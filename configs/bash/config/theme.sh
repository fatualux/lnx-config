#!/bin/bash

# Bash Theme Configuration
# Optimized: Only loads the theme that's actually used

# Set your preferred theme here
# Available: rainbow, template (copy template.sh to create new themes)
BASH_THEME="${BASH_THEME:-rainbow}"

# Get directory of this script
THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../themes" && pwd)"

# Store original PROMPT_COMMAND before theme loads
__ORIGINAL_THEME_PROMPT_COMMAND="$PROMPT_COMMAND"

# Fast theme loading - only check for the specific theme
if [ -f "$THEME_DIR/${BASH_THEME}.sh" ]; then
    source "$THEME_DIR/${BASH_THEME}.sh"
    
    # Preserve history synchronization by chaining PROMPT_COMMANDs
    if [[ -n "$__ORIGINAL_THEME_PROMPT_COMMAND" ]]; then
        PROMPT_COMMAND="__original_theme_prompt_wrapper"
        __original_theme_prompt_wrapper() {
            # Run original command first (history sync)
            eval "$__ORIGINAL_THEME_PROMPT_COMMAND"
            # Then run theme prompt command
            set_prompt
        }
    else
        # No original command, just use theme
        PROMPT_COMMAND=set_prompt
    fi
else
    # Fallback to basic prompt if theme not found
    echo "Warning: Theme '${BASH_THEME}' not found in $THEME_DIR"
    echo "Available themes: $(ls -1 "$THEME_DIR"/*.sh 2>/dev/null | xargs -n1 basename | sed 's/\.sh$//' | tr '\n' ' ')"
    echo "Falling back to basic prompt"
    PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '
fi