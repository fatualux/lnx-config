#!/bin/bash
# Main configuration loader for bash
# This file sources all configuration files from organized directories
# Location: ~/.config/bash/main.sh

# Get the directory where this script is located
BASH_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Only skip full re-sourcing if already loaded in parent shell
# But always source functions for subshells
if [[ -n "$__BASH_CONFIG_LOADED" ]] && [[ "$BASH_SUBSHELL" -eq 0 ]]; then
    : # Already loaded, skip re-sourcing
else

#═══════════════════════════════════════════════════════════════════════════════
# 1. CORE UTILITIES (logger, spinner, colors)
#═══════════════════════════════════════════════════════════════════════════════

# Source logger (with fallback protection)
if [[ -z "$__LOGGER_SOURCED" ]]; then
    if [ -f "$BASH_CONFIG_DIR/core/logger.sh" ]; then
        source "$BASH_CONFIG_DIR/core/logger.sh"
    fi
fi

# Source spinner utilities
if [[ -z "$__SPINNER_SOURCED" ]]; then
    if [ -f "$BASH_CONFIG_DIR/core/spinner.sh" ]; then
        source "$BASH_CONFIG_DIR/core/spinner.sh"
    fi
fi

# Source color definitions
if [ -f "$BASH_CONFIG_DIR/core/colors.sh" ]; then
    source "$BASH_CONFIG_DIR/core/colors.sh"
fi

#═══════════════════════════════════════════════════════════════════════════════
# 2. CONFIGURATION FILES (env_vars, history, init)
#═══════════════════════════════════════════════════════════════════════════════

for config_file in "$BASH_CONFIG_DIR/config"/*.sh; do
    if [ -f "$config_file" ]; then
        source "$config_file"
    fi
done

#═══════════════════════════════════════════════════════════════════════════════
# 3. FUNCTIONS (organized by category) - MUST LOAD BEFORE ALIASES
#═══════════════════════════════════════════════════════════════════════════════

# Source filesystem functions
for func_file in "$BASH_CONFIG_DIR/functions/filesystem"/*.sh; do
    if [ -f "$func_file" ]; then
        source "$func_file"
    fi
done

# Source Docker functions
for func_file in "$BASH_CONFIG_DIR/functions/docker"/*.sh; do
    if [ -f "$func_file" ]; then
        source "$func_file"
    fi
done

# Source music player functions
for func_file in "$BASH_CONFIG_DIR/functions/music"/*.sh; do
    if [ -f "$func_file" ]; then
        source "$func_file"
    fi
done

# Source alias utility functions
for func_file in "$BASH_CONFIG_DIR/functions/aliases"/*.sh; do
    if [ -f "$func_file" ]; then
        source "$func_file"
    fi
done

# Source development functions
for func_file in "$BASH_CONFIG_DIR/functions/development"/*.sh; do
    if [ -f "$func_file" ]; then
        source "$func_file"
    fi
done

#═══════════════════════════════════════════════════════════════════════════════
# 4. ALIASES (general and work-specific) - AFTER FUNCTIONS
#═══════════════════════════════════════════════════════════════════════════════

for alias_file in "$BASH_CONFIG_DIR/aliases"/*.sh; do
    if [ -f "$alias_file" ]; then
        source "$alias_file"
    fi
done

#═══════════════════════════════════════════════════════════════════════════════
# 5. INTEGRATIONS (docker, fzf, cd-activate, mc)
#═══════════════════════════════════════════════════════════════════════════════

for integration_file in "$BASH_CONFIG_DIR/integrations"/*.sh; do
    if [ -f "$integration_file" ]; then
        source "$integration_file"
    fi
done

#═══════════════════════════════════════════════════════════════════════════════
# 6. COMPLETION
#═══════════════════════════════════════════════════════════════════════════════

for completion_file in "$BASH_CONFIG_DIR/completion"/*.sh; do
    if [ -f "$completion_file" ]; then
        source "$completion_file"
    fi
done

# Mark as loaded
export __BASH_CONFIG_LOADED=1

# Optional: Display loaded message (comment out if not desired)
if command -v log_success &> /dev/null; then
    log_success "Bash configuration loaded from $BASH_CONFIG_DIR"; sleep 0.5 && clear
elif [ -n "$BASH_CONFIG_VERBOSE" ]; then
    echo "✓ Bash configuration loaded successfully"; sleep 0.5 && clear
fi

fi  # End guard clause
