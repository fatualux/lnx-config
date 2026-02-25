#!/bin/bash

# Directory completion function
_dirs_complete() {
    local CURRENT_PROMPT="${COMP_WORDS[COMP_CWORD]}"

    # Parse all defined shortcuts from ~/.dirs
    if [[ -r "$HOME/.dirs" ]]; then
        COMPREPLY=($(compgen -W "$(grep -v '^#' "$HOME/.dirs" | sed -e 's/\(.*\)=.*/\1/')" -- "$CURRENT_PROMPT"))
    fi

    return 0
}

# Register completion for G and R commands
complete -o default -o nospace -F _dirs_complete G R