#!/usr/bin/env bash

set -e;

branch=`git rev-parse --abbrev-ref HEAD`
commit_message="${1:-set}" # default commit message is 'set'

git add .
git add -A
git commit --allow-empty -am "ores/auto-commit => '$commit_message'"
git push

echo "pushed successfully to remote"
