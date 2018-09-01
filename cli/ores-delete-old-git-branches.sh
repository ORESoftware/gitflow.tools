#!/usr/bin/env bash


if ! type -f ores_get_project_root &> /dev/null; then
   npm i -s -g '@oresoftware/ores' || {
      echo "Could not install '@oresoftware/ores'";
      exit 1;
   }
fi

project_root="$(ores_get_project_root "$0")";
commands="$project_root/dist/commands"


export current_branch="$(git rev-parse --abbrev-ref HEAD)"



node "$commands/delete-old-branches" "$@"
