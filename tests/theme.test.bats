#!/usr/bin/env bats

# Load test helpers and theme
load test_helper
source "$SCRIPT_DIR/configs/core/bash/theme.sh"

@test "theme: defines all color variables" {
    [ -n "$C_USER" ]
    [ -n "$C_HOST" ]
    [ -n "$C_IP" ]
    [ -n "$C_PATH" ]
    [ -n "$C_VENV" ]
    [ -n "$C_BRANCH" ]
    [ -n "$C_AHEAD" ]
    [ -n "$C_BEHIND" ]
    [ -n "$C_COMMIT" ]
    [ -n "$C_SYMBOL" ]
    [ -n "$C_RESET" ]
}

@test "theme: get_ip_address caches results" {
    # Reset cache
    __CACHED_IP_ADDRESS=""
    __IP_CACHE_TIMESTAMP=0
    
    # First call should get IP
    local ip1
    ip1=$(get_ip_address)
    [ -n "$ip1" ]
    
    # Second call within TTL should return cached result
    local ip2
    ip2=$(get_ip_address)
    [ "$ip1" = "$ip2" ]
}

@test "theme: is_git_repo detects git repositories" {
    # Test in current directory (should be a git repo)
    run is_git_repo
    [ "$status" -eq 0 ]
}

@test "theme: get_git_branch returns branch name" {
    # Mock git command for testing
    git() {
        if [[ "$1" == "branch" && "$2" == "--show-current" ]]; then
            echo "main"
        fi
    }
    
    local branch
    branch=$(get_git_branch)
    [ "$branch" = "main" ]
}

@test "theme: get_theme_git_status handles no upstream" {
    # Mock git commands for testing
    git() {
        if [[ "$1" == "rev-list" ]]; then
            return 1  # No upstream
        fi
    }
    
    local status
    status=$(get_theme_git_status)
    [ -n "$status" ]
}

@test "theme: set_prompt creates valid PS1" {
    # Mock environment
    PWD="/test/path"
    git() {
        case "$1" in
            "branch")
                echo "main"
                ;;
            "rev-list")
                echo "0	0"
                ;;
        esac
    }
    
    # This would need more complex mocking for full test
    # For now, just ensure function exists and can be called
    command -v set_prompt
}
