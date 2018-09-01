#!/usr/bin/env bash


set -e;

if [ "$skip_postinstall" == "yes" ]; then
    echo "skipping nlu postinstall routine.";
    exit 0;
fi

export FORCE_COLOR=1;
export skip_postinstall="yes";


mkdir -p "$HOME/.oresoftware/bash" && {
  cat "assets/shell.sh" > "$HOME/.oresoftware/bash/ores_git_tools.sh" || {
    echo "Could not copy ores_git_tools.sh file to ~/.oresoftware/bash dir.";
    exit 1;
  }
}
