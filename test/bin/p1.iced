#!/usr/bin/env iced

read = require 'read'

await read { prompt : "What is your name, Droote?" }, defer err, r1
await read {prompt : "Have you seen Jabbers?", silent : true }, defer err, r2
console.log [ r1, r2 ].join (":")
process.exit 0