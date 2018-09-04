#!/usr/bin/env bash

all_export="yep";

if [[ ! "$SHELLOPTS" =~ "allexport" ]]; then
    all_export="nope";
    set -a;
fi

ores_install_gitflow(){
  if ! type -f ores_git_tools &> /dev/null; then
      npm i -g -s '@oresoftware/git.tools' || {
        echo &>2 "Could not install @oresoftware/git.tools ...";
        exit 1;
      }
  fi
}


ores_git_merge_with_integration(){
   ores_install_gitflow;
   command "$FUNCNAME" "$@"
}

ores_git_tools(){
   ores_install_gitflow;
   command "$FUNCNAME" "$@"
}

ores_git_push(){
   ores_install_gitflow;
   command "$FUNCNAME" "$@"
}

ores_list_git_branches_to_delete(){
   ores_install_gitflow;
   command "$FUNCNAME" "$@"
}

ores_determine_if_git_branch_is_merged_with_integration(){
   ores_install_gitflow;
   command "$FUNCNAME" "$@"
}

ores_git_squash_to_integration(){
   ores_install_gitflow;
   command "$FUNCNAME" "$@"
}

ores_delete_old_git_branches(){
   ores_install_gitflow;
   command "$FUNCNAME" "$@"
}

ores_checkout_new_git_branch_from_integration(){
   ores_install_gitflow;
   command "$FUNCNAME" "$@"
}


if [ "$all_export" == "nope" ]; then
  set +a;
fi

