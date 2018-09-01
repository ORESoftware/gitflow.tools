'use strict';

import shortid = require("shortid");
import async = require('async');
import * as stdio from 'json-stdio';
import * as path from "path";
import * as cp from 'child_process';
import residence = require('residence');
import chalk from 'chalk';
import log from '../../logger';
import {flattenDeep, getUniqueList} from '../../utils';

const cwd = process.cwd();
const projectRoot = residence.findProjectRoot(cwd);

if (!projectRoot) {
  throw new Error('Could not find project root given current working directory: ' + cwd);
}

const dest = path.resolve(projectRoot + '/scripts/git');
const cloneableRepo = 'git@github.com:ORESoftware/gitflow.tools.git';

export type EVCb<T> = (err: any, val?: T) => void;

export type Task = (cb: EVCb<any>) => void;
const q = async.queue<Task, any>((task, cb) => task(cb), 1);

const currentBranch = String(process.env.current_branch).trim();

if (!currentBranch) {
  throw chalk.magenta('Current branch env var was empty, check your current git branch.');
}

interface MergedBranchesResult {
  value: Array<string>,
  stdout: string
}

interface CommitHashResult {
  value: Map<string, string>,
  hashes: Set<string>
  stdout: string
}

interface DeleteResult {
  value: string
}

async.autoInject({
  
  findMergedBranches(cb: EVCb<MergedBranchesResult>) {
    
    q.push(cb => {
      
      const k = cp.spawn('bash');
      
      const result = <MergedBranchesResult>{
        value: [],
        stdout: ''
      };
      
      const cmd = `git branch --merged "remotes/origin/dev"`;
      
      k.stdin.end();
      
      k.stdout.on('data', d => {
        result.stdout += String(d);
      });
      
      k.stderr.pipe(process.stderr);
      
      k.once('exit', code => {
        
        if (code > 0) {
          log.error('Could not run command:', chalk.magenta(cmd));
          return cb(code);
        }
        
        result.value = String(result.stdout)
        .split('\n')
        .map(v => String(v || '').trim())
        .filter(Boolean)
        .filter(v => v !== currentBranch);
        
        cb(code, result);
        
      });
      
    }, cb);
    
  },
  
  getCommitsByBranch(findMergedBranches: MergedBranchesResult, cb: EVCb<CommitHashResult>) {
    
    q.push(cb => {
      
      const branches = findMergedBranches.value;
      const marker = '@squashed';
      
      const specialBranches = branches.filter(v => v.endsWith(marker));
      
      const result = <CommitHashResult>{
        value: new Map(),  // map <branch,current hash>
        hashes: new Set(),  // set < squashed branch hash >
        stdout: ''
      };
      
      async.each(specialBranches, (v, cb) => {
        
        const k = cp.spawn('bash');
        
        // add second to last element to the Set
        result.hashes.add(String(v).split('@').slice(-1).reverse()[0]);
        
        // remove the last two elements, @<hash>@squashed
        const b = String(v).split('@').slice(-2).join('');
        const cmd = `git rev-parse "${b}"`;
        
        let stdout = '';
        
        k.stdin.end();
        
        k.stdout.on('data', d => {
          stdout += String(d);
        });
        
        k.stderr.pipe(process.stderr);
        
        k.once('exit', code => {
          
          if (code > 0) {
            log.error('Could not run command:', chalk.magenta(cmd));
            return cb(null);
          }
          
          result.value.set(b, String(stdout).trim());
          cb(code);
          
        });
        
      }, err => {
        process.nextTick(cb, err, result);
      });
      
    }, cb);
    
  },
  
  runDelete(findMergedBranches: MergedBranchesResult, getCommitsByBranch: CommitHashResult, cb: EVCb<DeleteResult>) {
    
    const branches = findMergedBranches.value;
    const marker = '@squashed';
    
    // we remove brances xxx, where xxx@squashed exists
    const additionalBranches = Array.from(getCommitsByBranch.value.keys()).filter(v => {
      // we return true if the tip of a the feature branch is in the name of a squashed branch
      const currentCommitHash = getCommitsByBranch.value.get(v);
      return getCommitsByBranch.hashes.has(currentCommitHash);
    });
    
    const finalList = getUniqueList(flattenDeep([branches, additionalBranches]));
    
    const k = cp.spawn('bash');
    const cmd = `git branch -D ${finalList.join(' ')}`;
    k.stdin.end(cmd);
    
    let result = <DeleteResult>{
      value: ''
    };
    
    k.stdout.once('data', (d: any) => {
      result.value += String(d.value);
    });
    
    k.once('exit', code => {
      
      if (code > 0) {
        log.warning('The following commmand exited with code greater than zero:', chalk.magenta(cmd));
      }
      
      cb(null, result);
    });
    
  },
  
}, (err, results) => {
  
  if (err) {
    throw err;
  }
  
  console.log('All done.');
  
});

