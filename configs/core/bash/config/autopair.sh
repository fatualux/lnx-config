#!/bin/bash

# Auto-pairing for shell - automatically pairs quotes, brackets, and parentheses

# Enable/disable auto-pairing
AUTO_PAIR_ENABLED=true

# Function to insert paired character (simplified version)
insert_pair() {
    local char="$1"
    
    case "$char" in
        '"') echo -n '""' ;;
        "'") echo -n "''" ;;
        '(') echo -n "()" ;;
        '[') echo -n "[]" ;;
        '{') echo -n "{}" ;;
        *) echo -n "$char" ;;
    esac
}

# Function to toggle auto-pairing
toggle_autopair() {
    if [[ "$AUTO_PAIR_ENABLED" == "true" ]]; then
        AUTO_PAIR_ENABLED=false
        echo "Auto-pairing disabled"
    else
        AUTO_PAIR_ENABLED=true
        echo "Auto-pairing enabled"
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

# Create key bindings using bash builtins (simplified approach)
setup_autopair() {
    if [[ "$AUTO_PAIR_ENABLED" == "true" ]]; then
        # Note: This is a simplified version that works with basic bash
        # For full auto-pairing, consider using zsh with zsh-autopair or a more advanced solution
        
        # Create wrapper functions for easier typing
        pair_dquote() { insert_pair '"'; }
        pair_squote() { insert_pair "'"; }
        pair_paren() { insert_pair '('; }
        pair_bracket() { insert_pair '['; }
        pair_brace() { insert_pair '{'; }
        
        # Bind to convenient key combinations (if supported)
        bind -x '"\C-q"' 2>/dev/null || pair_dquote
        bind -x '"\C-q\'" 2>/dev/null || pair_squote
        bind -x '"\C-p"' 2>/dev/null || pair_paren
        bind -x '"\C-p)"' 2>/dev/null || echo -n ")"
        bind -x '"\C-b"' 2>/dev/null || pair_bracket
        bind -x '"\C-b]"' 2>/dev/null || echo -n "]"
        bind -x '"\C-c"' 2>/dev/null || pair_brace
        bind -x '"\C-c}"' 2>/dev/null || echo -n "}"
        
        echo "Auto-pairing key bindings set up"
        echo "  Ctrl+Q+\"  for double quotes"
        echo "  Ctrl+Q+'  for single quotes"
        echo "  Ctrl+P+(  for parentheses"
        echo "  Ctrl+B+[  for brackets"
        echo "  Ctrl+C+{  for braces"
    fi
}

# Setup auto-pairing when script is sourced
setup_autopair

# Add aliases for convenience
alias pair-toggle='toggle_autopair'
alias pair-status='show_autopair_status'
alias pair-on='AUTO_PAIR_ENABLED=true; setup_autopair; echo "Auto-pairing enabled"'
alias pair-off='AUTO_PAIR_ENABLED=false; echo "Auto-pairing disabled"'

# Additional helper functions
pair-double() { echo -n '""'; }
pair-single() { echo -n "''"; }
pair-round() { echo -n "()"; }
pair-square() { echo -n "[]"; }
pair-curly() { echo -n "{}"; }
