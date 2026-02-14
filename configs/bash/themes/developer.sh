#!/bin/bash
# Developer Theme - Detailed git information

# Color definitions
C_DATE='\033[38;5;81m'      # Cyan
C_USER='\033[38;5;220m'     # Gold
C_HOST='\033[38;5;77m'      # Green
C_IP='\033[38;5;183m'       # Lavender
C_PATH='\033[38;5;117m'     # Sky blue
C_VENV='\033[38;5;229m'     # Light yellow
C_BRANCH='\033[38;5;211m'   # Pink
C_DETACHED='\033[38;5;202m' # Orange
C_GIT_USER='\033[38;5;159m' # Pale cyan
C_AHEAD='\033[38;5;120m'    # Light green
C_BEHIND='\033[38;5;203m'   # Salmon
C_SYMBOL='\033[38;5;246m'   # Gray
C_RESET='\033[0m'

# Get IP address
get_ip_address() {
    hostname -I 2>/dev/null | awk '{print $1}' || echo "N/A"
}

# Build the prompt
set_prompt() {
    local date_str=$(date '+%y/%m/%d')
    local ip_addr=$(get_ip_address)
    
    # Line 1: YY/MM/DD >> USER#host[ip]
    PS1="\[${C_DATE}\]${date_str}\[${C_RESET}\] "
    PS1+="\[${C_SYMBOL}\]>>\[${C_RESET}\] "
    PS1+="\[${C_USER}\]\u\[${C_RESET}\]"
    PS1+="\[${C_SYMBOL}\]#\[${C_RESET}\]"
    PS1+="\[${C_HOST}\]\h\[${C_RESET}\]"
    PS1+="\[${C_SYMBOL}\][\[${C_RESET}\]"
    PS1+="\[${C_IP}\]${ip_addr}\[${C_RESET}\]"
    PS1+="\[${C_SYMBOL}\]]\[${C_RESET}\]\n"
    
    # Line 2: path | [venv] >> branch
    PS1+="\[${C_PATH}\]\w\[${C_RESET}\] "
    PS1+="\[${C_SYMBOL}\]|\[${C_RESET}\] "
    
    if [ -n "$VIRTUAL_ENV" ]; then
        local venv_name=$(basename "$VIRTUAL_ENV")
        PS1+="\[${C_SYMBOL}\][\[${C_RESET}\]"
        PS1+="\[${C_VENV}\]${venv_name}\[${C_RESET}\]"
        PS1+="\[${C_SYMBOL}\]]\[${C_RESET}\] "
    fi
    
    if is_git_repo 2>/dev/null; then
        local branch=$(get_git_branch 2>/dev/null)
        PS1+="\[${C_SYMBOL}\]>>\[${C_RESET}\] "
        if is_git_detached 2>/dev/null; then
            PS1+="\[${C_DETACHED}\]${branch}\[${C_RESET}\]"
        else
            PS1+="\[${C_BRANCH}\]${branch}\[${C_RESET}\]"
        fi
    fi
    
    PS1+="\n"
    
    # Line 3: git user info and sync status
    if is_git_repo 2>/dev/null; then
        local git_name=$(get_git_user_name 2>/dev/null)
        local git_email=$(get_git_user_email 2>/dev/null)
        local git_status=$(get_git_status 2>/dev/null)
        local ahead=$(echo "$git_status" | awk '{print $1}')
        local behind=$(echo "$git_status" | awk '{print $2}')
        
        PS1+="\[${C_GIT_USER}\]${git_name}@${git_email}\[${C_RESET}\] "
        PS1+="\[${C_SYMBOL}\]>>\[${C_RESET}\] "
        
        if [ "$ahead" -gt 0 ]; then
            PS1+="\[${C_AHEAD}\]↑ ahead ${ahead}\[${C_RESET}\] "
        fi
        if [ "$behind" -gt 0 ]; then
            PS1+="\[${C_BEHIND}\]↓ behind ${behind}\[${C_RESET}\] "
        fi
        if [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ]; then
            PS1+="\[${C_SYMBOL}\](synced)\[${C_RESET}\]"
        fi
        
        PS1+="\n"
    fi
    
    PS1+="\[${C_SYMBOL}\]➜\[${C_RESET}\] "
}

PROMPT_COMMAND=set_prompt
