#!/usr/bin/env bash

set -e; # exit immediately if any command fails

current_branch="$(git rev-parse --abbrev-ref HEAD)"

if [ "$current_branch" == "master" ] || [ "$current_branch" == "dev" ]; then
    echo 'Aborting script because you are on master or dev branch; you need to be on a feature branch.';
    git pull;
    exit $?;  # use 0 not 1
fi


time_seconds=`node -e 'console.log(String(Date.now()).slice(0,-3))'`;
git fetch origin;

git add .
git add -A
git commit --allow-empty -am "merge_at_${time_seconds}"

git rebase -Xignore-all-space "remotes/origin/dev"
git rebase -Xignore-all-space --no-edit 'HEAD@{upstream}';

git push origin HEAD

