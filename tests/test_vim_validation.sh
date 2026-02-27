#!/bin/bash

# Test file for vim validation functionality
# Tests both scenarios: vim available and vim not available

set -euo pipefail

# Source the install module to test
source "$(dirname "${BASH_SOURCE[0]}")/../src/install.sh"

# Test 1: vim not available - should skip gracefully
test_vim_not_available() {
    echo "Testing vim validation when vim is not available..."
    
    # Mock command -v to return failure for vim
    command() {
        if [[ "$1" == "-v" && "$2" == "vim" ]]; then
            return 1  # vim not found
        fi
        # Forward other command calls to real command
        /usr/bin/command "$@"
    }
    export -f command
    
    # Mock vim command to not exist
    vim() {
        echo "vim: command not found" >&2
        return 127
    }
    export -f vim
    
    # This should not fail and should log appropriate message
    if validate_vim_syntax "/tmp/test.vimrc"; then
        echo "✓ PASS: vim validation skipped gracefully when vim not available"
        return 0
    else
        echo "✗ FAIL: vim validation should not fail when vim not available"
        return 1
    fi
}

# Test 2: vim available - should validate normally
test_vim_available() {
    echo "Testing vim validation when vim is available..."
    
    # Mock command -v to return success for vim
    command() {
        if [[ "$1" == "-v" && "$2" == "vim" ]]; then
            return 0  # vim found
        fi
        # Forward other command calls to real command
        /usr/bin/command "$@"
    }
    export -f command
    
    # Mock vim command to exist and succeed
    vim() {
        if [[ "$1" == "-c" && "$2" == "syntax check" ]]; then
            return 0  # Success
        fi
        return 0
    }
    export -f vim
    
    # This should succeed
    if validate_vim_syntax "/tmp/test.vimrc"; then
        echo "✓ PASS: vim validation succeeded when vim available"
        return 0
    else
        echo "✗ FAIL: vim validation should succeed when vim available"
        return 1
    fi
}

# Test 3: vim available but syntax error - should fail gracefully
test_vim_syntax_error() {
    echo "Testing vim validation when vim finds syntax error..."
    
    # Mock command -v to return success for vim
    command() {
        if [[ "$1" == "-v" && "$2" == "vim" ]]; then
            return 0  # vim found
        fi
        # Forward other command calls to real command
        /usr/bin/command "$@"
    }
    export -f command
    
    # Mock vim command to exist but fail syntax check
    vim() {
        if [[ "$1" == "-c" && "$2" == "syntax check" ]]; then
            echo "Error: Invalid syntax at line 10" >&2
            return 1  # Syntax error
        fi
        return 0
    }
    export -f vim
    
    # This should fail but not crash
    if ! validate_vim_syntax "/tmp/test.vimrc"; then
        echo "✓ PASS: vim validation failed gracefully with syntax error"
        return 0
    else
        echo "✗ FAIL: vim validation should fail with syntax error"
        return 1
    fi
}

# Run tests
echo "Running vim validation tests..."
echo "================================"

# Create test vimrc file
echo "set number" > /tmp/test.vimrc

test_vim_not_available
test_vim_available  
test_vim_syntax_error

# Cleanup
rm -f /tmp/test.vimrc

echo "All tests completed!"
