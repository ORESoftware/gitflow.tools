#!/usr/bin/env bash

set -e;

branch_type="${1:-feature}";
arr=( 'feature' 'bugfix' 'release' );


branch_name="$2";

if [ -z "$branch_name" ]; then
  echo "Your branch name is empty, please pass a name for the branch as the second argument. The first arg is branch type: ($arr[@]).";
  exit 1;
fi


contains() {

    local seeking="$1"
    shift 1;
    local arr=( "$@" )

    for v in "${arr[@]}"; do
        if [ "$v" == "$seeking" ]; then
            return 0;
        fi
    done
   return 1;
}

if ! contains "$branch_type" "${arr[@]}"; then
    echo "Branch type needs to be either 'feature', 'bugfix' or 'release'."
    echo "The branch type you passed was: $branch_type"
    exit 1;
fi


git fetch origin;

time_seconds=`node -e 'console.log(String(Date.now()).slice(0,-3))'`;

echo "You are checking out a new $branch_type branch from the dev branch"
new_branch="${USER}/${branch_type}/${branch_name}"

echo "New branch name: $new_branch";

git branch --no-track "${new_branch}" "remotes/origin/dev"
git checkout "${new_branch}"
git push -u origin HEAD  # makes sure git is tracking this branch on the primary remote
