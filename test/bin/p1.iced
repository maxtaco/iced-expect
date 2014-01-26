#!/usr/bin/env iced

read = require 'read'

await read { prompt : "What is your name, Droote?" }, defer err, r1
await read {prompt : "Have you seen Jabbers?", silent : true }, defer err, r2
await read { prompt: "Love those dogs" }, defer err, r3
console.log [ r1, r2, r3 ].join (":")
process.exit 0