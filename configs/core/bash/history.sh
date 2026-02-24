#!/bin/bash

# History file and size settings
export HISTFILE="$HOME/.bash_history"
export HISTFILESIZE=10000      # total max entries in file (optimized balance)
export HISTSIZE=5000           # entries kept in memory (optimized balance)
export HISTCONTROL=ignorespace:ignoredups:erasedups  # ignore commands starting with space and duplicates
shopt -s histappend              # don't overwrite, always append
export HISTTIMEFORMAT="%F %T "   # timestamp format (YYYY-MM-DD HH:MM)

# Optimized history synchronization
__bash_history_sync() {
    # Only sync if we're in an interactive shell and history file exists
    if [[ $- == *i* && -f "$HISTFILE" ]]; then
        # Simple and efficient: append new entries and read new ones
        history -a
        history -n
    fi
}

# Efficient history cleanup on exit
__bash_history_cleanup() {
    # Only cleanup if history file exists and needs trimming
    if [[ -f "$HISTFILE" ]]; then
        # Append any pending entries first
        history -a
        
        # Only trim if file is significantly larger than HISTFILESIZE
        local line_count
        line_count=$(wc -l < "$HISTFILE" 2>/dev/null || echo 0)
        
        if [[ $line_count -gt $((HISTFILESIZE + 1000)) ]]; then
            # Efficient trimming: keep last HISTFILESIZE lines, remove duplicates
            tail -n "$HISTFILESIZE" "$HISTFILE" | awk '!seen[$0]++' > "${HISTFILE}.tmp" && \
                mv "${HISTFILE}.tmp" "$HISTFILE" 2>/dev/null || \
                rm -f "${HISTFILE}.tmp" 2>/dev/null
        fi
    fi
}

# Safe PROMPT_COMMAND handling
__safe_prompt_command() {
    # Run history sync (lightweight)
    __bash_history_sync
    
    # Run any existing PROMPT_COMMAND if it exists
    if [[ -n "${__ORIGINAL_PROMPT_COMMAND:-}" ]]; then
        eval "$__ORIGINAL_PROMPT_COMMAND"
    fi
}

# Preserve original PROMPT_COMMAND only if not already set
if [[ -z "${__HISTORY_SETUP_COMPLETE:-}" ]]; then
    __ORIGINAL_PROMPT_COMMAND="${PROMPT_COMMAND:-}"
    PROMPT_COMMAND="__safe_prompt_command"
    export __HISTORY_SETUP_COMPLETE=1
fi

# Set up exit trap for cleanup (only once)
if [[ -z "${__HISTORY_TRAP_SET:-}" ]]; then
    trap '__bash_history_cleanup' EXIT
    export __HISTORY_TRAP_SET=1
fi

# Additional history optimizations
shopt -s cmdhist                 # store multi-line commands as single entry
shopt -s lithist                 # store multi-line commands with embedded newlines

# Prevent history from being cleared by common commands
export HISTIGNORE="ls:cd:pwd:exit:clear:history:fg:bg:jobs:disown"

# Enhanced history search bindings (only in interactive shells and not in tests)
if [[ $- == *i* ]] && [[ -z "${BATS_RUN_TMPDIR:-}" ]] && [[ -z "${TEST_TEMP_DIR:-}" ]] && [[ -z "${IN_BATS_TEST:-}" ]]; then
    # Only set up bindings if we're in a real terminal
    if [[ -t 0 ]] && [[ -t 1 ]]; then
        # Arrow keys for history search
        bind '"\e[A": history-search-backward' 2>/dev/null || true
        bind '"\e[B": history-search-forward' 2>/dev/null || true
        bind '"\eOA": history-search-backward' 2>/dev/null || true  # Terminal variant
        bind '"\eOB": history-search-forward' 2>/dev/null || true  # Terminal variant
        
        # Ctrl+P/N for history search (Emacs style)
        bind '"\C-p": history-search-backward' 2>/dev/null || true
        bind '"\C-n": history-search-forward' 2>/dev/null || true
        
        # Alt+P/N for history search (alternative)
        bind '"\ep": history-search-backward' 2>/dev/null || true
        bind '"\en": history-search-forward' 2>/dev/null || true
        
        # PageUp/PageDown for history search
        bind '"\e[5~": history-search-backward' 2>/dev/null || true
        bind '"\e[6~": history-search-forward' 2>/dev/null || true
        
        # Preserve cursor position during history search
        bind "set history-preserve-point on" 2>/dev/null || true
        
        # Enable case-insensitive completion for history search
        bind "set completion-ignore-case on" 2>/dev/null || true
    fi
fi
