#!/bin/bash
# Default Theme - Colorful multi-line prompt

# Color definitions (customizable) - use escape codes without \[\]
C_DATE='\033[38;5;45m'      # Cyan
C_USER='\033[38;5;208m'     # Orange
C_HOST='\033[38;5;118m'     # Green
C_IP='\033[38;5;141m'       # Purple
C_VENV='\033[38;5;226m'     # Yellow
C_BRANCH='\033[38;5;203m'   # Pink
C_GIT_USER='\033[38;5;75m'  # Light Blue
C_GIT_AHEAD='\033[38;5;46m' # Bright Green
C_GIT_BEHIND='\033[38;5;196m' # Red
C_SYMBOL='\033[38;5;250m'   # Gray
C_RESET='\033[0m'

# Get IP address
get_ip_address() {
    hostname -I 2>/dev/null | awk '{print $1}' || echo "N/A"
}

# Build the prompt using PROMPT_COMMAND
set_prompt() {
    local date_str=$(date '+%y/%m/%d')
    local ip_addr=$(get_ip_address)
    
    # Line 1: YY/MM/DD >> USER#host[ip_address]
    PS1="\[${C_DATE}\]${date_str}\[${C_RESET}\]"
    PS1+=" \[${C_SYMBOL}\]>>\[${C_RESET}\] "
    PS1+="\[${C_USER}\]\u\[${C_RESET}\]"
    PS1+="\[${C_SYMBOL}\]#\[${C_RESET}\]"
    PS1+="\[${C_HOST}\]\h\[${C_RESET}\]"
    PS1+="\[${C_SYMBOL}\][\[${C_RESET}\]"
    PS1+="\[${C_IP}\]${ip_addr}\[${C_RESET}\]"
    PS1+="\[${C_SYMBOL}\]]\[${C_RESET}\]\n"
    
    # Line 2: [venv]$ >> branch
    if [ -n "$VIRTUAL_ENV" ]; then
        local venv_name=$(basename "$VIRTUAL_ENV")
        PS1+="\[${C_SYMBOL}\][\[${C_RESET}\]"
        PS1+="\[${C_VENV}\]${venv_name}\[${C_RESET}\]"
        PS1+="\[${C_SYMBOL}\]]\[${C_RESET}\] "
    fi
    
    PS1+="\[${C_SYMBOL}\]\$\[${C_RESET}\] "
    
    if is_git_repo 2>/dev/null; then
        local branch=$(get_git_branch 2>/dev/null)
        PS1+="\[${C_SYMBOL}\]>>\[${C_RESET}\] "
        PS1+="\[${C_BRANCH}\]${branch}\[${C_RESET}\]"
    fi
    
    PS1+="\n"
    
    # Line 3: git user info (only in git repo)
    if is_git_repo 2>/dev/null; then
        local git_name=$(get_git_user_name 2>/dev/null)
        local git_email=$(get_git_user_email 2>/dev/null)
        local git_status=$(get_git_status 2>/dev/null)
        local ahead=$(echo "$git_status" | awk '{print $1}')
        local behind=$(echo "$git_status" | awk '{print $2}')
        
        PS1+="\[${C_GIT_USER}\]${git_name}@${git_email}\[${C_RESET}\] "
        PS1+="\[${C_SYMBOL}\]>>\[${C_RESET}\] "
        
        if [ "$ahead" -gt 0 ]; then
            PS1+="\[${C_GIT_AHEAD}\]↑${ahead}\[${C_RESET}\] "
        fi
        if [ "$behind" -gt 0 ]; then
            PS1+="\[${C_GIT_BEHIND}\]↓${behind}\[${C_RESET}\] "
        fi
        if [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ]; then
            PS1+="\[${C_SYMBOL}\](synced)\[${C_RESET}\]"
        fi
        
        PS1+="\n"
    fi
    
    # Final prompt symbol
    PS1+="\[${C_SYMBOL}\]❯\[${C_RESET}\] "
}

# Use PROMPT_COMMAND instead of command substitution in PS1
PROMPT_COMMAND=set_prompt
