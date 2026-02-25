#!/bin/bash

# Auto-pairing for shell - automatically pairs quotes, brackets, and parentheses

# Enable/disable auto-pairing
AUTO_PAIR_ENABLED=true

# Characters to pair
declare -A PAIRS=(
    ['"']='["']
    ["'"]="'"
    ['(']=')'
    ['[']=']'
    ['{']='}'
)

# Function to insert paired character
insert_pair() {
    local char="$1"
    local pair="${PAIRS[$char]}"
    
    if [[ -n "$pair" ]]; then
        echo -n "$char$pair"
        # Move cursor back one position to be between the pair
        echo -ne "\b"
    else
        echo -n "$char"
    fi
}

# Function to handle backspace - removes paired character if appropriate
handle_backspace() {
    local last_char="$(echo -n "$READLINE_LINE" | tail -c 1)"
    local pair=""
    
    # Find matching pair for the last character
    for key in "${!PAIRS[@]}"; do
        if [[ "$last_char" == "$key" ]]; then
            pair="${PAIRS[$key]}"
            break
        fi
    done
    
    if [[ -n "$pair" ]]; then
        # Remove both characters of the pair
        READLINE_LINE="${READLINE_LINE%?}"
        READLINE_POINT=$((READLINE_POINT - 1))
    else
        # Normal backspace
        READLINE_LINE="${READLINE_LINE%?}"
        READLINE_POINT=$((READLINE_POINT - 1))
    fi
}

# Function to setup auto-pairing in readline
setup_autopair() {
    if [[ "$AUTO_PAIR_ENABLED" == "true" ]]; then
        # Bind bracket and quote keys
        bind -x '"\C-x\""' insert_pair '"'
        bind -x "\"'" insert_pair "'"
        bind -x '"\C-x("' insert_pair '('
        bind -x '"\C-x)"' insert_pair ')'
        bind -x '"\C-x["' insert_pair '['
        bind -x '"\C-x]"' insert_pair ']'
        bind -x '"\C-x{"' insert_pair '{'
        bind -x '"\C-x}"' insert_pair '}'
        
        # Enhanced backspace handling
        bind -x '"\C-h"' handle_backspace
    fi
}

# Function to toggle auto-pairing
toggle_autopair() {
    if [[ "$AUTO_PAIR_ENABLED" == "true" ]]; then
        AUTO_PAIR_ENABLED=false
        echo "Auto-pairing disabled"
    else
        AUTO_PAIR_ENABLED=true
        echo "Auto-pairing enabled"
        setup_autopair
    fi
}

# Function to show auto-pair status
show_autopair_status() {
    if [[ "$AUTO_PAIR_ENABLED" == "true" ]]; then
        echo "Auto-pairing: ENABLED"
    else
        echo "Auto-pairing: DISABLED"
    fi
}

# Setup auto-pairing when script is sourced
setup_autopair

# Add aliases for convenience
alias pair-toggle='toggle_autopair'
alias pair-status='show_autopair_status'
alias pair-on='AUTO_PAIR_ENABLED=true; setup_autopair; echo "Auto-pairing enabled"'
alias pair-off='AUTO_PAIR_ENABLED=false; echo "Auto-pairing disabled"'
