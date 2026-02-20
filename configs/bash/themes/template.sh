#!/bin/bash

# Theme Template
# Copy this file to create a new theme: cp template.sh your-theme-name.sh
# Then update BASH_THEME in config/theme.sh to use your theme

# Color definitions (modify these to create your color scheme)
C_USER='\[\033[1;36m\]'      # Cyan
C_HOST='\[\033[1;32m\]'      # Green  
C_PATH='\[\033[1;35m\]'      # Magenta
C_BRANCH='\[\033[1;33m\]'     # Yellow
C_AHEAD='\[\033[1;32m\]'      # Green
C_BEHIND='\[\033[1;31m\]'     # Red
C_SYNCED='\[\033[1;32m\]'      # Green
C_DIRTY='\[\033[1;31m\]'      # Red
C_SYMBOL='\[\033[1;37m\]'      # White
C_RESET='\[\033[0m\]'          # Reset

# Git helper functions
is_git_repo() {
    git rev-parse --git-dir >/dev/null 2>&1
}

get_git_branch() {
    git branch --show-current 2>/dev/null
}

get_git_status() {
    local status=$(git status --porcelain 2>/dev/null)
    if [[ -n "$status" ]]; then
        echo "dirty"
    else
        echo "clean"
    fi
}

get_ahead_behind() {
    local ahead_behind=$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null)
    local ahead=${ahead_behind#*	}
    local behind=${ahead_behind%	*}
    echo "$ahead $behind"
}

# Main prompt function
set_prompt() {
    # Get current directory and git info
    local dir_name="${PWD##*/}"
    
    # Build prompt
    PS1=""
    
    # User and host
    PS1+="${C_USER}\u${C_RESET}@${C_HOST}\h${C_RESET}:"
    
    # Current directory
    PS1+="${C_PATH}${dir_name}${C_RESET}"
    
    # Git information (if in git repo)
    if is_git_repo 2>/dev/null; then
        local branch=$(get_git_branch 2>/dev/null)
        local status=$(get_git_status)
        local ahead_behind=$(get_ahead_behind)
        local ahead=${ahead_behind% *}
        local behind=${ahead_behind#* }
        
        PS1+=" ${C_BRANCH}[${branch}${C_RESET}"
        
        if [[ "$status" == "dirty" ]]; then
            PS1+="${C_DIRTY}*${C_RESET}"
        fi
        
        if [[ "$ahead" -gt 0 ]]; then
            PS1+=" ${C_AHEAD}↑${ahead}${C_RESET}"
        fi
        if [[ "$behind" -gt 0 ]]; then
            PS1+=" ${C_BEHIND}↓${behind}${C_RESET}"
        fi
    fi
    
    # Prompt symbol
    PS1+=" ${C_SYMBOL}\$${C_RESET} "
}
