#!/usr/bin/env bash

### we use this bash file instead of a dist/.js file, because of this problem:
### https://stackoverflow.com/questions/50616253/how-to-resolve-chicken-egg-situation-with-tsc-and-npm-install

dir_name="$(dirname "$0")"
read_link="$(readlink "$0")";
exec_dir="$(dirname $(dirname "$read_link"))";
my_path="$dir_name/$exec_dir";
basic_path="$(cd $(dirname ${my_path}) && pwd)/$(basename ${my_path})"
commands="$basic_path/dist/commands"


### there is an extradinary amount of magic required to get a bash script
### to properly reference an adjacent .js file
### if the above can be simplified, please lmk, but the above is currently very necessary.

### one value add here of using a bash script, is that we can easily install any missing CLI dependencies
### or set env variables as needed

### run this mofo


if ! type -f ores; then
  npm i -g -s '@oresoftware/ores' || {
    echo &>2 "Could not install ores command line tool.";
    exit 1;
  }
fi

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
