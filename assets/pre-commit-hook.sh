#!/usr/bin/env bash

git fetch origin dev

if ! type -f read_json > /dev/null; then
  npm i -g -s '@oresoftware/read.json' || {
    echo 'Could not install @oresoftware/read.json, fatal.';
    exit 1;
  }
fi

master="master";
integration="integration";

if [ -f '.vcs.json' ]; then
    master="${`read_json -f .vcs.json -k git.master`:-master}"
    integration="${`read_json -f .vcs.json -k git.integration`:-integration}"
fi

current_branch=`git rev-parse --abbrev-ref HEAD`
echo "Current branch: '$current_branch'";

branches="$(git branch --merged dev | tr '@squashed' '')"


for b in "$branches"; do
   if [[ "$current_branch" == *b ]]; then
     echo "The tip of your current branch has already been merged into integration.";
     exit 1;
   fi
done
