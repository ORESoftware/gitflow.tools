#!/usr/bin/env bash


install_ores_gitflow(){
  if ! type -f ores_git_tools &> /dev/null; then
      npm i -g -s '@oresoftware/git.tools' || {
        echo &>2 "Could not install @oresoftware/git.tools ...";
        exit 1;
      }
  fi
}



ores_git_merge_with_integration(){
   install_ores_gitflow;
   command ores_git_merge_with_integration "$@"
}


export -f install_ores_gitflow;
export -f ores_git_merge_with_integration;
