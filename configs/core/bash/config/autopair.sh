#!/bin/bash

# Auto-pairing for shell - provides practical character pairing solutions

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

# Setup readline bindings for actual auto-pairing
setup_readline_autopair() {
    if [[ "$AUTO_PAIR_ENABLED" == "true" ]]; then
        # Create a temporary file with our readline bindings
        local temp_rc=$(mktemp)
        
        cat > "$temp_rc" << 'EOF'
# Auto-pairing bindings
"\"": "\"\"\C-b"
"'": "''\C-b"
"(": "()\C-b"
"[": "[]\C-b"
"{": "{}\C-b"
EOF
        
        # Apply the bindings
        bind -f "$temp_rc" 2>/dev/null
        rm -f "$temp_rc"
        
        echo "Readline auto-pairing enabled"
        echo "Type: \" ' ( [ { to get paired characters"
    fi
}

# Alternative approach: Use bash's builtin 'bind' with proper syntax
bind_autopair() {
    if [[ "$AUTO_PAIR_ENABLED" == "true" ]]; then
        # Use different approach - bind to control sequences instead of direct characters
        # This avoids the recursion issue
        
        # Create functions that insert paired characters
        insert_double_quotes() {
            READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}\"\"${READLINE_LINE:$READLINE_POINT}"
            READLINE_POINT=$((READLINE_POINT + 1))
        }
        
        insert_single_quotes() {
            READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}''${READLINE_LINE:$READLINE_POINT}"
            READLINE_POINT=$((READLINE_POINT + 1))
        }
        
        insert_parens() {
            READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}()${READLINE_LINE:$READLINE_POINT}"
            READLINE_POINT=$((READLINE_POINT + 1))
        }
        
        insert_brackets() {
            READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}[]${READLINE_LINE:$READLINE_POINT}"
            READLINE_POINT=$((READLINE_POINT + 1))
        }
        
        insert_braces() {
            READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}{}${READLINE_LINE:$READLINE_POINT}"
            READLINE_POINT=$((READLINE_POINT + 1))
        }
        
        # Bind control sequences to these functions
        bind -x '"\C-x\"": insert_double_quotes' 2>/dev/null
        bind -x '"\C-x\'": insert_single_quotes' 2>/dev/null
        bind -x '"\C-x(": insert_parens' 2>/dev/null
        bind -x '"\C-x[": insert_brackets' 2>/dev/null
        bind -x '"\C-x{": insert_braces' 2>/dev/null
        
        echo "Bash readline auto-pairing enabled"
        echo "Use Ctrl+X + character for auto-pairing:"
        echo "  Ctrl+X + \"  -> inserts \"\""
        echo "  Ctrl+X + '  -> inserts ''"
        echo "  Ctrl+X + (  -> inserts ()"
        echo "  Ctrl+X + [  -> inserts []"
        echo "  Ctrl+X + {  -> inserts {}"
    fi
}

# Helper functions for command substitution (still useful for scripts)
pd() { printf '""'; }
ps() { printf "''"; }
pr() { printf '()'; }
pb() { printf '[]'; }
pc() { printf '{}'; }

# Setup auto-pairing when script is sourced
if [[ "$AUTO_PAIR_ENABLED" == "true" ]]; then
    echo "Auto-pairing helper functions loaded"
    echo ""
    echo "Trying to enable readline auto-pairing..."
    bind_autopair
    
    echo ""
    echo "If readline pairing doesn't work, you can use:"
    echo "  echo \$(pd)    -> outputs \"\""
    echo "  echo \$(ps)    -> outputs ''"
    echo "  echo \$(pr)    -> outputs ()"
    echo "  echo \$(pb)    -> outputs []"
    echo "  echo \$(pc)    -> outputs {}"
    echo ""
    echo "Short aliases: pd, ps, pr, pb, pc"
fi
