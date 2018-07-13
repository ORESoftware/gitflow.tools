'use strict';

import shortid = require("shortid");
import async = require('async');
import * as stdio from 'json-stdio';
import * as path from "path";
import * as cp from 'child_process';
import residence = require('residence');
import log from '../../logger';
const cwd = process.cwd();
const projectRoot = residence.findProjectRoot(cwd);

if (!projectRoot) {
  throw new Error('Could not find project root given current working directory: ' + cwd);
}

const dest = path.resolve(projectRoot + '/scripts/git');
const cloneableRepo = 'git@github.com:ORESoftware/gitflow.tools.git';

export type EVCb<T> = (err: any, val?: T) => void;

async.autoInject({

  mkdir(cb: EVCb<any>) {

    const k = cp.spawn('bash');
    k.stdin.end(`mkdir -p ${dest}`);
    k.once('exit', cb);

  },

  clone(cb: EVCb<any>) {

    const k = cp.spawn('bash');
    k.stdin.end(`ores clone "${cloneableRepo}"`);

    let result = {
      value: null as string
    };

    k.stdout.pipe(stdio.createParser()).once('data', (d: any) => {
      if (d && d.value) {
        result.value = String(d.value);
      }
    });

    k.once('exit', code => {
      cb(code, result.value);
    });

  },

  copy(mkdir: string, clone: string, cb: EVCb<any>) {

    if (typeof clone !== 'string') {
      return process.nextTick(cb, new Error('Could not find cloneable path.'));
    }

    const source = path.resolve(clone + '/assets/tools');
    const k = cp.spawn('bash');
    k.stdin.end(`rsync -r "${source}" "${dest}"`);
    k.once('exit', cb);

  }

}, (err, results) => {

  if (err) {
    throw err;
  }

  console.log('All done.');

});

