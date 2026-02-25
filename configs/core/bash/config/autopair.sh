#!/bin/bash

# Auto-pairing for shell - provides helper functions for character pairing

# Enable/disable auto-pairing
AUTO_PAIR_ENABLED=true

# Function to insert paired character
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

# Simple setup without complex key bindings
setup_autopair() {
    if [[ "$AUTO_PAIR_ENABLED" == "true" ]]; then
        echo "Auto-pairing enabled"
        echo "Note: For full auto-pairing functionality, consider:"
        echo "  - Using zsh with zsh-autopair plugin"
        echo "  - Using a terminal with built-in auto-pairing"
        echo "  - Using readline-based solutions"
        echo ""
        echo "Current helper functions available:"
        echo "  pair-double()  - inserts \"\""
        echo "  pair-single()  - inserts ''"
        echo "  pair-round()   - inserts ()"
        echo "  pair-square()  - inserts []"
        echo "  pair-curly()   - inserts {}"
    fi
}

# Setup auto-pairing when script is sourced
setup_autopair

# Add aliases for convenience
alias pair-toggle='toggle_autopair'
alias pair-status='show_autopair_status'
alias pair-on='AUTO_PAIR_ENABLED=true; setup_autopair; echo "Auto-pairing enabled"'
alias pair-off='AUTO_PAIR_ENABLED=false; echo "Auto-pairing disabled"'

# Additional helper functions for direct use
pair-double() { echo -n '""'; }
pair-single() { echo -n "''"; }
pair-round() { echo -n "()"; }
pair-square() { echo -n "[]"; }
pair-curly() { echo -n "{}"; }
