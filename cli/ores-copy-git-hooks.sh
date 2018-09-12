#!/usr/bin/env bash

set -C    # or set -o noclobber

dir="$(dirname ${BASH_SOURCE})";
githooks="$(cd $(dirname "$dir") && pwd)/assets/githooks"


for f in "$(find "$githooks" -maxdepth 1 -type f)"; do
    echo "Copying this file: $f";
    dest="$PWD/.git/hooks/$(basename "$f")"
    echo "To this location: $dest";
    cat "$f" > "$dest"
done

