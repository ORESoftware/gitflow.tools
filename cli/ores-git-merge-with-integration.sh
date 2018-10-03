#!/usr/bin/env bash

set -e; # exit immediately if any command fails

current_branch=`git rev-parse --abbrev-ref HEAD`;

if [ "$current_branch" == "master" ] || [ "$current_branch" == "dev" ]; then
    echo 'Aborting script because you are on master or dev branch; you need to be on a feature branch.';
    git pull;
    exit $?;
fi

if [[ "$current_branch" == *"@squashed" ]]; then
    echo "Your current branch is already squashed.";
    exit 1;
fi


git fetch origin;
time_seconds=`node -e 'console.log(String(Date.now()).slice(0,-3))'`;

if ! git diff --quiet  --exit-code > /dev/null || ! git diff --quiet --cached --exit-code > /dev/null; then

    git add .
    git add -A
    git reset origin/dev -- config
    git commit -m "merging with remotes/origin/dev at ${time_seconds}" || echo 'Could not create new commit.';

fi

git merge -Xignore-all-space "remotes/origin/dev" # use --no-ff to force a new commit

# git merge -Xignore-all-space --no-edit 'HEAD@{upstream}';

git push origin HEAD

