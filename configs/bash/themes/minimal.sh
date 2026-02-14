#!/bin/bash
# Minimal Theme - Simple and clean

# Color definitions
C_USER='\033[1;32m'   # Green
C_HOST='\033[1;34m'   # Blue
C_PATH='\033[1;35m'   # Magenta
C_BRANCH='\033[1;33m' # Yellow
C_SYMBOL='\033[1;36m' # Cyan
C_RESET='\033[0m'

# Build the prompt
set_prompt() {
    PS1="\[${C_USER}\]\u\[${C_RESET}\]@"
    PS1+="\[${C_HOST}\]\h\[${C_RESET}\]:"
    PS1+="\[${C_PATH}\]\w\[${C_RESET}\]"
    
    if is_git_repo 2>/dev/null; then
        local branch=$(get_git_branch 2>/dev/null)
        PS1+=" \[${C_BRANCH}\](${branch})\[${C_RESET}\]"
    fi
    
    PS1+=" \[${C_SYMBOL}\]\$\[${C_RESET}\] "
}

PROMPT_COMMAND=set_prompt
