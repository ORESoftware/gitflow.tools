#!/usr/bin/env bash

set -e;

#branch=`git rev-parse --abbrev-ref HEAD`
commit_message="${1:-set}" # default commit message is 'set'

git add .
git add -A
git reset origin/dev -- config || echo 'Could not reset config folder.';

commit_made="nope";

if git commit -m "ores/auto-commit => '$commit_message'"; then
 commit_made="yes"
else
 echo 'Could not create new commit.';
fi

if [ "$commit_made" == "yes" ]; then
    git push
fi

echo "pushed successfully to remote"
