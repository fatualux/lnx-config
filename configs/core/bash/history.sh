#!/bin/bash

# History file and size settings
export HISTFILE="$HOME/.bash_history"
export HISTFILESIZE=50000       # total max entries in file (reduced for performance)
export HISTSIZE=10000           # entries kept in memory (reduced for performance)
export HISTCONTROL=ignorespace:ignoredups:erasedups  # ignore commands starting with space and duplicates
shopt -s histappend              # don't overwrite, always append
export HISTTIMEFORMAT="%F %T "   # timestamp format (YYYY-MM-DD HH:MM)

# Safe history synchronization without clearing memory
__bash_history_sync() {
    # Only sync if we're in an interactive shell and history file exists
    if [[ $- == *i* && -f "$HISTFILE" ]]; then
        # Append new entries from this session to file
        history -a
        
        # Read new entries from other sessions (without clearing current memory)
        # This preserves current session history while adding new entries
        local temp_history_file=$(mktemp)
        if [[ -f "$HISTFILE" ]]; then
            # Get current history count
            local current_count=$(history | wc -l)
            
            # Read only new entries from file (skip current_count lines)
            tail -n "+$((current_count + 1))" "$HISTFILE" 2>/dev/null > "$temp_history_file"
            
            # If there are new entries, add them to memory
            if [[ -s "$temp_history_file" ]]; then
                while IFS= read -r line; do
                    if [[ -n "$line" ]]; then
                        if [[ "$line" =~ ^#[0-9]+$ ]]; then
                            continue
                        fi
                        history -s "$line"
                    fi
                done < "$temp_history_file"
            fi
        fi
        rm -f "$temp_history_file"
    fi
}

# Optimized history cleanup on exit (only if needed)
__bash_history_cleanup() {
    # Only cleanup if history file exists and is larger than HISTFILESIZE
    local history_count=0
    if [[ -f "$HISTFILE" ]]; then
        history_count=$(wc -l < "$HISTFILE" 2>/dev/null || echo 0)
    fi
    
    # Use integer comparison
    if [[ $history_count -gt ${HISTFILESIZE} ]]; then
        # Append any pending entries first
        history -a
        
        # Efficient deduplication and trimming using awk
        awk '!/^#[0-9]+$/{ if (!seen[$0]++) print $0 }' "$HISTFILE" | tail -n "$HISTFILESIZE" > "${HISTFILE}.tmp" 2>/dev/null && \
            mv "${HISTFILE}.tmp" "$HISTFILE" 2>/dev/null || \
            rm -f "${HISTFILE}.tmp" 2>/dev/null
    else
        # Just append pending entries if no cleanup needed
        history -a
    fi
}

# Safer PROMPT_COMMAND handling
__safe_prompt_command() {
    # Run history sync first
    __bash_history_sync
    
    # Run any existing PROMPT_COMMAND
    if [[ -n "$__ORIGINAL_PROMPT_COMMAND" ]]; then
        eval "$__ORIGINAL_PROMPT_COMMAND"
    fi
}

# Preserve original PROMPT_COMMAND
__ORIGINAL_PROMPT_COMMAND="$PROMPT_COMMAND"

# Set new PROMPT_COMMAND
PROMPT_COMMAND="__safe_prompt_command"

# Set up exit trap for cleanup
trap '__bash_history_cleanup' EXIT

# Additional history optimizations
shopt -s cmdhist                 # store multi-line commands as single entry
shopt -s lithist                 # store multi-line commands with embedded newlines

# Prevent history from being cleared by common commands
# Add commands that should not be saved to history (optional)
export HISTIGNORE="ls:cd:pwd:exit:clear:history"

