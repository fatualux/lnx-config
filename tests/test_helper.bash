#!/usr/bin/env bash

# Test Helper Functions for lnx-config
# Provides common utilities for all test files

set -euo pipefail

# Test configuration
TEST_TEMP_DIR="$(mktemp -d)"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DATA_DIR="${PROJECT_ROOT}/tests/test-data"

# Cleanup function
cleanup() {
    rm -rf "$TEST_TEMP_DIR"
}
trap cleanup EXIT

# Source project modules
source "${PROJECT_ROOT}/src/logger.sh"
source "${PROJECT_ROOT}/src/colors.sh"

# Helper functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Expected '$expected' but got '$actual'}"
    
    if [[ "$expected" == "$actual" ]]; then
        return 0
    else
        echo "FAIL: $message" >&2
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Expected '$needle' to be in '$haystack'}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        return 0
    else
        echo "FAIL: $message" >&2
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-Expected file '$file' to exist"}"
    
    if [[ -f "$file" ]]; then
        return 0
    else
        echo "FAIL: $message" >&2
        return 1
    fi
}

assert_command_success() {
    local cmd="$1"
    local message="${2:-"Expected command '$cmd' to succeed"}"
    
    if eval "$cmd" >/dev/null 2>&1; then
        return 0
    else
        echo "FAIL: $message" >&2
        return 1
    fi
}

# Mock functions for testing
mock_apt() {
    echo "Mock apt: $*"
}

mock_git() {
    echo "Mock git: $*"
}

# Setup test environment
setup_test_env() {
    export TEST_MODE=1
    # Don't override HOME - keep original for file access
    export TEST_HOME="$TEST_TEMP_DIR/home"
    mkdir -p "$TEST_HOME"
    
    # Create mock system binaries
    mkdir -p "$TEST_TEMP_DIR/bin"
    cat > "$TEST_TEMP_DIR/bin/apt" << 'EOF'
#!/bin/bash
echo "Mock apt: $*"
EOF
    cat > "$TEST_TEMP_DIR/bin/git" << 'EOF'
#!/bin/bash
echo "Mock git: $*"
EOF
    chmod +x "$TEST_TEMP_DIR/bin"/*
    
    export PATH="$TEST_TEMP_DIR/bin:$PATH"
}

# Create test data directories
setup_test_data() {
    mkdir -p "$TEST_DATA_DIR"
    mkdir -p "$TEST_DATA_DIR/configs"
    mkdir -p "$TEST_DATA_DIR/src"
}

log_test_start() {
    echo "🧪 Starting: $1"
}

log_test_pass() {
    echo "✅ PASS: $1"
}

log_test_fail() {
    echo "❌ FAIL: $1"
}
