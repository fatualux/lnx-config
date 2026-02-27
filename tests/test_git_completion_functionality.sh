#!/bin/bash

# Test actual git completion functionality
# Tests the git autocompletion after installation

set -euo pipefail

echo "Testing actual git completion functionality..."

# Test 1: Verify git completion functions are available in actual environment
test_git_completion_in_real_env() {
    echo "Testing git completion in real environment..."
    
    # Source the actual git-autocompletion.sh file
    if [[ -f "/root/lnx-config/configs/core/bash/git-autocompletion.sh" ]]; then
        echo "Sourcing git-autocompletion.sh..."
        
        # Use bash -c to source in a subshell and check functions
        local result
        result=$(bash -c 'source "/root/lnx-config/configs/core/bash/git-autocompletion.sh"; declare -f _git >/dev/null && echo "YES" || echo "NO"')
        
        if [[ "$result" == "YES" ]]; then
            echo "✓ PASS: _git function is available"
        else
            echo "✗ FAIL: _git function is NOT available"
            return 1
        fi
        
        result=$(bash -c 'source "/root/lnx-config/configs/core/bash/git-autocompletion.sh"; declare -f _git_flow >/dev/null && echo "YES" || echo "NO"')
        
        if [[ "$result" == "YES" ]]; then
            echo "✓ PASS: _git_flow function is available"
        else
            echo "✗ FAIL: _git_flow function is NOT available"
            return 1
        fi
        
        result=$(bash -c 'source "/root/lnx-config/configs/core/bash/git-autocompletion.sh"; declare -f __git_ps1 >/dev/null && echo "YES" || echo "NO"')
        
        if [[ "$result" == "YES" ]]; then
            echo "✓ PASS: __git_ps1 function is available"
        else
            echo "✗ FAIL: __git_ps1 function is NOT available"
            return 1
        fi
        
        return 0
    else
        echo "✗ FAIL: git-autocompletion.sh file not found"
        return 1
    fi
}

# Test 2: Test __git_ps1 function output
test_git_ps1_function() {
    echo "Testing __git_ps1 function output..."
    
    # Source the git autocompletion
    source "/root/lnx-config/configs/core/bash/git-autocompletion.sh"
    
    # Test __git_ps1 in a non-git directory (should return empty)
    local result
    result=$(__git_ps1)
    if [[ -z "$result" ]]; then
        echo "✓ PASS: __git_ps1 returns empty string outside git repository"
    else
        echo "✗ FAIL: __git_ps1 should return empty outside git repo, got: '$result'"
        return 1
    fi
    
    # Test __git_ps1 in a git directory (if we're in one)
    if git rev-parse --git-dir >/dev/null 2>&1; then
        result=$(__git_ps1)
        if [[ -n "$result" ]]; then
            echo "✓ PASS: __git_ps1 returns non-empty string in git repository: '$result'"
        else
            echo "✗ FAIL: __git_ps1 should return non-empty in git repo"
            return 1
        fi
    else
        echo "ℹ️  INFO: Not in a git repository, skipping git repo test"
    fi
    
    return 0
}

# Test 3: Test git completion registration
test_completion_registration() {
    echo "Testing git completion registration..."
    
    # Source the git autocompletion
    source "/root/lnx-config/configs/core/bash/git-autocompletion.sh"
    
    # Check if git completion is registered
    local completion_output
    completion_output=$(complete -p git 2>/dev/null || echo "not registered")
    
    if [[ "$completion_output" != "not registered" ]]; then
        echo "✓ PASS: git completion is registered"
        echo "  Registration: $completion_output"
    else
        echo "✗ FAIL: git completion is not registered"
        return 1
    fi
    
    # Check if git-flow completion is registered
    completion_output=$(complete -p git-flow 2>/dev/null || echo "not registered")
    
    if [[ "$completion_output" != "not registered" ]]; then
        echo "✓ PASS: git-flow completion is registered"
        echo "  Registration: $completion_output"
    else
        echo "✗ FAIL: git-flow completion is not registered"
        return 1
    fi
    
    return 0
}

# Test 4: Test git completion initialization
test_completion_initialization() {
    echo "Testing git completion initialization..."
    
    # Source the git autocompletion
    source "/root/lnx-config/configs/core/bash/git-autocompletion.sh"
    
    # Test the initialization function
    if _git_completion_initialize; then
        echo "✓ PASS: _git_completion_initialize executed successfully"
    else
        echo "✗ FAIL: _git_completion_initialize failed"
        return 1
    fi
    
    # Check if git completion functions are now available
    if declare -f _git >/dev/null; then
        echo "✓ PASS: _git function available after initialization"
    else
        echo "✗ FAIL: _git function not available after initialization"
        return 1
    fi
    
    return 0
}

# Run tests
echo "Running git completion functionality tests..."
echo "=========================================="

test_git_completion_in_real_env
test_git_ps1_function
test_completion_registration
test_completion_initialization

echo "All functionality tests completed!"
