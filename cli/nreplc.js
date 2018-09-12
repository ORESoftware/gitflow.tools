#!/usr/bin/env node
'use strict';

const rl = require('readline');
process.stdin.resume();

const regex = new RegExp(process.argv[2]);
const replaceWith = process.argv[3];

rl.createInterface({
  input: process.stdin
})
.on('line', l => {
   console.log(String(l || '').replace(regex, replaceWith));
});
