#!/usr/bin/env bash


if ! type -f ores_pre_commit_hook > /dev/null; then
   npm i -s -g '@oresoftware/git.tools' || {
      echo "Could not install @oresoftware/git.tools";
      echo 1;
   }
fi



ores_pre_commit_hook "$@"
