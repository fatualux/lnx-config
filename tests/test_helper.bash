#!/usr/bin/env bash

# Test helper functions for Bats tests

# Setup test environment
setup() {
    # Create temporary directory for tests
    TEST_TEMP_DIR=$(mktemp -d)
    export TEST_TEMP_DIR
    
    # Set test environment variables
    export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    export BACKUP_DIR="$TEST_TEMP_DIR/backups"
    export HOME="$TEST_TEMP_DIR/home"
    
    # Set flags to prevent bind commands in tests
    export IN_BATS_TEST=1
    
    # Create home directory
    mkdir -p "$HOME"
    
    # Source installer modules with proper test guards
    source "$SCRIPT_DIR/src/colors.sh"
    source "$SCRIPT_DIR/src/logger.sh"
    source "$SCRIPT_DIR/src/spinner.sh"
    
    # Source installer functions (but not main)
    source "$SCRIPT_DIR/installer.sh" 2>/dev/null || true
    
    # Override main to prevent execution
    main() {
        return 0
    }
}

# Cleanup test environment
teardown() {
    # Remove temporary directory
    rm -rf "$TEST_TEMP_DIR"
}

# Mock function to replace system commands
mock() {
    local command="$1"
    local output="$2"
    local return_code="${3:-0}"
    
    eval "$command() { echo '$output'; return $return_code; }"
}

# Helper to create test files
create_test_file() {
    local path="$1"
    local content="${2:-test content}"
    
    mkdir -p "$(dirname "$path")"
    echo "$content" > "$path"
}

# Helper to check if file exists and contains content
assert_file_exists() {
    local file="$1"
    [ -f "$file" ] || {
        echo "File does not exist: $file"
        return 1
    }
}

assert_file_contains() {
    local file="$1"
    local content="$2"
    
    assert_file_exists "$file"
    grep -q "$content" "$file" || {
        echo "File '$file' does not contain '$content'"
        return 1
    }
}

# Helper to simulate git repository
init_git_repo() {
    local dir="$1"
    
    cd "$dir"
    git init >/dev/null 2>&1
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create initial commit
    echo "test" > test.txt
    git add test.txt
    git commit -m "Initial commit" >/dev/null 2>&1
}
