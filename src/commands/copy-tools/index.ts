'use strict';

import shortid = require("shortid");
import async = require('async');
import * as stdio from 'json-stdio';
import * as path from "path";
import * as cp from 'child_process';
const source = process.argv[2];
const dest = process.argv[3];
import residence = require('residence');
const cwd = process.cwd();
const projectRoot = residence.findProjectRoot(cwd);

if(!projectRoot){
  throw new Error('Could not find project root given current working directory: ' + cwd);
}

export type EVCb = (err: any, val?: any) => void;

async.autoInject({

  mkdir(cb: EVCb){

    const k = cp.spawn('bash');
    k.stdin.end(`mkdir -p ${dest}`);
    k.once('exit', cb);

  },

  copy(mkdir: string, cb: EVCb){

    const k = cp.spawn('bash');
    k.stdin.end(`rsync -r "${source}" "${dest}"`);
    k.once('exit', cb);

  }



}, (err, results) => {

  if(err){
    throw err;
  }




});

