#!/bin/bash
# ============================================================================
# Optimized Bash Completion System - Legacy Compatibility Wrapper
# ============================================================================
# This file provides backward compatibility while loading the optimized system
# 
# Features:
#   - Backward compatibility with existing setup
#   - Automatic migration to optimized system
#   - Performance monitoring and metrics
#   - Graceful fallback if optimized system unavailable

# Load configuration first
if [[ -f "${BASH_CONFIG_DIR:-$HOME/.config/bash}/completion/config.sh" ]]; then
    source "${BASH_CONFIG_DIR:-$HOME/.config/bash}/completion/config.sh"
fi

# Try to load optimized system
if [[ -f "${BASH_CONFIG_DIR:-$HOME/.config/bash}/completion/autocomplete_optimized.sh" ]]; then
    source "${BASH_CONFIG_DIR:-$HOME/.config/bash}/completion/autocomplete_optimized.sh"
    return 0
fi

# Fallback to original implementation if optimized system not available
if [[ -z "$_BASH_SMART_COMPLETE_LOADED" ]]; then
    _BASH_SMART_COMPLETE_LOADED=1

    # Only initialize cache directory if needed
    _smart_cache_dir="${COMPLETION_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/bash-smart-complete}"
    _smart_cache_ttl="${COMPLETION_CACHE_TTL:-86400}"

    # ========================================================================
    # Option Extraction with Caching
    # ========================================================================
    _smart_extract_opts() {
        local cmd="$1"
        local cache="${_smart_cache_dir}/${cmd}.opts"

        # Return cached options if valid
        if [[ -f "$cache" ]]; then
            local cache_age=$(($(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0)))
            if (( cache_age < _smart_cache_ttl )); then
                cat "$cache"
                return 0
            fi
        fi

        # Create cache dir if needed
        mkdir -p "$_smart_cache_dir" 2>/dev/null

        # Extract options from multiple sources
        local opts
        opts=$(
            {
                "$cmd" --help 2>/dev/null
                "$cmd" -h 2>/dev/null
                "$cmd" -? 2>/dev/null
                man "$cmd" 2>/dev/null || true
            } | grep -oE '(^|[[:space:]])--?[a-zA-Z0-9][a-zA-Z0-9_-]*' |
            sed 's/^[[:space:]]*//; s/[[:space:]]*$//' |
            sort -u
        )

        # Cache and return
        echo "$opts" > "$cache" 2>/dev/null
        echo "$opts"
    }

    # ========================================================================
    # Git Smart Completion
    # ========================================================================
    _smart_git_complete() {
        if [[ -z "${COMP_CWORD+x}" || ${COMP_CWORD:-0} -lt 0 || ${#COMP_WORDS[@]} -eq 0 || ${COMP_CWORD:-0} -ge ${#COMP_WORDS[@]} ]]; then
            COMPREPLY=()
            return 0
        fi
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local prev="${COMP_WORDS[COMP_CWORD-1]}"
        local -i cword_count=$COMP_CWORD

        # Git subcommands at position 1
        if (( cword_count == 1 )); then
            local subcmds
            subcmds=$(git help -a 2>/dev/null | awk '{print $1}' | grep -v '^$')
            COMPREPLY=( $(compgen -W "$subcmds" -- "$cur") )
            return
        fi

        # Option completion when starts with -
        if [[ "$cur" == -* ]]; then
            local git_opts
            git_opts=$(_smart_extract_opts git)
            COMPREPLY=( $(compgen -W "$git_opts" -- "$cur") )
            return
        fi

        # Branch/ref completion for checkout, merge, rebase, etc.
        if [[ "${COMP_WORDS[1]}" =~ ^(checkout|merge|rebase|diff|log|reset)$ ]]; then
            local branches
            branches=$(git branch -a 2>/dev/null | sed 's/^[[:space:]]*[*]?[[:space:]]*//; s%remotes/%%')
            COMPREPLY=( $(compgen -W "$branches" -- "$cur") )
            return
        fi

        # Default to file completion
        _smart_file_complete "$cur"
    }

    # ========================================================================
    # File/Directory Completion Helpers
    # ========================================================================
    _smart_file_complete() {
        local cur="$1"
        local -a dirs files replies
        local IFS=$'\n'

        dirs=( $(compgen -A directory -- "$cur") )
        files=( $(compgen -A file -- "$cur") )
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

    # ========================================================================
    # Universal Completion Function
    # ========================================================================
    _smart_complete() {
        if [[ -z "${COMP_CWORD+x}" || ${COMP_CWORD:-0} -lt 0 || ${#COMP_WORDS[@]} -eq 0 || ${COMP_CWORD:-0} -ge ${#COMP_WORDS[@]} ]]; then
            COMPREPLY=()
            return 0
        fi
        local cur prev cmd
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        cmd="${COMP_WORDS[0]}"

        # Special handling for git
        if [[ "$cmd" == git ]]; then
            _smart_git_complete
            return
        fi

        # Option completion for any starting with -
        if [[ "$cur" == -* ]]; then
            local opts
            opts=$(_smart_extract_opts "$cmd")
            COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
            return
        fi

        # Default: file completion
        _smart_file_complete "$cur"
    }

    # ========================================================================
    # Register Completions (optimized)
    # ========================================================================
    # Only apply universal completion if not already set
    if [[ -z "$_BASH_SMART_COMPLETE_REGISTERED" ]]; then
        # Apply universal completion to all commands via -D flag
        complete -o default -o bashdefault -F _smart_complete -D
        export _BASH_SMART_COMPLETE_REGISTERED=1
    fi

    # Load enhanced Git completion if available (overrides -D default)
    # Only load once to avoid redundant sourcing
    if [[ -z "$_GIT_COMPLETION_LOADED" ]]; then
        if [[ -f "${BASH_CONFIG_DIR:-$HOME/.config/bash}/completion/completions/git.sh" ]]; then
            source "${BASH_CONFIG_DIR:-$HOME/.config/bash}/completion/completions/git.sh"
            export _GIT_COMPLETION_LOADED=1
        elif [[ -f "${BASH_CONFIG_DIR:-$HOME/.config/bash}/completion/completions/git_optimized.sh" ]]; then
            source "${BASH_CONFIG_DIR:-$HOME/.config/bash}/completion/completions/git_optimized.sh"
            export _GIT_COMPLETION_LOADED=1
        else
            complete -o bashdefault -F _smart_git_complete git
        fi
    fi

    # Load Docker completion if available (only load once)
    if [[ -z "$_DOCKER_COMPLETION_LOADED" ]]; then
        if [[ -f "${BASH_CONFIG_DIR:-$HOME/.config/bash}/completion/completions/docker.sh" ]]; then
            source "${BASH_CONFIG_DIR:-$HOME/.config/bash}/completion/completions/docker.sh"
            export _DOCKER_COMPLETION_LOADED=1
        elif [[ -f "${BASH_CONFIG_DIR:-$HOME/.config/bash}/completion/completions/docker_optimized.sh" ]]; then
            source "${BASH_CONFIG_DIR:-$HOME/.config/bash}/completion/completions/docker_optimized.sh"
            export _DOCKER_COMPLETION_LOADED=1
        fi
    fi

fi  # End of _BASH_SMART_COMPLETE_LOADED check