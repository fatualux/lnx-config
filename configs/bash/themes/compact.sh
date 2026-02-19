#!/bin/bash
# Compact Theme - Two-line with essential info

# Color definitions
C_TIME='\033[38;5;111m'   # Light blue
C_USER='\033[38;5;214m'   # Orange
C_PATH='\033[38;5;105m'   # Purple
C_VENV='\033[38;5;228m'   # Yellow
C_BRANCH='\033[38;5;210m' # Pink
C_AHEAD='\033[38;5;82m'   # Green
C_BEHIND='\033[38;5;196m' # Red
C_RESET='\033[0m'

# Build the prompt
set_prompt() {
    # Line 1: [time] user ~ path
    PS1="\[${C_TIME}\]\t\[${C_RESET}\] "
    PS1+="\[${C_USER}\]\u\[${C_RESET}\] "
    PS1+="~ \[${C_PATH}\]\w\[${C_RESET}\]\n"
    
    # Line 2: [venv] >> branch ↑↓
    if [ -n "$VIRTUAL_ENV" ]; then
        local venv_name=$(basename "$VIRTUAL_ENV")
        PS1+="\[${C_VENV}\][${venv_name}]\[${C_RESET}\] "
    fi
    
    if is_git_repo 2>/dev/null; then
        local branch=$(get_git_branch 2>/dev/null)
        local git_status=$(get_git_status 2>/dev/null)
        local ahead=$(echo "$git_status" | awk '{print $1}')
        local behind=$(echo "$git_status" | awk '{print $2}')
        
        PS1+=">> \[${C_BRANCH}\]${branch}\[${C_RESET}\] "
        
        if [ "$ahead" -gt 0 ]; then
            PS1+="\[${C_AHEAD}\]↑${ahead}\[${C_RESET}\]"
        fi
        if [ "$behind" -gt 0 ]; then
            PS1+="\[${C_BEHIND}\]↓${behind}\[${C_RESET}\]"
        fi
    fi
    
    PS1+=" \$ "
}
