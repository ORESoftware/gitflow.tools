#!/usr/bin/env bash


set -e; # exit immediately if any command fails

commit_message="$1";

if [ -z "$commit_message" ]; then
  echo "Your commit message is empty, please pass a commit message as the first argument.";
  exit 1;
fi

export current_branch=`git rev-parse --abbrev-ref HEAD`;

if [[ "$current_branch" != */feature/* ]] ; then
  echo "Current branch does not seem to be a feature branch by name, please check, and use --force to override.";
  echo "Current branch name: '$current_branch'";
  exit 1;
fi

if [[ "$current_branch" == *"@squashed" ]]; then
    echo "Your current branch is already squashed.";
    exit 1;
fi

git fetch origin;

git add .
git add -A
git reset origin/dev -- config
git commit --allow-empty -m "ores/gitflow auto-commit (PRE-squashed)"

#git merge -Xignore-space-change -Xignore-all-space --no-edit 'HEAD@{upstream}';


current_commit=`git rev-parse HEAD`
new_branch="$current_branch@squashed";

git branch -D "$new_branch" 2> /dev/null || {
  echo "(no branch named '$new_branch' to delete)";
}

base="remotes/origin/dev";
git checkout --no-track -b "$new_branch";

if ! git rebase -Xignore-space-change -Xignore-all-space "$base"; then
  read -p "Git rebase failed. Press ENTER when you think you've fixed it"
fi

git reset --soft "$base";

git add .
git add -A
git reset origin/dev -- config
git commit --allow-empty -m "$commit_message"


clean_branch=`echo "$current_branch" | tr -dc '[:alnum:]'`  # replace non-alpha-numerics with nothing
git config --local "branch.$clean_branch.orescommit" "$current_commit"

git push -f -u origin "$new_branch" || {
  echo "Could not push to remote.";
  exit 1;
}


echo "Successfully pushed.";
# checkout new feature branch
ores_checkout_new_git_branch_from_integration feature next




