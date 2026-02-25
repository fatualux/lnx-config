#!/bin/bash

# Initialize git completion
_git_completion_initialize() {
    if ! declare -f __gitdir >/dev/null; then
        # Try to find git completion in common locations
        local completion_paths=(
            "/usr/share/bash-completion/completions/git"
            "/etc/bash_completion.d/git"
            "/usr/local/etc/bash_completion.d/git"
            "$HOME/.local/share/bash-completion/completions/git"
        )
        
        for path in "${completion_paths[@]}"; do
            if [[ -f "$path" ]]; then
                source "$path"
                return 0
            fi
        done
        
        # Fallback to basic completion
        complete -o default -o nospace -F _git git 2>/dev/null || true
    fi
}

# Git flow completion
_git_flow() {
    local subcommands="init feature release hotfix support help"
    local cur="${COMP_WORDS[COMP_CWORD]}"
    
    case "${COMP_WORDS[1]}" in
        feature|release|hotfix)
            local flow_subcommands="list start finish delete publish rebase"
            COMPREPLY=($(compgen -W "$flow_subcommands" -- "${cur}"))
            ;;
        *)
            COMPREPLY=($(compgen -W "$subcommands" -- "${cur}"))
            ;;
    esac
}

# Git flow feature completion
_git_flow_feature() {
    local subcommands="list start finish delete publish rebase"
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "$subcommands" -- "${cur}"))
}

# Git flow release completion
_git_flow_release() {
    local subcommands="list start finish delete publish"
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "$subcommands" -- "${cur}"))
}

# Git flow hotfix completion
_git_flow_hotfix() {
    local subcommands="list start finish delete publish"
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "$subcommands" -- "${cur}"))
}

# Basic git prompt function
__git_ps1() {
    local g="$(__gitdir)"
    if [ -n "$g" ]; then
        local r
        local b
        if [ -d "$g/rebase-apply" ]; then
            r="|REBASING"
            b="$(cat "$g/rebase-apply/head-name" 2>/dev/null)"
            b="${b##refs/heads/}"
        elif [ -d "$g/rebase-merge" ]; then
            r="|REBASING"
            b="$(cat "$g/rebase-merge/head-name" 2>/dev/null)"
            b="${b##refs/heads/}"
        elif [ -f "$g/MERGE_HEAD" ]; then
            r="|MERGING"
            b="$(git symbolic-ref HEAD 2>/dev/null || echo "HEAD")"
            b="${b##refs/heads/}"
        elif [ -f "$g/BISECT_LOG" ]; then
            r="|BISECTING"
            b="$(git symbolic-ref HEAD 2>/dev/null || echo "HEAD")"
            b="${b##refs/heads/}"
        else
            r=""
            b="$(git symbolic-ref HEAD 2>/dev/null || echo "HEAD")"
            b="${b##refs/heads/}"
        fi
        
        if [ -n "$b" ]; then
            echo "($b$r)"
        fi
    fi
}

# Helper function for git directory
__gitdir() {
    if [ -z "${1-}" ]; then
        if [ -n "${__git_repo_path-}" ]; then
            echo "$__git_repo_path"
        elif [ -n "${GIT_DIR-}" ]; then
            echo "$GIT_DIR"
        elif [ -d .git ]; then
            echo .git
        else
            git rev-parse --git-dir 2>/dev/null
        fi
    elif [ -d "$1/.git" ]; then
        echo "$1/.git"
    else
        echo "$1"
    fi
}

# Register completions
complete -F _git_flow git-flow
complete -F _git_flow_feature git-flow-feature
complete -F _git_flow_release git-flow-release  
complete -F _git_flow_hotfix git-flow-hotfix

# Initialize git completion on load
_git_completion_initialize
