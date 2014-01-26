{spawn} = require 'child_process'
{List} = require 'iced-data-structures'

#============================================================

exports.Engine = class Engine

  #-----------------------------

  constructor : ({@args, @name}) ->
    @_exit_code = null
    @_exit_cb = null
    @_n_out = 0
    @_probes = new List

  #-----------------------------

  _got_data : (data, source) ->
    s = data.toString('utf8')
    @_probes.walk (o) =>
      for term in o.terms
        if (not(term.source?) or (term.source is source)) and s.match(term.pattern)
          @_probes.remove o
          o.cb null, data, source
          return true
      return false

  #-----------------------------

  _clear_probes : () ->
    @_probes.walk (o) =>
      @_probes.remove o
      o.cb new Error "EOF before expectation met"

  #-----------------------------

  expect : (terms, cb) ->
    @_probes.push { terms, cb }

  #-----------------------------

  run : () ->
    @proc = spawn @name, @args
    @pid = @proc.pid
    @proc.on 'exit', (status) => @_got_exit status
    @proc.stderr.on 'end',  ()     => @_maybe_finish()
    @proc.stdout.on 'end',  ()     => @_maybe_finish()
    @proc.stderr.on 'data', (data) => @_got_data data, 'stderr'
    @proc.stdout.on 'data', (data) => @_got_data data, 'stdout'

  #-----------------------------

  send : (args...) ->
    if @proc 
      @proc.stdin.write args...
    else
      args[-1...][0] new Error "EOF on input; can't send"

  #-----------------------------

  _got_exit : (status) ->
    @_exit_code = status
    @handler.got_exit status
    @proc = null
    @_maybe_finish()

  #-----------------------------

  _maybe_finish : () ->
    if --@_n_out <= 0
      @_clear_probes()
      if (ecb = @_exit_cb)?
        @_exit_cb = null
        ecb = @_exit_code
      @pid = -1

  #-----------------------------

  wait : (cb) ->
    if (@_exit_code and @_n_out <= 0) then cb @_exit_code
    else @_exit_cb = cb

#============================================================

