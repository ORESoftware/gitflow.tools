#!/usr/bin/env bash

set -e; # exit immediately if any command fails

current_branch="$(git rev-parse --abbrev-ref HEAD)"

if [ "$current_branch" == "master" ] || [ "$current_branch" == "dev" ]; then
    echo 'Aborting script because you are on master or dev branch, you need to be on a feature branch.';
    exit 1;
fi

contains() {

    local seeking="$1"; shift 1;
    local arr=( "$@" )

    for v in "${arr[@]}"; do
        if [ "$v" == "$seeking" ]; then
            return 0;
        fi
    done
   return 1;
}

rebase="yep";
if contains "--no-rebase" "$@"; then
  rebase="nope";
fi


time_seconds=`node -e 'console.log(String(Date.now()).slice(0,-3))'`;
git fetch origin;

git add .
git add -A
git commit --allow-empty -am "merge_at_${time_seconds}"

### merge with upstream
git merge -Xignore-all-space --no-edit 'HEAD@{upstream}';


if [ "$rebase" == "yep" ]; then
    git rebase -Xignore-all-space "remotes/origin/dev"
else
    git merge -Xignore-space-change "remotes/origin/dev" # use --no-ff to force a new commit
fi

git push origin HEAD

