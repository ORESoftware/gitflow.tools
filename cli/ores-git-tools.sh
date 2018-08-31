#!/usr/bin/env bash

### we use this bash file instead of a dist/.js file, because of this problem:
### https://stackoverflow.com/questions/50616253/how-to-resolve-chicken-egg-situation-with-tsc-and-npm-install


if ! type -f ores_get_project_root &> /dev/null; then
   npm i -s -g '@oresoftware/ores' || {
      echo "Could not install '@oresoftware/ores'";
      exit 1;
   }
fi

project_root="$(ores_get_project_root "$0")";
commands="$project_root/dist/commands"

first_arg="$1";
shift 1;


if [ "$first_arg" == "copy-tools" ]; then

    node "$commands/copy-tools" "$@"

else

    echo "No commands matched."; false;

fi


exit_code="$?"
echo "Exiting with code => $exit_code";
exit "$exit_code";
