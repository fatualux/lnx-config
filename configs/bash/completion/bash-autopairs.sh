#!/bin/bash

if [[ $- != *i* ]]; then
    return 0
fi

if [[ -f "$BASH_CONFIG_DIR/completion/bash-autopairs/main.sh" ]]; then
    source "$BASH_CONFIG_DIR/completion/bash-autopairs/main.sh"
fi
