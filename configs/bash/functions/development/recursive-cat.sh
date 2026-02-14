#!/bin/bash

# recursively cats all files in a given directory with their names
# if run with no arguments, it cats the current directory
recursive_cat() {
    local dir="${1:-.}"

    # Check if directory exists
    if [[ ! -d "$dir" ]]; then
        echo "Directory does not exist: $dir" >&2
        return 1
    fi

    # Loop through items in the directory
    for item in "$dir"/*; do
        if [[ -d "$item" ]]; then
            # If item is a directory, recurse into it
            recursive_cat "$item"
        elif [[ -f "$item" ]]; then
            # If item is a file, print its name and contents
            echo "==> $item <=="
            cat "$item"
            echo ""
        fi
    done
}
