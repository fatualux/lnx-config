#!/bin/bash
# ============================================================================
# Bash Completion System - Core Utilities
# ============================================================================
# Provides unified utilities for all completion functions
# Optimized for performance and maintainability

# Global completion configuration
declare -A _COMPLETION_CONFIG=(
    ["cache_dir"]="${XDG_CACHE_HOME:-$HOME/.cache}/bash-completion"
    ["cache_ttl"]=86400  # 24 hours default
    ["debug_mode"]=0
    ["lazy_load"]=1
    ["max_cache_size"]=1000
    ["performance_tracking"]=1
)

# Performance tracking
declare -A _COMPLETION_METRICS=(
    ["cache_hits"]=0
    ["cache_misses"]=0
    ["completion_calls"]=0
    ["total_time"]=0
)

# Initialize completion system
_completion_init() {
    local cache_dir="${_COMPLETION_CONFIG[cache_dir]}"
    
    # Create cache directory
    mkdir -p "$cache_dir" 2>/dev/null || {
        # Fallback to temp directory
        cache_dir="${TMPDIR:-/tmp}/bash-completion-$$"
        mkdir -p "$cache_dir" 2>/dev/null || true
        _COMPLETION_CONFIG[cache_dir]="$cache_dir"
    }
    
    # Clean old cache files
    _completion_cache_cleanup
}

# Unified cache management
_completion_cache_get() {
    local key="$1"
    local cache_file="${_COMPLETION_CONFIG[cache_dir]}/${key}.cache"
    local cache_ttl="${_COMPLETION_CONFIG[cache_ttl]}"
    
    if [[ ! -f "$cache_file" ]]; then
        ((_COMPLETION_METRICS[cache_misses]++))
        return 1
    fi
    
    local cache_age=$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0)))
    
    if (( cache_age >= cache_ttl )); then
        rm -f "$cache_file" 2>/dev/null
        ((_COMPLETION_METRICS[cache_misses]++))
        return 1
    fi
    
    ((_COMPLETION_METRICS[cache_hits]++))
    cat "$cache_file" 2>/dev/null
    return 0
}

_completion_cache_set() {
    local key="$1"
    local data="$2"
    local cache_file="${_COMPLETION_CONFIG[cache_dir]}/${key}.cache"
    
    echo "$data" > "$cache_file" 2>/dev/null
    _completion_cache_size_check
}

_completion_cache_size_check() {
    local cache_dir="${_COMPLETION_CONFIG[cache_dir]}"
    local max_size="${_COMPLETION_CONFIG[max_cache_size]}"
    
    if [[ -d "$cache_dir" ]]; then
        local cache_count=$(find "$cache_dir" -name "*.cache" | wc -l)
        if (( cache_count > max_size )); then
            # Remove oldest cache files
            find "$cache_dir" -name "*.cache" -printf '%T@ %p\n' | \
                sort -n | head -n $((cache_count - max_size)) | \
                cut -d' ' -f2- | xargs rm -f 2>/dev/null
        fi
    fi
}

_completion_cache_cleanup() {
    local cache_dir="${_COMPLETION_CONFIG[cache_dir]}"
    local cache_ttl="${_COMPLETION_CONFIG[cache_ttl]}"
    
    if [[ -d "$cache_dir" ]]; then
        # Remove expired cache files
        find "$cache_dir" -name "*.cache" -type f -mmin "+$((cache_ttl / 60))" \
            -delete 2>/dev/null
    fi
}

# Performance tracking
_completion_track_start() {
    if [[ "${_COMPLETION_CONFIG[performance_tracking]}" == "1" ]]; then
        _COMPLETION_START_TIME=$(date +%s%N)
    fi
}

_completion_track_end() {
    if [[ "${_COMPLETION_CONFIG[performance_tracking]}" == "1" && -n "${_COMPLETION_START_TIME:-}" ]]; then
        local end_time=$(date +%s%N)
        local duration=$(( (end_time - _COMPLETION_START_TIME) / 1000000 )) # Convert to ms
        ((_COMPLETION_METRICS[total_time] += duration))
        ((_COMPLETION_METRICS[completion_calls]++))
        unset _COMPLETION_START_TIME
    fi
}

_completion_get_metrics() {
    printf "Cache Hits: %d\n" "${_COMPLETION_METRICS[cache_hits]}"
    printf "Cache Misses: %d\n" "${_COMPLETION_METRICS[cache_misses]}"
    printf "Completion Calls: %d\n" "${_COMPLETION_METRICS[completion_calls]}"
    printf "Total Time: %d ms\n" "${_COMPLETION_METRICS[total_time]}"
    if (( ${_COMPLETION_METRICS[completion_calls]} > 0 )); then
        local avg_time=$(( ${_COMPLETION_METRICS[total_time]} / ${_COMPLETION_METRICS[completion_calls]} ))
        printf "Average Time: %d ms\n" "$avg_time"
    fi
}

# Common completion utilities
_completion_filter_options() {
    local input="$1"
    local prefix="$2"
    
    # Extract options from help/man pages
    echo "$input" | grep -oE '(^|[[:space:]])'"$prefix"'?[a-zA-Z0-9][a-zA-Z0-9_-]*' |
        sed 's/^[[:space:]]*//; s/[[:space:]]*$//' |
        sort -u
}

_completion_complete_files() {
    local cur="$1"
    local -a dirs files replies
    local IFS=$'\n'

    dirs=( $(compgen -A directory -- "$cur" 2>/dev/null) )
    files=( $(compgen -A file -- "$cur" 2>/dev/null) )
    replies=( "${dirs[@]}" "${files[@]}" )

    if (( ${#replies[@]} == 0 )); then
        COMPREPLY=()
        return
    fi

    if (( ${#dirs[@]} > 0 )); then
        compopt -o nospace 2>/dev/null
        for i in "${!replies[@]}"; do
            if [[ -d "${replies[i]}" && "${replies[i]}" != */ ]]; then
                replies[i]="${replies[i]}/"
            fi
        done
    fi

    COMPREPLY=( "${replies[@]}" )
}

_completion_complete_with_cache() {
    local cmd="$1"
    local cache_key="$2"
    local extraction_func="$3"
    local cur="$4"
    
    _completion_track_start
    
    local opts
    if ! opts=$(_completion_cache_get "$cache_key"); then
        opts=$($extraction_func "$cmd")
        _completion_cache_set "$cache_key" "$opts"
    fi
    
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    
    _completion_track_end
}

# Lazy loading system
_completion_lazy_load() {
    local completion_name="$1"
    local completion_file="$2"
    local load_flag="_COMPLETION_${completion_name^^}_LOADED"
    
    if [[ -z "${!load_flag}" ]]; then
        if [[ -f "$completion_file" ]]; then
            source "$completion_file"
            declare -g "$load_flag=1"
            return 0
        fi
    fi
    return 1
}

# Initialize the completion system
_completion_init
