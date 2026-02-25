#!/bin/bash

# Initialize git completion
_git_completion_initialize() {
    if ! declare -f __gitdir >/dev/null; then
        local git_paths path
        IFS=$'\n' read -r -d '' -a git_paths <<< "$(type -aP git 2>/dev/null)"
        # Fallback to common paths
        git_paths+=("/usr/bin/git" "/usr/local/bin/git")
        
        for path in "${git_paths[@]}"; do
            if [[ -L "$path" ]]; then
                path=$(readlink -f "$path" 2>/dev/null || echo "$path")
            fi
            
            path="${path%/*}"
            local files
            local prefix="${path%/bin}"
            
            # Look for git completion files
            for file in "$prefix"/share/bash-completion/completions/git \
                        "$prefix"/share/git/contrib/completion/git-completion.bash \
                        "$prefix"/share/doc/git/contrib/completion/git-completion.bash; do
                if [[ -f "$file" && -r "$file" && -s "$file" ]]; then
                    source "$file" 2>/dev/null
                    return 0
                fi
            done
        done
        
        # If no completion found, try to create basic completion
        if ! declare -f __gitdir >/dev/null; then
            _git_basic_completion
        fi
    fi
}

# Basic git completion fallback
_git_basic_completion() {
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
                b="$(git symbolic-ref HEAD 2>/dev/null)" || b="$(git rev-parse --short HEAD 2>/dev/null)"
                b="${b##refs/heads/}"
            else
                b="$(git symbolic-ref HEAD 2>/dev/null)" || b="$(git rev-parse --short HEAD 2>/dev/null)"
                b="${b##refs/heads/}"
            fi
            if [ -n "$1" ]; then
                printf "$1" "${b##refs/heads/}$r"
            else
                printf "%s%s" "${b##refs/heads/}" "$r"
            fi
        fi
    }
}

# Git flow completion
_git_flow() {
    local subcommands="init feature release hotfix"
    local subcommand="$(__git_find_subcommand "$subcommands")"
    if [ -z "$subcommand" ]; then
        __gitcomp "$subcommands"
        return
    fi

    case "$subcommand" in
    feature)
        __git_flow_feature
        return
        ;;
    release)
        __git_flow_release
        return
        ;;
    hotfix)
        __git_flow_hotfix
        return
        ;;
    *)
        COMPREPLY=()
        ;;
    esac
}

__git_flow_feature() {
    local subcommands="list start finish publish track diff rebase checkout pull"
    local subcommand="$(__git_find_subcommand "$subcommands")"
    if [ -z "$subcommand" ]; then
        __gitcomp "$subcommands"
        return
    fi

    case "$subcommand" in
    pull)
        __gitcomp "$(__git_remotes)"
        return
        ;;
    checkout|finish|diff|rebase)
        __gitcomp "$(__git_flow_list_features)"
        return
        ;;
    publish)
        __gitcomp "$(comm -23 <(__git_flow_list_features) <(__git_flow_list_remote_features))"
        return
        ;;
    track)
        __gitcomp "$(__git_flow_list_remote_features)"
        return
        ;;
    *)
        COMPREPLY=()
        ;;
    esac
}

__git_flow_list_features() {
    git flow feature list 2> /dev/null | tr -d ' |*'
}

__git_flow_list_remote_features() {
    git branch -r 2> /dev/null | grep "origin/$(__git_flow_feature_prefix)" | awk '{ sub(/^origin\/$(__git_flow_feature_prefix)/, "", $1); print }'
}

__git_flow_feature_prefix() {
    git config gitflow.prefix.feature 2> /dev/null || echo "feature/"
}

__git_flow_release() {
    local subcommands="list start finish"
    local subcommand="$(__git_find_subcommand "$subcommands")"
    if [ -z "$subcommand" ]; then
        __gitcomp "$subcommands"
        return
    fi

    case "$subcommand" in
    finish)
        __gitcomp "$(__git_flow_list_releases)"
        return
        ;;
    *)
        COMPREPLY=()
        ;;
    esac
}

__git_flow_list_releases() {
    git flow release list 2> /dev/null
}

__git_flow_hotfix() {
    local subcommands="list start finish"
    local subcommand="$(__git_find_subcommand "$subcommands")"
    if [ -z "$subcommand" ]; then
        __gitcomp "$subcommands"
        return
    fi

    case "$subcommand" in
    finish)
        __gitcomp "$(__git_flow_list_hotfixes)"
        return
        ;;
    *)
        COMPREPLY=()
        ;;
    esac
}

__git_flow_list_hotfixes() {
    git flow hotfix list 2> /dev/null
}

# Helper functions
__git_find_subcommand() {
    local word c=1
    while [ $c -lt $COMP_CWORD ]; do
        word="${COMP_WORDS[c]}"
        for subcommand in $1; do
            [ "$word" = "$subcommand" ] && echo "$subcommand" && return
        done
        c=$((++c))
    done
}

# Fallback functions if git completion isn't available
if ! declare -f __gitcomp >/dev/null; then
    __gitcomp() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        COMPREPLY=($(compgen -W "$1" -- "$cur"))
    }
fi

if ! declare -f __git_remotes >/dev/null; then
    __git_remotes() {
        git remote 2>/dev/null
    }
fi

# Initialize completion
_git_completion_initialize

# Register git flow completion
if declare -f _git >/dev/null; then
    complete -o default -o nospace -F _git git
    complete -o default -o nospace -F _git_flow git-flow
fi

# Clean up
unset -f _git_completion_initialize
