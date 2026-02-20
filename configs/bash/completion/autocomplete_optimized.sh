#!/bin/bash
# ============================================================================
# Optimized Bash Completion System - Main Loader
# ============================================================================
# Features:
#   - Lazy loading of completion modules
#   - Unified caching and performance tracking
#   - Modular architecture
#   - Smart resource management

# Prevent multiple loading
if [[ -n "$_BASH_COMPLETION_SYSTEM_LOADED" ]]; then
    return 0
fi
_BASH_COMPLETION_SYSTEM_LOADED=1

# Source core utilities
if [[ -f "${BASH_CONFIG_DIR:-$HOME/.config/bash}/completion/core/completion_utils.sh" ]]; then
    source "${BASH_CONFIG_DIR:-$HOME/.config/bash}/completion/core/completion_utils.sh"
else
    # Fallback minimal implementation
    return 0
fi

# ============================================================================
# Completion Module Registry
# ============================================================================

declare -A _COMPLETION_MODULES=(
    ["git"]="completions/git.sh"
    ["docker"]="completions/docker.sh"
    ["npm"]="completions/npm.sh"
    ["ssh"]="completions/ssh.sh"
    ["systemd"]="completions/systemd.sh"
)

declare -A _COMPLETION_PATTERNS=(
    ["git"]="git.*"
    ["docker"]="docker|docker-compose"
    ["npm"]="npm|yarn|pnpm"
    ["ssh"]="ssh|scp|sftp"
    ["systemd"]="systemctl|journalctl|systemd-*"
)

# ============================================================================
# Smart Universal Completion
# ============================================================================

_smart_universal_complete() {
    local cur prev cmd
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    cmd="${COMP_WORDS[0]}"
    
    _completion_track_start
    
    # Try to load appropriate completion module
    local module_loaded=0
    for module_name in "${!_COMPLETION_MODULES[@]}"; do
        local pattern="${_COMPLETION_PATTERNS[$module_name]}"
        if [[ "$cmd" =~ $pattern ]]; then
            local module_file="${_COMPLETION_MODULES[$module_name]}"
            local full_path="${BASH_CONFIG_DIR:-$HOME/.config/bash}/completion/$module_file"
            
            if _completion_lazy_load "$module_name" "$full_path"; then
                # Call the module's completion function if it exists
                local completion_func="_${module_name}_complete"
                if declare -F "$completion_func" >/dev/null; then
                    "$completion_func"
                    module_loaded=1
                    break
                fi
            fi
        fi
    done
    
    # Fallback to basic completion if no module loaded
    if (( module_loaded == 0 )); then
        _smart_basic_complete
    fi
    
    _completion_track_end
}

_smart_basic_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local cmd="${COMP_WORDS[0]}"
    
    # Option completion for commands starting with -
    if [[ "$cur" == -* ]]; then
        _completion_complete_with_cache "$cmd" "${cmd}_opts" "_extract_command_options" "$cur"
        return
    fi
    
    # File/directory completion
    _completion_complete_files "$cur"
}

_extract_command_options() {
    local cmd="$1"
    local cache_key="${cmd}_help"
    
    if ! _completion_cache_get "$cache_key"; then
        local help_output
        help_output=$(
            {
                "$cmd" --help 2>/dev/null
                "$cmd" -h 2>/dev/null
                "$cmd" -? 2>/dev/null
                man "$cmd" 2>/dev/null || true
            } 2>/dev/null
        )
        
        local opts
        opts=$(_completion_filter_options "$help_output" "--?")
        echo "$opts" | _completion_cache_set "$cache_key"
    fi
}

# ============================================================================
# Completion Registration
# ============================================================================

_register_completions() {
    # Register universal completion for all commands
    complete -o default -o bashdefault -F _smart_universal_complete -D
    
    # Register specific completions for common commands
    local common_commands=(
        "git" "docker" "docker-compose" "npm" "yarn" "pnpm"
        "ssh" "scp" "sftp" "systemctl" "journalctl"
    )
    
    for cmd in "${common_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            complete -o default -o bashdefault -F _smart_universal_complete "$cmd"
        fi
    done
}

# ============================================================================
# Performance and Debug Commands
# ============================================================================

_completion_stats() {
    echo "=== Bash Completion Statistics ==="
    _completion_get_metrics
    echo "Cache Directory: ${_COMPLETION_CONFIG[cache_dir]}"
    echo "Cache TTL: ${_COMPLETION_CONFIG[cache_ttl]} seconds"
    echo "Lazy Loading: ${_COMPLETION_CONFIG[lazy_load]}"
}

_completion_debug() {
    local mode="${1:-toggle}"
    case "$mode" in
        "on"|"1")
            _COMPLETION_CONFIG[debug_mode]=1
            echo "Completion debug mode enabled"
            ;;
        "off"|"0")
            _COMPLETION_CONFIG[debug_mode]=0
            echo "Completion debug mode disabled"
            ;;
        "toggle")
            if (( _COMPLETION_CONFIG[debug_mode] == 1 )); then
                _completion_debug off
            else
                _completion_debug on
            fi
            ;;
        *)
            echo "Usage: completion-debug [on|off|toggle]"
            ;;
    esac
}

_completion_clear_cache() {
    local cache_dir="${_COMPLETION_CONFIG[cache_dir]}"
    if [[ -d "$cache_dir" ]]; then
        rm -rf "$cache_dir"/*.cache 2>/dev/null
        echo "Completion cache cleared"
    fi
    _completion_init  # Reinitialize
}

# Register convenience commands
alias completion-stats='_completion_stats'
alias completion-debug='_completion_debug'
alias completion-clear='_completion_clear_cache'

# ============================================================================
# Initialize System
# ============================================================================

# Only register completions in interactive mode
if [[ $- == *i* ]]; then
    _register_completions
    
    # Show performance summary if debug mode is enabled
    if (( _COMPLETION_CONFIG[debug_mode] == 1 )); then
        echo "Bash completion system loaded (debug mode)"
    fi
fi
