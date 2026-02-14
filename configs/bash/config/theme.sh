#!/bin/bash

# Bash Theme Configuration
# Customizable prompt themes with git integration

# Set your preferred theme here
# Available: default, minimal, compact, developer, rainbow
BASH_THEME="${BASH_THEME:-rainbow}"

# Get the directory of this script
THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../themes" && pwd)"

# Source the selected theme
if [ -f "$THEME_DIR/${BASH_THEME}.sh" ]; then
    source "$THEME_DIR/${BASH_THEME}.sh"
else
    # Fallback to basic prompt if theme not found
    echo "Warning: Theme '${BASH_THEME}' not found in $THEME_DIR"
    echo "Available themes: $(ls -1 "$THEME_DIR"/*.sh 2>/dev/null | xargs -n1 basename | sed 's/\.sh$//' | tr '\n' ' ')"
    echo "Falling back to basic prompt"
    PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '
fi