#!/usr/bin/env bash


set -e; # exit immediately if any command fails

export current_branch="$(git rev-parse --abbrev-ref HEAD)"

if [[ "$current_branch" != */feature/* ]] ; then
  echo "Current branch does not seem to be a feature branch by name, please check, and use --force to override.";
  echo "Current branch name: '$current_branch'";
  exit 1;
fi

git add .
git add -A
git commit --allow-empty -am "ores/gitflow auto-commit (PRE-squashed)"

git fetch origin;
# GIT_MERGE_AUTOEDIT=no git merge origin;
# git merge --no-commit --no-edit origin;

#git merge --no-edit origin;
git merge --no-edit 'HEAD@{upstream}';


current_commit="$(git rev-parse HEAD)"
new_branch="$current_branch@squashed";

git checkout -b "$new_branch";
git reset --soft "remotes/origin/dev";

git add .
git add -A
git commit --allow-empty -am "ores/gitflow auto-commit (squashed)"

clean_branch=`echo "$current_branch" | tr -dc '[:alnum:]'`  # replace non-alpha-numerics with nothing
git config --local "branch.$clean_branch.orescommit" "$current_commit"

git push -u origin "$new_branch"

