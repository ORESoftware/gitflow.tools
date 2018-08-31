#!/usr/bin/env bash


set -e; # exit immediately if any command fails

if ! git diff --quiet; then
   echo "Working tree/index not clean, use git status to investigate";
   exit 1;
fi

current_branch="$(git rev-parse --abbrev-ref HEAD)"

if [ "$current_branch" != *feature* ] ; then
  echo "Current branch does not seem to be a feature branch by name, please check, and use --force to override.";
  exit 1;
fi

git fetch origin;



