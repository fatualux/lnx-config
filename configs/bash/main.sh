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

# Batch source core utilities to reduce file system calls
_source_core_files() {
    local core_dir="$BASH_CONFIG_DIR/core"
    # Only attempt to source if core directory exists
    if [[ -d "$core_dir" ]]; then
        [[ -f "$core_dir/logger.sh" ]] && source "$core_dir/logger.sh"
        [[ -f "$core_dir/spinner.sh" ]] && source "$core_dir/spinner.sh"
        [[ -f "$core_dir/colors.sh" ]] && source "$core_dir/colors.sh"
    else
        # Fallback: try to source from the main lnx-config src directory
        local lnx_src_dir="$HOME/.lnx-config/src"
        if [[ -d "$lnx_src_dir" ]]; then
            [[ -f "$lnx_src_dir/logger.sh" ]] && source "$lnx_src_dir/logger.sh"
            [[ -f "$lnx_src_dir/spinner.sh" ]] && source "$lnx_src_dir/spinner.sh"
            [[ -f "$lnx_src_dir/colors.sh" ]] && source "$lnx_src_dir/colors.sh"
        fi
    fi
}
_source_core_files

#═══════════════════════════════════════════════════════════════════════════════
# 2. CONFIGURATION FILES (env_vars, history, init)
#═══════════════════════════════════════════════════════════════════════════════

# Batch source configuration files
_source_config_files() {
    local config_dir="$BASH_CONFIG_DIR/config"
    for config_file in "$config_dir"/*.sh; do
        [[ -f "$config_file" ]] && source "$config_file"
    done
}
_source_config_files

#═══════════════════════════════════════════════════════════════════════════════
# 3. FUNCTIONS (organized by category) - MUST LOAD BEFORE ALIASES
#═══════════════════════════════════════════════════════════════════════════════

# Batch source function files by category
_source_function_files() {
    local func_dir="$BASH_CONFIG_DIR/functions"
    
    # Source all function categories in one loop to reduce directory scans
    for category in filesystem docker music aliases development; do
        for func_file in "$func_dir/$category"/*.sh; do
            [[ -f "$func_file" ]] && source "$func_file"
        done
    done
}
_source_function_files

#═══════════════════════════════════════════════════════════════════════════════
# 4. ALIASES (general and work-specific) - AFTER FUNCTIONS
#═══════════════════════════════════════════════════════════════════════════════

# Batch source alias files
_source_alias_files() {
    local alias_dir="$BASH_CONFIG_DIR/aliases"
    for alias_file in "$alias_dir"/*.sh; do
        [[ -f "$alias_file" ]] && source "$alias_file"
    done
}
_source_alias_files

#═══════════════════════════════════════════════════════════════════════════════
# 5. INTEGRATIONS (docker, fzf, cd-activate, mc)
#═══════════════════════════════════════════════════════════════════════════════

# Batch source integration files
_source_integration_files() {
    local integration_dir="$BASH_CONFIG_DIR/integrations"
    for integration_file in "$integration_dir"/*.sh; do
        [[ -f "$integration_file" ]] && source "$integration_file"
    done
}
_source_integration_files

#═══════════════════════════════════════════════════════════════════════════════
# 6. COMPLETION
#═══════════════════════════════════════════════════════════════════════════════

# Batch source completion files
_source_completion_files() {
    local completion_dir="$BASH_CONFIG_DIR/completion"
    for completion_file in "$completion_dir"/*.sh; do
        [[ -f "$completion_file" ]] && source "$completion_file"
    done
}
_source_completion_files

# Mark as loaded
export __BASH_CONFIG_LOADED=1

# Optional: Display loaded message (comment out if not desired)
if command -v log_success &> /dev/null; then
    log_success "Bash configuration loaded from $BASH_CONFIG_DIR"
    clear
elif [ -n "$BASH_CONFIG_VERBOSE" ]; then
    echo "✓ Bash configuration loaded successfully"
    clear
fi

fi  # End guard clause
