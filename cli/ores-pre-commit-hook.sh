#!/usr/bin/env bash


set -e;

if [ "ores_gitflow_pre_commit" == "force" ]; then
    exit 0;
fi

git fetch origin;

if ! type -f read_json > /dev/null; then
  npm i -g -s '@oresoftware/read.json' || {
    echo 'Could not install @oresoftware/read.json, fatal.';
    exit 1;
  }
fi


if ! type -f nreplc > /dev/null; then
  npm i -g -s '@oresoftware/git.tools' || {
    echo 'Could not install @oresoftware/git.tools, fatal.';
    exit 1;
  }
fi

current_branch=`git rev-parse --abbrev-ref HEAD`;
echo "Current branch: '$current_branch'";

remote_tracking_branch="$current_branch@{upstream}"

if ! git diff --exit-code HEAD "$remote_tracking_branch"; then
   echo "There is a diff between HEAD and the remote tracking branch.";
   exit 1;
fi


master='';
integration='';

if [ -f '.vcs.json' ]; then
    master=`read_json -f .vcs.json -k git.master`
    integration=`read_json -f .vcs.json -k git.integration`
fi

master="${master-master}";
integration="${integration-dev}";


if [ "$allow_commit_to_master" != "yes" ]; then
    if [ "$current_branch" == "$master" ]; then
       echo "Cannot commit to master without using an env variable: allow_commit_to_master=yes."
       exit 1;
    fi
fi

if [ "$allow_commit_to_integration" != "yes" ]; then
    if [ "$current_branch" == "$integration" ]; then
       echo "Cannot commit to integration branch without using an env variable: allow_commit_to_integration=yes."
       exit 1;
    fi
fi


branches="$(git branch --merged remotes/origin/dev | tr -d " *" |  nreplc '@squashed$' '')"

for b in "$branches"; do
   if [[ "$current_branch" == *b ]]; then
     echo "The tip of your current branch has already been merged into integration.";
     echo "You cannot commit to this branch, please use git stash and checkout another branch.";
     exit 1;
   fi
done


echo "Git pre-commit hook passed.";
