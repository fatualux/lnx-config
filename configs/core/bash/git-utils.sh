#!/bin/bash

# Git caching variables to reduce repeated calls
__GIT_CACHE_DIR=""
__GIT_CACHE_BRANCH=""
__GIT_CACHE_STATUS=""
__GIT_CACHE_WORKING_STATUS=""
__GIT_CACHE_USER_NAME=""
__GIT_CACHE_USER_EMAIL=""
__GIT_CACHE_TIMESTAMP=0
__GIT_CACHE_TTL=5  # Cache for 5 seconds

# Check if cache is valid
_is_git_cache_valid() {
    local current_time=$(date +%s)
    [[ $((current_time - __GIT_CACHE_TIMESTAMP)) -lt $__GIT_CACHE_TTL ]]
}

# Update git cache with current directory info
_update_git_cache() {
    __GIT_CACHE_DIR=$(git rev-parse --git-dir 2>/dev/null)
    __GIT_CACHE_TIMESTAMP=$(date +%s)
    
    if [[ -n "$__GIT_CACHE_DIR" ]]; then
        # Cache all git info at once
        __GIT_CACHE_BRANCH=$(get_git_branch_uncached)
        __GIT_CACHE_STATUS=$(get_git_status_uncached)
        __GIT_CACHE_WORKING_STATUS=$(get_git_working_status_uncached)
        __GIT_CACHE_USER_NAME=$(git config user.name 2>/dev/null)
        __GIT_CACHE_USER_EMAIL=$(git config user.email 2>/dev/null)
    else
        # Clear cache if not in git repo
        __GIT_CACHE_BRANCH=""
        __GIT_CACHE_STATUS=""
        __GIT_CACHE_WORKING_STATUS=""
        __GIT_CACHE_USER_NAME=""
        __GIT_CACHE_USER_EMAIL=""
    fi
    
    # Ensure only status is output, suppress other function outputs
    return 0
}

# Get current git branch name (cached)
get_git_branch() {
    if ! _is_git_cache_valid; then
        _update_git_cache
    fi
    echo "$__GIT_CACHE_BRANCH"
}

# Uncached version for internal use
get_git_branch_uncached() {
    local branch
    if branch=$(git symbolic-ref --short HEAD 2>/dev/null); then
        echo "$branch"
    elif branch=$(git describe --all --exact-match 2>/dev/null); then
        echo "${branch#heads/}"
    else
        # Detached HEAD
        local sha=$(git rev-parse --short HEAD 2>/dev/null)
        if [ -n "$sha" ]; then
            echo "detached:$sha"
        fi
    fi
}

# Check if HEAD is detached
is_git_detached() {
    ! git symbolic-ref HEAD &>/dev/null
}

# Get git status (ahead/behind) (cached)
get_git_status() {
    if ! _is_git_cache_valid; then
        _update_git_cache
    fi
    echo "$__GIT_CACHE_STATUS"
}

# Uncached version for internal use
get_git_status_uncached() {
    local ahead=0
    local behind=0
    local staged=0
    local unstaged=0
    
    if git rev-parse --git-dir >/dev/null 2>&1; then
        local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
        if [ -n "$branch" ]; then
            local upstream=$(git rev-parse --abbrev-ref "@{upstream}" 2>/dev/null)
            if [ -n "$upstream" ]; then
                local counts=$(git rev-list --left-right --count "$upstream...HEAD" 2>/dev/null)
                behind=$(echo "$counts" | awk '{print $1}' | sed 's/^$/0/')
                ahead=$(echo "$counts" | awk '{print $2}' | sed 's/^$/0/')
            fi
        fi
        
        # Get commit status
        local status=$(git status --porcelain 2>/dev/null)
        if [[ -n "$status" ]]; then
            staged=$(echo "$status" | grep -c "^[MADRC]" || echo "0")
            unstaged=$(echo "$status" | grep -c "^[MADRC][MD]" || echo "0")
            # Count deleted files as unstaged
            unstaged=$((unstaged + $(echo "$status" | grep -c "^ D" || echo "0")))
        fi
    fi
    
    # Ensure they're numbers
    ahead=${ahead:-0}
    behind=${behind:-0}
    staged=${staged:-0}
    unstaged=${unstaged:-0}
    
    echo "$ahead $behind $staged $unstaged"
}

# Check if working directory has changes (staged or unstaged)
has_git_changes() {
    ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null
}

# Get detailed git working directory status (cached)
get_git_working_status() {
    if ! _is_git_cache_valid; then
        _update_git_cache
    fi
    echo "$__GIT_CACHE_WORKING_STATUS"
}

# Uncached version for internal use
get_git_working_status_uncached() {
    local staged=0
    local unstaged=0
    local untracked=0
    
    if git rev-parse --git-dir >/dev/null 2>&1; then
        # Count staged changes
        staged=$(git diff --cached --numstat 2>/dev/null | wc -l)
        staged=${staged:-0}
        
        # Count unstaged changes
        unstaged=$(git diff --numstat 2>/dev/null | wc -l)
        unstaged=${unstaged:-0}
        
        # Count untracked files
        untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l)
        untracked=${untracked:-0}
    fi
    
    echo "$staged $unstaged $untracked"
}

# Get git user name (cached)
get_git_user_name() {
    if ! _is_git_cache_valid; then
        _update_git_cache
    fi
    echo "$__GIT_CACHE_USER_NAME"
}

# Get git user email (cached)
get_git_user_email() {
    if ! _is_git_cache_valid; then
        _update_git_cache
    fi
    echo "$__GIT_CACHE_USER_EMAIL"
}

# Check if current directory is in a git repository (cached)
is_git_repo() {
    if ! _is_git_cache_valid; then
        _update_git_cache
    fi
    [[ -n "$__GIT_CACHE_DIR" ]]
}

# Get git root directory
get_git_root() {
    git rev-parse --show-toplevel 2>/dev/null
}
