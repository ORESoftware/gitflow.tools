#!/usr/bin/env bash

all_export="yep";

if [[ ! "$SHELLOPTS" =~ "allexport" ]]; then
    all_export="nope";
    set -a;
fi

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
   command "$FUNCNAME" "$@"
}

ores_git_tools(){
   install_ores_gitflow;
   command "$FUNCNAME" "$@"
}

ores_git_push(){
   install_ores_gitflow;
   command "$FUNCNAME" "$@"
}

ores_list_git_branches_to_delete(){
   install_ores_gitflow;
   command "$FUNCNAME" "$@"
}

ores_determine_if_git_branch_is_merged_with_integration(){
   install_ores_gitflow;
   command "$FUNCNAME" "$@"
}

ores_git_squash_to_integration(){
   install_ores_gitflow;
   command "$FUNCNAME" "$@"
}

ores_delete_old_git_branches(){
   install_ores_gitflow;
   command "$FUNCNAME" "$@"
}

ores_checkout_new_branch_from_integration(){
   install_ores_gitflow;
   command "$FUNCNAME" "$@"
}


if [ "$all_export" == "nope" ]; then
  set +a;
fi

