#!/bin/bash
# ============================================================================
# Optimized Git Completion Module
# ============================================================================
# Features:
#   - Lazy loading of git commands
#   - Smart caching for branches, remotes, etc.
#   - Performance optimized with minimal external calls
#   - Modular subcommand handling

# Prevent multiple loading
if [[ -n "$_GIT_COMPLETION_LOADED" ]]; then
    return 0
fi
_GIT_COMPLETION_LOADED=1

# ============================================================================
# Git Resource Caching
# ============================================================================

_git_cache_get() {
    local resource="$1"
    local cache_key="git_${resource}"
    _completion_cache_get "$cache_key"
}

_git_cache_set() {
    local resource="$1"
    local data="$2"
    local cache_key="git_${resource}"
    _completion_cache_set "$cache_key" "$data"
}

_git_get_branches() {
    if ! _git_cache_get "branches"; then
        local branches
        branches=$(git branch -a 2>/dev/null | \
            sed 's/^[[:space:]]*[*]?[[:space:]]*//; s%remotes/%%' | \
            sort -u)
        echo "$branches" | _git_cache_set "branches"
    fi
}

_git_get_remotes() {
    if ! _git_cache_get "remotes"; then
        local remotes
        remotes=$(git remote 2>/dev/null | sort -u)
        echo "$remotes" | _git_cache_set "remotes"
    fi
}

_git_get_tags() {
    if ! _git_cache_get "tags"; then
        local tags
        tags=$(git tag 2>/dev/null | sort -u)
        echo "$tags" | _git_cache_set "tags"
    fi
}

_git_get_stashes() {
    if ! _git_cache_get "stashes"; then
        local stashes
        stashes=$(git stash list 2>/dev/null | \
            sed 's/^stash@{\([0-9]*\)}.*/\1/' | \
            sort -n)
        echo "$stashes" | _git_cache_set "stashes"
    fi
}

_git_get_subcommands() {
    if ! _git_cache_get "subcommands"; then
        local subcommands
        subcommands=$(git help -a 2>/dev/null 2>/dev/null | \
            awk '/^  [a-z]/ {print $1}' | \
            sort -u)
        echo "$subcommands" | _git_cache_set "subcommands"
    fi
}

_git_get_config_keys() {
    if ! _git_cache_get "config_keys"; then
        local config_keys
        config_keys=$(git config --list 2>/dev/null | \
            cut -d'=' -f1 | \
            sort -u)
        echo "$config_keys" | _git_cache_set "config_keys"
    fi
}

# ============================================================================
# Git Subcommand Completions
# ============================================================================

_git_complete_checkout() {
    local cur="$1"
    local prev="$2"
    
    case "$prev" in
        -b|--branch)
            _git_get_branches
            COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
            return
            ;;
        -t|--track)
            _git_get_remotes
            COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
            return
            ;;
    esac
    
    # Complete branches, tags, and remotes
    local refs
    refs=$(
        (_git_get_branches; _git_get_tags; _git_get_remotes) | \
        sort -u | tr '\n' ' '
    )
    COMPREPLY=( $(compgen -W "$refs" -- "$cur") )
}

_git_complete_branch() {
    local cur="$1"
    local prev="$2"
    
    case "$prev" in
        -d|--delete|-D|--delete|--force-delete|-m|--move|-M|--move-force)
            _git_get_branches
            COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
            return
            ;;
        -r|--remotes)
            _git_get_remotes
            COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
            return
            ;;
    esac
    
    _git_get_branches
    COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
}

_git_complete_remote() {
    local cur="$1"
    local prev="$2"
    
    case "$prev" in
        add|rename|rm|prune|set-branches|set-head|set-url)
            _git_get_remotes
            COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
            return
            ;;
    esac
    
    COMPREPLY=( $(compgen -W "add prune rename rm show update set-head set-url set-branches get-url --help" -- "$cur") )
}

_git_complete_log() {
    local cur="$1"
    local prev="$2"
    
    case "$prev" in
        --since|--after|--until|--before)
            COMPREPLY=( $(compgen -W "yesterday today '1 week ago' '1 month ago'" -- "$cur") )
            return
            ;;
        --author)
            COMPREPLY=( $(compgen -u -- "$cur") )
            return
            ;;
        --grep)
            COMPREPLY=()
            return
            ;;
    esac
    
    # Complete branches and tags for log
    local refs
    refs=$(_git_get_branches; _git_get_tags)
    COMPREPLY=( $(compgen -W "$refs --oneline --graph --decorate --all --grep --author --since --until --help" -- "$cur") )
}

_git_complete_stash() {
    local cur="$1"
    local prev="$2"
    
    case "$prev" in
        show|apply|pop|drop)
            _git_get_stashes
            COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
            return
            ;;
    esac
    
    COMPREPLY=( $(compgen -W "show list apply pop drop clear branch create save --help" -- "$cur") )
}

_git_complete_config() {
    local cur="$1"
    local prev="$2"
    
    case "$prev" in
        --get|--unset|--unset-all|--add|--replace-all)
            _git_get_config_keys
            COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
            return
            ;;
        --global|--system|--local|--worktree)
            COMPREPLY=()
            return
            ;;
    esac
    
    COMPREPLY=( $(compgen -W "--global --system --local --worktree --get --unset --unset-all --add --replace-all --list --edit --get-colorbool --get-regexp --help" -- "$cur") )
}

_git_complete_add() {
    local cur="$1"
    
    # Complete files and directories
    _completion_complete_files "$cur"
}

_git_complete_commit() {
    local cur="$1"
    local prev="$2"
    
    case "$prev" in
        -m|--message)
            COMPREPLY=()
            return
            ;;
        --author)
            COMPREPLY=( $(compgen -u -- "$cur") )
            return
            ;;
    esac
    
    COMPREPLY=( $(compgen -W "--message --author --date --all --amend --no-edit --signoff --help" -- "$cur") )
}

_git_complete_push() {
    local cur="$1"
    local prev="$2"
    
    case "$prev" in
        git)
            _git_get_remotes
            COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
            return
            ;;
        origin|upstream|github|gitlab)  # Common remote names
            _git_get_branches
            COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
            return
            ;;
    esac
    
    _git_get_remotes
    COMPREPLY=( $(compgen -W "$(cat) --all --delete --tags --force --help" -- "$cur") )
}

_git_complete_pull() {
    local cur="$1"
    local prev="$2"
    
    case "$prev" in
        git)
            _git_get_remotes
            COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
            return
            ;;
    esac
    
    _git_get_remotes
    COMPREPLY=( $(compgen -W "$(cat) --all --rebase --no-rebase --help" -- "$cur") )
}

# ============================================================================
# Main Git Completion Function
# ============================================================================

_git_complete() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Handle git subcommands
    if (( COMP_CWORD == 1 )); then
        _git_get_subcommands
        COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
        return
    fi
    
    local subcmd="${COMP_WORDS[1]}"
    
    # Option completion for any subcommand
    if [[ "$cur" == -* ]]; then
        _completion_complete_with_cache "git $subcmd" "git_${subcmd}_opts" "_extract_git_options" "$cur"
        return
    fi
    
    # Subcommand-specific completion
    case "$subcmd" in
        checkout|co)
            _git_complete_checkout "$cur" "$prev"
            ;;
        branch|br)
            _git_complete_branch "$cur" "$prev"
            ;;
        remote|rem)
            _git_complete_remote "$cur" "$prev"
            ;;
        log)
            _git_complete_log "$cur" "$prev"
            ;;
        stash)
            _git_complete_stash "$cur" "$prev"
            ;;
        config)
            _git_complete_config "$cur" "$prev"
            ;;
        add)
            _git_complete_add "$cur"
            ;;
        commit|ci)
            _git_complete_commit "$cur" "$prev"
            ;;
        push)
            _git_complete_push "$cur" "$prev"
            ;;
        pull)
            _git_complete_pull "$cur" "$prev"
            ;;
        merge|rebase|diff|reset|show)
            _git_get_branches
            COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
            ;;
        tag)
            _git_get_tags
            COMPREPLY=( $(compgen -W "$(cat)" -- "$cur") )
            ;;
        *)
            # Default to file completion
            _completion_complete_files "$cur"
            ;;
    esac
}

_extract_git_options() {
    local cmd="$1"
    local help_output
    help_output=$(git "$cmd" --help 2>/dev/null || true)
    _completion_filter_options "$help_output" "--?"
}

# Register completion
complete -o default -o bashdefault -F _git_complete git
