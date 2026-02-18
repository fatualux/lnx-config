#!/bin/bash
# Rainbow Theme - Every element in different mid-range colors with ASCII symbols

# Color definitions (mid-range - not too dark, not too bright)
C_DATE='\[\033[38;5;117m\]'     # Sky blue
C_TIME='\[\033[38;5;150m\]'     # Light green
C_USER='\[\033[38;5;215m\]'     # Peach
C_HOST='\[\033[38;5;114m\]'     # Light lime
C_IP='\[\033[38;5;183m\]'       # Lavender
C_PATH='\[\033[38;5;222m\]'     # Light gold
C_VENV='\[\033[38;5;186m\]'     # Tan
C_BRANCH='\[\033[38;5;153m\]'   # Light cyan
C_DETACHED='\[\033[38;5;216m\]' # Light orange
C_GIT_USER='\[\033[38;5;159m\]' # Pale cyan
C_GIT_EMAIL='\[\033[38;5;156m\]' # Light green
C_AHEAD='\[\033[38;5;120m\]'    # Mint green
C_BEHIND='\[\033[38;5;210m\]'   # Coral
C_SYNCED='\[\033[38;5;121m\]'   # Aqua
C_STAGED='\[\033[38;5;227m\]'   # Light yellow
C_UNSTAGED='\[\033[38;5;216m\]' # Light orange
C_UNTRACKED='\[\033[38;5;147m\]' # Light blue
C_SYMBOL1='\[\033[38;5;111m\]'  # Medium blue
C_SYMBOL2='\[\033[38;5;78m\]'   # Green
C_PROMPT='\[\033[38;5;228m\]'   # Light yellow
C_RESET='\[\033[0m\]'

# Cache IP address to avoid repeated hostname calls
__CACHED_IP_ADDRESS=""
__IP_CACHE_TIMESTAMP=0
__IP_CACHE_TTL=300  # Cache IP for 5 minutes

# Get IP address (cached)
get_ip_address() {
    local current_time=$(date +%s)
    if [[ $((current_time - __IP_CACHE_TIMESTAMP)) -gt $__IP_CACHE_TTL ]]; then
        __CACHED_IP_ADDRESS=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "N/A")
        __IP_CACHE_TIMESTAMP=$current_time
    fi
    echo "$__CACHED_IP_ADDRESS"
}

# Build the prompt (optimized to reduce external calls)
set_prompt() {
    # Cache date and time to avoid multiple date calls
    local current_time=$(date '+%y/%m/%d %H:%M:%S')
    local date_str="${current_time:0:8}"
    local time_str="${current_time:9:8}"
    local ip_addr=$(get_ip_address)
    
    # Line 1: ┌─[ YY/MM/DD ]─[ HH:MM:SS ]─[ USER @ HOST ]─[ IP ]
    PS1="\n${C_SYMBOL1}┌─${C_RESET} "
    PS1+="${C_DATE}${date_str}${C_RESET} "
    PS1+="${C_SYMBOL1}─${C_RESET} "
    PS1+="${C_TIME}${time_str}${C_RESET} "
    PS1+="${C_SYMBOL1}─${C_RESET} "
    PS1+="${C_USER}\u${C_RESET} "
    PS1+="${C_SYMBOL2}@${C_RESET} "
    PS1+="${C_HOST}\h${C_RESET} "
    PS1+="${C_SYMBOL1}─${C_RESET} "
    PS1+="${C_IP}${ip_addr}${C_RESET} "
    PS1+="${C_SYMBOL1}${C_RESET}\n"
    
    # Line 2: ├─[ PATH ][ VENV ]
    PS1+="${C_SYMBOL1}├─${C_RESET} "
    PS1+="${C_PATH}\w${C_RESET} "
    PS1+="${C_SYMBOL1}${C_RESET}"
    
    if [ -n "$VIRTUAL_ENV" ]; then
        local venv_name=$(basename "$VIRTUAL_ENV")
        PS1+=" ${C_SYMBOL2}<${C_RESET}"
        PS1+="${C_VENV}${venv_name}${C_RESET}"
        PS1+="${C_SYMBOL2}>${C_RESET}"
    fi
    
    PS1+="\n"
    
    # Line 3 (if in git): ├─[ GIT: USER ]─[ BRANCH ]─[ STATUS ]
    if is_git_repo 2>/dev/null; then
        # Get all git info in one batch to minimize git calls
        local git_name=$(get_git_user_name 2>/dev/null)
        local branch=$(get_git_branch 2>/dev/null)
        local git_status=$(get_git_status 2>/dev/null)
        local working_status=$(get_git_working_status 2>/dev/null)
        
        # Parse status values efficiently
        local ahead=$(echo "$git_status" | awk '{print $1}')
        local behind=$(echo "$git_status" | awk '{print $2}')
        local staged=$(echo "$working_status" | awk '{print $1}')
        local unstaged=$(echo "$working_status" | awk '{print $2}')
        local untracked=$(echo "$working_status" | awk '{print $3}')
        
        PS1+="${C_SYMBOL1}├─${C_RESET} "
        PS1+="${C_SYMBOL2}GIT:${C_RESET} "
        PS1+="${C_GIT_USER}${git_name}${C_RESET} "
        PS1+="${C_SYMBOL1}─${C_RESET} "
        
        if is_git_detached 2>/dev/null; then
            PS1+="${C_DETACHED}${branch}${C_RESET} "
        else
            PS1+="${C_BRANCH}${branch}${C_RESET} "
        fi
        
        PS1+="${C_SYMBOL1}─${C_RESET} "
        
        # Show remote sync status
        if [ "$ahead" -gt 0 ]; then
            PS1+="${C_AHEAD}↑${ahead}${C_RESET} "
        fi
        if [ "$behind" -gt 0 ]; then
            PS1+="${C_BEHIND}↓${behind}${C_RESET} "
        fi
        if [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ]; then
            PS1+="${C_SYNCED}✓ remote${C_RESET} "
        fi
        
        # Show working directory status
        if [ "$staged" -gt 0 ]; then
            PS1+="${C_STAGED}●${staged}${C_RESET} "
        fi
        if [ "$unstaged" -gt 0 ]; then
            PS1+="${C_UNSTAGED}✚${unstaged}${C_RESET} "
        fi
        if [ "$untracked" -gt 0 ]; then
            PS1+="${C_UNTRACKED}…${untracked}${C_RESET} "
        fi
        if [ "$staged" -eq 0 ] && [ "$unstaged" -eq 0 ] && [ "$untracked" -eq 0 ]; then
            PS1+="${C_SYNCED}✓ clean${C_RESET}"
        fi
        
        PS1+="${C_SYMBOL1} ${C_RESET}\n"
    fi
    
    # Final line: └─>
    PS1+="${C_SYMBOL1}└─${C_RESET}"
    PS1+="${C_PROMPT}>${C_RESET} "
}

PROMPT_COMMAND=set_prompt
