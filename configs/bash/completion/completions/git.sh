#!/bin/bash
# ============================================================================
# Git Bash Completion
# ============================================================================
# Enhanced completion with comprehensive git command support
# Features:
#   - Complete all branches (local + remote) for relevant commands
#   - Complete all tags for relevant commands
#   - Complete all remotes for relevant commands
#   - Smart context-aware completions
#   - Enhanced commit message suggestions
#   - Stash completion
#   - Worktree completion
# ============================================================================

if [[ -z "$_GIT_COMPLETION_CONSOLIDATED_LOADED" ]]; then
    _GIT_COMPLETION_CONSOLIDATED_LOADED=1

    # ============================================================================
    # Helper Functions
    # ============================================================================

    # Get all branches (local and remote)
    _git_get_branches() {
        git branch -a 2>/dev/null | sed 's/^[[:space:]]*[*]?[[:space:]]*//; s%remotes/%%' | sort -u
    }

    # Get local branches only
    _git_get_local_branches() {
        git branch 2>/dev/null | sed 's/^[[:space:]]*[*]?[[:space:]]*//' | sort -u
    }

    # Get remote branches only
    _git_get_remote_branches() {
        git branch -r 2>/dev/null | sed 's/^[[:space:]]*[*]?[[:space:]]*//' | sort -u
    }

    # Get all tags
    _git_get_tags() {
        git tag 2>/dev/null | sort -u
    }

    # Get all remotes
    _git_get_remotes() {
        git remote 2>/dev/null | sort -u
    }

    # Get recent commits (for commit completion)
    _git_get_recent_commits() {
        git log --oneline -20 2>/dev/null | cut -d' ' -f1
    }

    # Get stash list
    _git_get_stashes() {
        git stash list 2>/dev/null | sed 's/^stash@{\([0-9]*\)}.*/\1/' | sort -n
    }

    # Get worktree paths
    _git_get_worktrees() {
        git worktree list 2>/dev/null | awk '{print $1}' | sort -u
    }

    # Get config keys
    _git_get_config_keys() {
        git config --list 2>/dev/null | cut -d'.' -f1 | sort -u
    }

    # ============================================================================
    # Git-Flow Helper Functions
    # ============================================================================

    # Get git-flow prefix for a branch type
    _git_flow_prefix() {
        local branch_type="$1"
        git config "gitflow.prefix.$branch_type" 2>/dev/null || echo "$branch_type/"
    }

    # Get git-flow branches of a specific type
    _git_flow_list_branches() {
        local branch_type="$1"
        local scope="$2"  # "local", "remote", or "all"
        local prefix
        prefix=$(_git_flow_prefix "$branch_type")
        
        case "$scope" in
            local)
                git for-each-ref --format="%(refname:short)" "refs/heads/$prefix" 2>/dev/null | \
                    sed "s|^$prefix||" | sort
                ;;
            remote)
                local origin
                origin=$(git config gitflow.origin 2>/dev/null || echo "origin")
                git for-each-ref --format="%(refname:short)" "refs/remotes/$origin/$prefix" 2>/dev/null | \
                    sed "s|^$origin/$prefix||" | sort
                ;;
            *)
                # All branches (local + remote)
                {
                    git for-each-ref --format="%(refname:short)" "refs/heads/$prefix" 2>/dev/null | \
                        sed "s|^$prefix||"
                    local origin
                    origin=$(git config gitflow.origin 2>/dev/null || echo "origin")
                    git for-each-ref --format="%(refname:short)" "refs/remotes/$origin/$prefix" 2>/dev/null | \
                        sed "s|^$origin/$prefix||"
                } | sort -u
                ;;
        esac
    }

    # Get git-flow features
    _git_flow_list_features() {
        _git_flow_list_branches "feature" "$1"
    }

    # Get git-flow bugfixes
    _git_flow_list_bugfixes() {
        _git_flow_list_branches "bugfix" "$1"
    }

    # Get git-flow releases
    _git_flow_list_releases() {
        _git_flow_list_branches "release" "$1"
    }

    # Get git-flow hotfixes
    _git_flow_list_hotfixes() {
        _git_flow_list_branches "hotfix" "$1"
    }

    # Get git-flow support branches
    _git_flow_list_support() {
        _git_flow_list_branches "support" "$1"
    }

    # Find subcommand on command line (optimized version)
    _git_find_subcommand() {
        local subcommands="$1"
        local cword="${COMP_CWORD:-1}"
        local i
        
        for ((i=1; i<cword; i++)); do
            if [[ " ${COMP_WORDS[i]} " =~ " ${subcommands} " ]]; then
                echo "${COMP_WORDS[i]}"
                return
            fi
        done
    }

    # ============================================================================
    # Specific Completion Functions
    # ============================================================================

    _git_branch_completion() {
        local cur="$1"
        local branches=$(_git_get_branches)
        COMPREPLY=($(compgen -W "$branches" -- "$cur"))
    }

    _git_tag_completion() {
        local cur="$1"
        local tags=$(_git_get_tags)
        COMPREPLY=($(compgen -W "$tags" -- "$cur"))
    }

    _git_remote_completion() {
        local cur="$1"
        local remotes=$(_git_get_remotes)
        COMPREPLY=($(compgen -W "$remotes" -- "$cur"))
    }

    _git_commit_completion() {
        local cur="$1"
        if [[ "$cur" == -* ]]; then
            local opts=(
                "--message" "-m" "--all" "-a" "--amend" "--no-edit" "--no-verify"
                "--signoff" "-s" "--quiet" "-q" "--verbose" "-v" "--help"
            )
            COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
        else
            # Suggest recent commit hashes for reference
            local commits=$(_git_get_recent_commits)
            COMPREPLY=($(compgen -W "$commits" -- "$cur"))
        fi
    }

    _git_stash_completion() {
        local cur="$1"
        local prev="$2"
        
        case "$prev" in
            stash)
                local commands=("show" "pop" "apply" "drop" "clear" "list" "branch" "save" "push")
                COMPREPLY=($(compgen -W "${commands[*]}" -- "$cur"))
                ;;
            show|pop|apply|drop|branch)
                local stashes=$(_git_get_stashes | sed 's/^/stash@{&}/')
                COMPREPLY=($(compgen -W "$stashes" -- "$cur"))
                ;;
            *)
                if [[ "$cur" == -* ]]; then
                    local opts=("--help" "-p" "--patch" "-s" "--staged" "-u" "--include-untracked" "-a" "--all" "-k" "--keep-index" "-q" "--quiet")
                    COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
                fi
                ;;
        esac
    }

    _git_worktree_completion() {
        local cur="$1"
        local prev="$2"
        
        case "$prev" in
            worktree)
                local commands=("add" "list" "prune" "remove" "move" "unlock")
                COMPREPLY=($(compgen -W "${commands[*]}" -- "$cur"))
                ;;
            add)
                local branches=$(_git_get_branches)
                COMPREPLY=($(compgen -W "$branches" -- "$cur"))
                ;;
            remove|move|unlock)
                local worktrees=$(_git_get_worktrees)
                COMPREPLY=($(compgen -W "$worktrees" -- "$cur"))
                ;;
            *)
                if [[ "$cur" == -* ]]; then
                    local opts=("--help" "--force" "-f" "--detach" "-d" "--guess-remote" "-b" "-B")
                    COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
                fi
                ;;
        esac
    }

    _git_remote_subcmd_completion() {
        local cur="$1"
        local prev="$2"
        
        case "$prev" in
            remote)
                local commands=("add" "rename" "remove" "prune" "set-head" "set-branches" "set-url" "show" "get-url" "update")
                COMPREPLY=($(compgen -W "${commands[*]}" -- "$cur"))
                ;;
            add|rename|remove|set-head|set-branches|set-url|show|get-url|update)
                local remotes=$(_git_get_remotes)
                COMPREPLY=($(compgen -W "$remotes" -- "$cur"))
                ;;
            *)
                if [[ "$cur" == -* ]]; then
                    local opts=("--help" "-v" "--verbose")
                    COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
                fi
                ;;
        esac
    }

    _git_remote_ops_completion() {
        local cur="$1"
        local prev="$2"
        
        case "$prev" in
            push|pull|fetch)
                local remotes=$(_git_get_remotes)
                COMPREPLY=($(compgen -W "$remotes" -- "$cur"))
                ;;
            *)
                if [[ "$cur" == -* ]]; then
                    local opts=("--help" "--all" "--prune" "--tags" "--force" "-f" "--dry-run" "-n")
                    COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
                else
                    # For push/pull/fetch, suggest remotes and branches
                    local remotes=$(_git_get_remotes)
                    local branches=$(_git_get_branches)
                    COMPREPLY=($(compgen -W "$remotes $branches" -- "$cur"))
                fi
                ;;
        esac
    }

    _git_log_completion() {
        local cur="$1"
        if [[ "$cur" == -* ]]; then
            local opts=(
                "--oneline" "--graph" "--decorate" "--all" "--grep" "--author"
                "--since" "--until" "--max-count" "-n" "--patch" "-p" "--stat"
                "--name-only" "--name-status" "--follow" "--help"
            )
            COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
        else
            # Suggest branches, tags, and commits for log targets
            local refs=$(_git_get_branches)
            refs="$refs $(_git_get_tags)"
            refs="$refs $(_git_get_recent_commits)"
            COMPREPLY=($(compgen -W "$refs" -- "$cur"))
        fi
    }

    _git_config_completion() {
        local cur="$1"
        if [[ "$cur" == -* ]]; then
            local opts=("--global" "--local" "--system" "--worktree" "--file" "--get" "--get-all" "--add" "--unset" "--unset-all" "--replace-all" "--list" "--show-origin" "--help")
            COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
        else
            local keys=$(_git_get_config_keys)
            COMPREPLY=($(compgen -W "$keys" -- "$cur"))
        fi
    }

    _git_history_completion() {
        local cur="$1"
        if [[ "$cur" == -* ]]; then
            local opts=("--help" "--all" "--grep" "--author" "--since" "--until" "--max-count" "-n")
            COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
        else
            local refs=$(_git_get_branches)
            refs="$refs $(_git_get_tags)"
            refs="$refs $(_git_get_recent_commits)"
            COMPREPLY=($(compgen -W "$refs" -- "$cur"))
        fi
    }

    # ============================================================================
    # Git-Flow Completion Functions
    # ============================================================================

    _git_flow_completion() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local prev="${COMP_WORDS[COMP_CWORD-1]}"
        local subcommands="init feature bugfix release hotfix support help version config finish delete publish rebase"
        local subcommand
        
        subcommand=$(_git_find_subcommand "$subcommands")
        if [[ -z "$subcommand" ]]; then
            COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
            return
        fi

        case "$subcommand" in
            init)
                _git_flow_init_completion "$cur" "$prev"
                ;;
            feature)
                _git_flow_feature_completion "$cur" "$prev"
                ;;
            bugfix)
                _git_flow_bugfix_completion "$cur" "$prev"
                ;;
            release)
                _git_flow_release_completion "$cur" "$prev"
                ;;
            hotfix)
                _git_flow_hotfix_completion "$cur" "$prev"
                ;;
            support)
                _git_flow_support_completion "$cur" "$prev"
                ;;
            config)
                _git_flow_config_completion "$cur" "$prev"
                ;;
            *)
                COMPREPLY=()
                ;;
        esac
    }

    _git_flow_init_completion() {
        local cur="$1"
        if [[ "$cur" == -* ]]; then
            local opts=("--nodefaults" "--defaults" "--noforce" "--force" "--local" "--global" "--system" "--file=")
            COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
        else
            COMPREPLY=($(compgen -W "help" -- "$cur"))
        fi
    }

    _git_flow_feature_completion() {
        local cur="$1"
        local prev="$2"
        local subcommands="list start finish publish track diff rebase checkout pull help delete rename"
        local subcommand
        
        subcommand=$(_git_find_subcommand "$subcommands")
        if [[ -z "$subcommand" ]]; then
            COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
            return
        fi

        case "$subcommand" in
            pull)
                local remotes=$(_git_get_remotes)
                COMPREPLY=($(compgen -W "$remotes" -- "$cur"))
                ;;
            checkout)
                local features=$(_git_flow_list_features "local")
                COMPREPLY=($(compgen -W "$features" -- "$cur"))
                ;;
            delete|finish|diff|rebase)
                if [[ "$cur" == -* ]]; then
                    local opts=("--noforce" "--force" "--noremote" "--remote" "--nofetch" "--fetch" "--norebase" "--rebase" "--nopreserve-merges" "--preserve-merges" "--nokeep" "--keep" "--keepremote" "--keeplocal" "--noforce_delete" "--force_delete" "--nosquash" "--squash" "--no-ff" "--nointeractive" "--interactive")
                    COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
                else
                    local features=$(_git_flow_list_features "local")
                    COMPREPLY=($(compgen -W "$features" -- "$cur"))
                fi
                ;;
            publish)
                local features=$(_git_flow_list_features "all")
                COMPREPLY=($(compgen -W "$features" -- "$cur"))
                ;;
            track)
                local features=$(_git_flow_list_features "remote")
                COMPREPLY=($(compgen -W "$features" -- "$cur"))
                ;;
            *)
                COMPREPLY=()
                ;;
        esac
    }

    _git_flow_bugfix_completion() {
        local cur="$1"
        local prev="$2"
        local subcommands="list start finish publish track diff rebase checkout pull help delete rename"
        local subcommand
        
        subcommand=$(_git_find_subcommand "$subcommands")
        if [[ -z "$subcommand" ]]; then
            COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
            return
        fi

        case "$subcommand" in
            pull)
                local remotes=$(_git_get_remotes)
                COMPREPLY=($(compgen -W "$remotes" -- "$cur"))
                ;;
            checkout)
                local bugfixes=$(_git_flow_list_bugfixes "local")
                COMPREPLY=($(compgen -W "$bugfixes" -- "$cur"))
                ;;
            delete|finish|diff|rebase)
                if [[ "$cur" == -* ]]; then
                    local opts=("--noforce" "--force" "--noremote" "--remote" "--nofetch" "--fetch" "--norebase" "--rebase" "--nopreserve-merges" "--preserve-merges" "--nokeep" "--keep" "--keepremote" "--keeplocal" "--noforce_delete" "--force_delete" "--nosquash" "--squash" "--no-ff" "--nointeractive" "--interactive")
                    COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
                else
                    local bugfixes=$(_git_flow_list_bugfixes "local")
                    COMPREPLY=($(compgen -W "$bugfixes" -- "$cur"))
                fi
                ;;
            publish)
                local bugfixes=$(_git_flow_list_bugfixes "all")
                COMPREPLY=($(compgen -W "$bugfixes" -- "$cur"))
                ;;
            track)
                local bugfixes=$(_git_flow_list_bugfixes "remote")
                COMPREPLY=($(compgen -W "$bugfixes" -- "$cur"))
                ;;
            *)
                COMPREPLY=()
                ;;
        esac
    }

    _git_flow_release_completion() {
        local cur="$1"
        local prev="$2"
        local subcommands="list start finish track publish help delete"
        local subcommand
        
        subcommand=$(_git_find_subcommand "$subcommands")
        if [[ -z "$subcommand" ]]; then
            COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
            return
        fi

        case "$subcommand" in
            finish|delete)
                if [[ "$cur" == -* ]]; then
                    local opts=("--nofetch" "--fetch" "--sign" "--signingkey" "--message" "--nomessagefile" "--messagefile=" "--nopush" "--push" "--nokeep" "--keep" "--keepremote" "--keeplocal" "--noforce_delete" "--force_delete" "--notag" "--tag" "--nonobackmerge" "--nobackmerge" "--nosquash" "--squash" "--squash-info" "--noforce" "--force" "--noremote" "--remote")
                    COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
                else
                    local releases=$(_git_flow_list_releases "local")
                    COMPREPLY=($(compgen -W "$releases" -- "$cur"))
                fi
                ;;
            publish|track)
                local releases=$(_git_flow_list_releases "all")
                COMPREPLY=($(compgen -W "$releases" -- "$cur"))
                ;;
            start)
                if [[ "$cur" == -* ]]; then
                    local opts=("--nofetch" "--fetch")
                    COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
                fi
                ;;
            *)
                COMPREPLY=()
                ;;
        esac
    }

    _git_flow_hotfix_completion() {
        local cur="$1"
        local prev="$2"
        local subcommands="list start finish track publish help delete rename"
        local subcommand
        
        subcommand=$(_git_find_subcommand "$subcommands")
        if [[ -z "$subcommand" ]]; then
            COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
            return
        fi

        case "$subcommand" in
            finish|delete)
                if [[ "$cur" == -* ]]; then
                    local opts=("--nofetch" "--fetch" "--sign" "--signingkey" "--message" "--nomessagefile" "--messagefile=" "--nopush" "--push" "--nokeep" "--keep" "--keepremote" "--keeplocal" "--noforce_delete" "--force_delete" "--notag" "--tag" "--nonobackmerge" "--nobackmerge" "--nosquash" "--squash" "--squash-info" "--noforce" "--force" "--noremote" "--remote")
                    COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
                else
                    local hotfixes=$(_git_flow_list_hotfixes "local")
                    COMPREPLY=($(compgen -W "$hotfixes" -- "$cur"))
                fi
                ;;
            publish|track)
                local hotfixes=$(_git_flow_list_hotfixes "all")
                COMPREPLY=($(compgen -W "$hotfixes" -- "$cur"))
                ;;
            start)
                if [[ "$cur" == -* ]]; then
                    local opts=("--nofetch" "--fetch")
                    COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
                fi
                ;;
            *)
                COMPREPLY=()
                ;;
        esac
    }

    _git_flow_support_completion() {
        local cur="$1"
        local prev="$2"
        local subcommands="list start help"
        local subcommand
        
        subcommand=$(_git_find_subcommand "$subcommands")
        if [[ -z "$subcommand" ]]; then
            COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
            return
        fi

        case "$subcommand" in
            start)
                if [[ "$cur" == -* ]]; then
                    local opts=("--nofetch" "--fetch")
                    COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
                fi
                ;;
            *)
                COMPREPLY=()
                ;;
        esac
    }

    _git_flow_config_completion() {
        local cur="$1"
        local prev="$2"
        local subcommands="list set base"
        local subcommand
        
        subcommand=$(_git_find_subcommand "$subcommands")
        if [[ -z "$subcommand" ]]; then
            COMPREPLY=($(compgen -W "$subcommands" -- "$cur"))
            return
        fi

        case "$subcommand" in
            set)
                if [[ "$cur" == -* ]]; then
                    local opts=("--local" "--global" "--system" "--file=")
                    COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
                else
                    COMPREPLY=($(compgen -W "master develop feature bugfix hotfix release support versiontagprefix" -- "$cur"))
                fi
                ;;
            base)
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=($(compgen -W "set get" -- "$cur"))
                else
                    local branches=$(_git_get_local_branches)
                    COMPREPLY=($(compgen -W "$branches" -- "$cur"))
                fi
                ;;
            *)
                COMPREPLY=()
                ;;
        esac
    }

    # ============================================================================
    # Main Git Completion Function
    # ============================================================================

    _git_complete() {
        if [[ -z "${COMP_CWORD+x}" || ${COMP_CWORD:-0} -lt 0 || ${#COMP_WORDS[@]} -eq 0 || ${COMP_CWORD:-0} -ge ${#COMP_WORDS[@]} ]]; then
            COMPREPLY=()
            return 0
        fi
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local prev="${COMP_WORDS[COMP_CWORD-1]}"
        local cmd="${COMP_WORDS[1]}"

        # Handle git subcommands
        case "$cmd" in
            # Git Flow operations
            flow)
                _git_flow_completion
                ;;
            # Branch operations
            branch|checkout|switch|merge|rebase|cherry-pick|reset)
                _git_branch_completion "$cur"
                ;;
            # Tag operations
            tag|describe|verify-tag)
                _git_tag_completion "$cur"
                ;;
            # Remote operations
            remote)
                _git_remote_subcmd_completion "$cur" "$prev"
                ;;
            push|pull|fetch|clone)
                _git_remote_ops_completion "$cur" "$prev"
                ;;
            # Commit operations
            commit|amend|revert)
                _git_commit_completion "$cur"
                ;;
            # Stash operations
            stash)
                _git_stash_completion "$cur" "$prev"
                ;;
            # Worktree operations
            worktree)
                _git_worktree_completion "$cur" "$prev"
                ;;
            # Log operations
            log|show|diff)
                _git_log_completion "$cur"
                ;;
            # Config operations
            config)
                _git_config_completion "$cur"
                ;;
            # History operations
            reflog|bisect)
                _git_history_completion "$cur"
                ;;
            *)
                # Main git command completion
                if [[ "$cur" == -* ]]; then
                    local main_opts=(
                        "--version" "--help" "--exec-path" "--html-path"
                        "--man-path" "--info-path" "--work-tree" "--git-dir"
                        "--namespace" "--bare" "--no-pager" "--paginate"
                        "--no-replace-objects" "--literal-pathspecs"
                        "--glob-pathspecs" "--noglob-pathspecs" "--icase-pathspecs"
                    )
                    COMPREPLY=($(compgen -W "${main_opts[*]}" -- "$cur"))
                else
                    local commands=(
                        "add" "am" "annotate" "apply" "archive" "bisect" "blame"
                        "branch" "bundle" "cat-file" "check-attr" "check-ignore"
                        "check-mailmap" "check-ref-format" "checkout" "cherry"
                        "cherry-pick" "citool" "clean" "clone" "commit" "config"
                        "count-objects" "credential" "credential-cache"
                        "credential-store" "cvsexportcommit" "cvsimport" "cvsserver"
                        "daemon" "describe" "diff" "difftool" "fast-export"
                        "fast-import" "fetch" "fetch-pack" "filter-branch"
                        "fmt-merge-msg" "for-each-ref" "format-patch" "fsck"
                        "gc" "get-tar-commit-id" "grep" "gui" "hash-object"
                        "help" "http-backend" "http-fetch" "http-push" "imap-send"
                        "index-pack" "init" "init-db" "log" "ls-files" "ls-remote"
                        "ls-tree" "mailinfo" "mailsplit" "merge" "merge-base"
                        "merge-file" "merge-index" "merge-one-file" "merge-tree"
                        "mergetool" "mktag" "mktree" "mv" "name-rev" "notes"
                        "p4" "pack-objects" "pack-redundant" "pack-refs"
                        "patch-id" "peek-remote" "prune" "prune-packed" "pull"
                        "push" "quiltimport" "read-tree" "rebase" "receive-pack"
                        "reflog" "remote" "remote-ext" "remote-fd" "remote-ftp"
                        "remote-ftps" "remote-http" "remote-https" "remote-testgit"
                        "remote-tftp" "repack" "replace" "request-pull" "rerere"
                        "reset" "rev-list" "rev-parse" "revert" "rm" "send-email"
                        "send-pack" "sh-i18n--envsubst" "shell" "shortlog" "show"
                        "show-branch" "show-index" "show-ref" "stage" "stash"
                        "status" "stripspace" "submodule" "svn" "symbolic-ref"
                        "tag" "tar-tree" "unpack-file" "unpack-objects"
                        "update-index" "update-ref" "update-server-info"
                        "upload-archive" "upload-pack" "var" "verify-pack"
                        "verify-tag" "web--browse" "whatchanged" "worktree"
                        "write-tree" "flow"
                    )
                    COMPREPLY=($(compgen -W "${commands[*]}" -- "$cur"))
                fi
                ;;
        esac
    }

    # Register completion
    complete -o bashdefault -o default -F _git_complete git
fi
