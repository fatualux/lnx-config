#!/bin/bash

# Auto-pairing for shell - provides helper functions for character pairing

# Enable/disable auto-pairing
AUTO_PAIR_ENABLED=true

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

# Add aliases for convenience
alias pair-toggle='toggle_autopair'
alias pair-status='show_autopair_status'
alias pair-on='AUTO_PAIR_ENABLED=true; echo "Auto-pairing enabled"'
alias pair-off='AUTO_PAIR_ENABLED=false; echo "Auto-pairing disabled"'

# Practical helper functions that work with bash
# These create paired characters that you can copy/paste or use in scripts
pair-double() { echo '""'; }
pair-single() { echo "''"; }
pair-round() { echo '()'; }
pair-square() { echo '[]'; }
pair-curly() { echo '{}'; }

# More practical approach: create functions that output paired characters
# and can be used with command substitution
pd() { printf '""'; }
ps() { printf "''"; }
pr() { printf '()'; }
pb() { printf '[]'; }
pc() { printf '{}'; }

# Create wrapper functions that can be used with $(command) syntax
# Example: echo $(pd) will output ""
quote-double() { printf '""'; }
quote-single() { printf "''"; }
bracket-round() { printf '()'; }
bracket-square() { printf '[]'; }
bracket-curly() { printf '{}'; }

# Setup message
if [[ "$AUTO_PAIR_ENABLED" == "true" ]]; then
    echo "Auto-pairing helper functions loaded"
    echo "Usage examples:"
    echo "  echo \$(pd)    -> outputs \"\""
    echo "  echo \$(ps)    -> outputs ''"
    echo "  echo \$(pr)    -> outputs ()"
    echo "  echo \$(pb)    -> outputs []"
    echo "  echo \$(pc)    -> outputs {}"
    echo ""
    echo "Short aliases: pd, ps, pr, pb, pc"
    echo "Long aliases: quote-double, quote-single, bracket-round, bracket-square, bracket-curly"
fi
