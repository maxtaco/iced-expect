
read = require 'read'
{Engine} = require '../../lib/main'
path = require 'path'


exports.t1 = (T,cb) ->
  eng = new Engine { 
    name : path.join(__dirname, "..", "bin", "p1.iced")
  }
  eng.run()
  await eng.expect [{ pattern : /Droote\?/ } ], defer err
  T.no_error err
  await eng.send "Joe\n", defer()
  await eng.expect [{ pattern : /Jabbers\?/ } ], defer err
  T.no_error err
  await eng.send "Bill\n", defer()
  await eng.expect [{ pattern : /those dogs/ } ], defer err
  T.no_error err
  await eng.send "me2\n", defer()
  await eng.wait defer rc
  T.equal rc, 0, "error was 0"
  T.equal eng.stdout().toString('utf8'), "Joe:Bill:me2\n", "right stdout"
  cb()

exports.t2 = (T,cb) ->
  eng = new Engine { 
    name : path.join(__dirname, "..", "bin", "p1.iced")
  }
  await eng.run().conversation [
    { expect : "What is your name, Droote?" },
    { sendline : "abc" },
    { expect : /Jabbers\?/ },
    { sendline : "1234" },
    { expect : /those dogs/ },
    { sendline : "woof" }
  ], defer err
  await eng.wait defer rc
  T.equal rc, 0, "error was 0"
  T.equal eng.stdout().toString('utf8'), "abc:1234:woof\n", "right stdout"
  cb()
