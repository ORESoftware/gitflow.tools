'use strict';

import shortid = require("shortid");
import async = require('async');
import * as stdio from 'json-stdio';
import * as path from "path";
import * as cp from 'child_process';
import residence = require('residence');
import chalk from 'chalk';
import log from '../../logger';
import {EVCb, flattenDeep, getUniqueList} from '../../utils';
import pt from 'prepend-transform';

const cwd = process.cwd();
const projectRoot = residence.findProjectRoot(cwd);

if (!projectRoot) {
  throw new Error('Could not find project root given current working directory: ' + cwd);
}

const actuallyDelete = process.argv.indexOf('-d') > 1;
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
  branches: Array<string>,
  stdout: string
}

interface DeleteResult {
  value: string
}

async.autoInject({
  
  fetchOrigin(cb: EVCb<any>) {
    
    q.push(cb => {
      
      const k = cp.spawn('bash');
      
      const result = <any>{
        value: [],
        stdout: ''
      };
      
      const cmd = `git fetch origin`;
      k.stdin.end(cmd);
      
      k.stdout.on('data', d => {
        result.stdout += String(d);
      });
      
      k.stderr.pipe(pt(chalk.yellow.bold(`ores/git fetch origin: `))).pipe(process.stderr);
      
      k.once('exit', code => {
        
        if (code > 0) {
          log.error('Could not run command:', chalk.magenta(cmd));
          return cb(code);
        }
        
        result.value = String(result.stdout).trim();
        cb(code, result);
        
      });
      
    }, cb);
    
  },
  
  findMergedBranches(fetchOrigin: any, cb: EVCb<MergedBranchesResult>) {
    
    q.push(cb => {
      
      const k = cp.spawn('bash');
      
      const result = <MergedBranchesResult>{
        value: [],
        stdout: ''
      };
      
      const cmd = `git branch --merged "remotes/origin/dev" | tr -d ' *'`;
      k.stdin.end(cmd);
      
      k.stdout.on('data', d => {
        result.stdout += String(d);
      });
      
      k.stderr.pipe(pt(chalk.yellow.bold(`ores/find merged branches: `))).pipe(process.stderr);
      
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
      
      const result = <CommitHashResult> {
        // map: new Map(),  // map <branch,current hash>
        // set: new Set(),  // set < squashed branch hash >,
        branches: [],
        stdout: ''
      };
      
      async.each(specialBranches, (v, cb) => {
        
        const k = cp.spawn('bash');
        const b = String(v).split('@').slice(0, -1).join('');
        const cleanBranch = b.replace(/[^a-zA-Z0-9]/g, '');
        const divider = '***divider***';
        
        const cmd = [
          `commit="$(git config --local 'branch.${cleanBranch}.orescommit')__ensured"`,  // __ensured means we always get some stdout
          `echo "$commit"`,
          `echo "${divider}"`,
          `git rev-parse "${b}"`
        ]
        .join(' && ');
        
        k.stdin.end(cmd);
        
        let stdout = '';
        
        k.stdout.on('data', d => {
          stdout += String(d || '').trim();
        });
        
        k.stderr.pipe(pt(chalk.yellow.bold(`ores/get commits by branch: `))).pipe(process.stderr);
        
        k.once('exit', code => {
          
          if (code > 0) {
            log.error('Could not run command:', chalk.magenta(cmd));
            return cb(null);
          }
          
          const getSplitDivider = () : Array<string> => {
            return String(stdout).trim().split(divider).map(v => String(v || '').trim()).filter(Boolean);
          };
          
          const storedCommit = getSplitDivider().shift().replace('__ensured', '');
          const currentCommit = getSplitDivider().pop();
          
          if (currentCommit === storedCommit) {
            result.branches.push(b);
          }
          
          cb(code);
        });
        
      }, err => {
        process.nextTick(cb, err, result);
      });
      
    }, cb);
    
  },
  
  runDelete(findMergedBranches: MergedBranchesResult, getCommitsByBranch: CommitHashResult, cb: EVCb<DeleteResult>) {
    
    q.push(v => {
      
      const branches = findMergedBranches.value;
      const additionalBranches = getCommitsByBranch.branches;
      const finalList = getUniqueList(flattenDeep([branches, additionalBranches]));
      
      if (!actuallyDelete) {
        
        if (finalList.length > 0) {
          log.info('The following branches would be deleted if you use the -d flag:');
          finalList.forEach(v => log.info(v));
        }
        else {
          log.warning('No branches would be deleted.');
        }
        
        return process.nextTick(cb);
      }
      
      const k = cp.spawn('bash');
      k.stderr.pipe(pt(`ores/run delete:`)).pipe(process.stderr);
      
      const cmd = `git branch -D ${finalList.join(' ')}`;
      k.stdin.end(cmd);
      
      let result = <DeleteResult> {
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
      
    }, cb);
    
  },
  
}, (err, results) => {
  
  if (err) {
    throw err;
  }
  
  log.info('All done.');
  
});

