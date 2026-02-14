#!/bin/bash

# Get current git branch name
get_git_branch() {
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

# Get git status (ahead/behind)
get_git_status() {
    local ahead=0
    local behind=0
    
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
    fi
    
    # Ensure they're numbers
    ahead=${ahead:-0}
    behind=${behind:-0}
    
    echo "$ahead $behind"
}

# Check if working directory has changes (staged or unstaged)
has_git_changes() {
    ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null
}

# Get detailed git working directory status
get_git_working_status() {
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

# Get git user name
get_git_user_name() {
    git config user.name 2>/dev/null
}

# Get git user email
get_git_user_email() {
    git config user.email 2>/dev/null
}

# Check if current directory is in a git repository
is_git_repo() {
    git rev-parse --git-dir >/dev/null 2>&1
}

# Get git root directory
get_git_root() {
    git rev-parse --show-toplevel 2>/dev/null
}
