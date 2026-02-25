#!/bin/bash

# Bash Theme Configuration
# Source unified colors with robust fallback handling
if [[ -n "${SCRIPT_DIR:-}" ]] && [[ -f "$SCRIPT_DIR/src/colors.sh" ]]; then
    source "$SCRIPT_DIR/src/colors.sh"
elif [[ -f "${BASH_CONFIG_DIR:-$HOME/.config/bash}/colors.sh" ]]; then
    source "${BASH_CONFIG_DIR:-$HOME/.config/bash}/colors.sh"
elif [[ -f "$HOME/.config/bash/colors.sh" ]]; then
    source "$HOME/.config/bash/colors.sh"
else
    # Fallback color definitions only if unified colors not available
    C_USER='\[\033[1;34m\]'      # Blue
    C_HOST='\[\033[1;32m\]'      # Green  
    C_IP='\[\033[1;35m\]'        # Magenta
    C_PATH='\[\033[1;36m\]'      # Cyan
    C_VENV='\[\033[1;33m\]'      # Yellow
    C_BRANCH='\[\033[1;31m\]'    # Red
    C_AHEAD='\[\033[1;33m\]'     # Yellow (ahead)
    C_BEHIND='\[\033[1;32m\]'    # Green (behind)
    C_COMMIT='\[\033[1;35m\]'    # Magenta (files to commit)
    C_SYMBOL='\[\033[1;37m\]'    # White
    C_RESET='\[\033[0m\]'        # Reset
fi

# Cache IP address to avoid repeated hostname calls
__CACHED_IP_ADDRESS=""
__IP_CACHE_TIMESTAMP=0
__IP_CACHE_TTL=300  # Cache IP for 5 minutes

# Get IP address (cached)
get_ip_address() {
    local current_time
    current_time=$(date +%s)
    if [[ $(( current_time - __IP_CACHE_TIMESTAMP )) -gt $__IP_CACHE_TTL ]]; then
        __CACHED_IP_ADDRESS=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "N/A")
        __IP_CACHE_TIMESTAMP=$current_time
    fi
    echo "$__CACHED_IP_ADDRESS"
}

# Git helper functions
is_git_repo() {
    git rev-parse --git-dir >/dev/null 2>&1
}

get_git_branch() {
    git branch --show-current 2>/dev/null || echo "detached"
}

get_theme_git_status() {
    # Get ahead/behind info
    local ahead=0
    local behind=0

    # Get ahead/behind counts safely
    local count_output
    count_output=$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null || echo "")
    if [[ -n "$count_output" ]]; then
        behind=$(echo "$count_output" | awk '{print $1}')
        ahead=$(echo "$count_output" | awk '{print $2}')
    fi

    # Get commit status
    local status
    status=$(git status --porcelain 2>/dev/null || echo "")

    local staged=0
    local unstaged=0

    if [[ -n "$status" ]]; then
        # staged: lines where first column is one of M A D R C
        staged=$(echo "$status" | grep -c '^[MADRC]' 2>/dev/null)
        # unstaged: lines where second column is one of M A D R C
        unstaged=$(echo "$status" | grep -c '^.[MADRC]' 2>/dev/null)

        # default to 0 if grep produced nothing
        staged=${staged:-0}
        unstaged=${unstaged:-0}
    fi

    # Ensure numeric defaults
    ahead=${ahead:-0}
    behind=${behind:-0}

    # Ensure we output only one line
    echo "$ahead $behind $staged $unstaged"
}

# Main prompt function
set_prompt() {
    # Get IP address with caching
    local ip_addr
    ip_addr=$(get_ip_address)

    # Line 1: user - host - ip_address
    PS1="[ ${C_USER}\\u${C_RESET} ]"
    PS1+=" ${C_SYMBOL}-${C_RESET} "
    PS1+="[ ${C_HOST}\\h${C_RESET} ]"
    PS1+=" ${C_SYMBOL}-${C_RESET} "
    PS1+="[ ${C_IP}${ip_addr}${C_RESET} ]"

    # Line 2: [current_directory] [branch_name: to_pull - to_push] - (.venv_name)
    PS1+="\n"

    # Always show current directory
    PS1+="[ ${C_PATH}$PWD${C_RESET} ]"

    # Git info
    if is_git_repo; then
        local branch
        branch=$(get_git_branch)

        local git_status
        git_status=$(get_theme_git_status)

        # Parse status values
        local ahead behind staged unstaged
        ahead=$(echo "$git_status"  | awk '{print $1}')
        behind=$(echo "$git_status" | awk '{print $2}')
        staged=$(echo "$git_status" | awk '{print $3}')
        unstaged=$(echo "$git_status"| awk '{print $4}')

        # Ensure numeric defaults
        ahead=${ahead:-0}
        behind=${behind:-0}
        staged=${staged:-0}
        unstaged=${unstaged:-0}

        # Calculate files to pull and push
        local files_to_pull=$(( ahead + behind ))
        local files_to_push=$(( staged + unstaged ))

        # Add git info after directory
        PS1+=" ${C_SYMBOL}-${C_RESET} "
        PS1+="[ ${C_BRANCH}${branch}${C_RESET} ]"
        PS1+="${C_SYMBOL} ${C_RESET}"

        # Show files to pull
        if [[ "$ahead" -gt 0 ]]; then
            PS1+="${C_AHEAD}▲${ahead} ${C_RESET}"
        fi
        if [[ "$behind" -gt 0 ]]; then
            PS1+="${C_BEHIND}▼ ${behind} ${C_RESET}"
        fi

        # Show files to push
        if [[ "$files_to_push" -gt 0 ]]; then
            PS1+="${C_COMMIT}▲ ${files_to_push}${C_RESET}"
        fi

        PS1+="${C_SYMBOL}${C_RESET}"
    fi

    # Virtual environment
    if [[ -n "$VIRTUAL_ENV" ]]; then
        if is_git_repo; then
            PS1+=" ${C_SYMBOL}-${C_RESET} "
        fi
        local venv_name
        venv_name=$(basename "$VIRTUAL_ENV")
        PS1+="${C_VENV}(${venv_name})${C_RESET}"
    fi

    # Add prompt symbol
    PS1+="\n${C_SYMBOL} >> ${C_RESET}"
}

# Store original PROMPT_COMMAND before theme loads
__ORIGINAL_THEME_PROMPT_COMMAND="${PROMPT_COMMAND:-}"

# Set up prompt command
if [[ -n "$__ORIGINAL_THEME_PROMPT_COMMAND" ]]; then
    __original_theme_prompt_wrapper() {
        # Run original command first (history sync, etc.)
        eval "$__ORIGINAL_THEME_PROMPT_COMMAND"
        # Then run theme prompt command
        set_prompt
    }
    PROMPT_COMMAND="__original_theme_prompt_wrapper"
else
    # No original command, just use theme
    PROMPT_COMMAND=set_prompt
fi