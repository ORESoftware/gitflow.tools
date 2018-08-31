#!/usr/bin/env bash


set -e; # exit immediately if any command fails

export current_branch="$(git rev-parse --abbrev-ref HEAD)"

if [ "$current_branch" != */feature/* ] ; then
  echo "Current branch does not seem to be a feature branch by name, please check, and use --force to override.";
  echo "Current branch name: '$current_branch'";
  exit 1;
fi

if ! git diff --quiet; then
   echo "Working tree/index not clean, use 'git status' to investigate";
   exit 1;
fi

git fetch origin;

git checkout -b "$current_branch/squashed"
git reset --soft "remotes/origin/dev";

git add .
git add -A
git commit -am "ores/gitflow auto-commit (squashed)"
git push

