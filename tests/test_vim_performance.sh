#!/bin/bash

# Test vim configuration performance and functionality
# Tests the optimized vim configuration for performance improvements

set -euo pipefail

# Source the logging utility
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../applications/core/logging.sh"

# Test configuration - configurable via environment variables
TEST_DIR="${VIM_TEST_DIR:-/tmp/vim_config_test_$$}"
VIM_CONFIG_DIR="${VIM_CONFIG_PATH:-$SCRIPT_DIR/../configs/vim}"
STARTUP_TIME_THRESHOLD="${VIM_STARTUP_THRESHOLD:-2000}"  # milliseconds
PLUGIN_LOAD_THRESHOLD="${VIM_PLUGIN_THRESHOLD:-5000}"    # milliseconds

# Resolve absolute path for vim config
if [[ ! -d "$VIM_CONFIG_DIR" ]]; then
    # Try alternative path resolution
    VIM_CONFIG_DIR="$SCRIPT_DIR/../configs/vim"
fi
if [[ ! -d "$VIM_CONFIG_DIR" ]]; then
    # Fallback to current working directory
    VIM_CONFIG_DIR="$(pwd)/configs/vim"
fi

# Check for required dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v vim &> /dev/null; then
        missing_deps+=("vim")
    fi
    
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    if ! command -v bc &> /dev/null; then
        log_warning "bc command not found - some tests may be skipped"
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        return 1
    fi
    
    return 0
}

# Colors for output - use local variables to avoid conflicts
setup_colors() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local NC='\033[0m' # No Color
}

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Helper functions
log_test_result() {
    local test_name="$1"
    local result="$2"
    local message="${3:-}"
    
    # Define colors locally with different names to avoid conflicts
    local TEST_RED='\033[0;31m'
    local TEST_GREEN='\033[0;32m'
    local TEST_YELLOW='\033[1;33m'
    local TEST_NC='\033[0m' # No Color
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    if [[ "$result" == "PASS" ]]; then
        echo -e "${TEST_GREEN}✓ PASS${TEST_NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${TEST_RED}✗ FAIL${TEST_NC} $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        [[ -n "$message" ]] && echo -e "  ${TEST_YELLOW}→${TEST_NC} $message"
    fi
}

setup_test_environment() {
    log_info "Setting up test environment..."
    log_info "VIM_CONFIG_DIR: $VIM_CONFIG_DIR"
    
    # Create test directory
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Create a minimal test vimrc that sources our config
    cat > test_vimrc << EOF
set runtimepath^=/tmp/vim_config_test_$$/vim_config
source /tmp/vim_config_test_$$/vim_config/.vimrc
EOF
    
    # Copy vim config to test directory
    if [[ ! -d "$VIM_CONFIG_DIR" ]]; then
        log_error "VIM_CONFIG_DIR does not exist: $VIM_CONFIG_DIR"
        return 1
    fi
    
    log_info "Copying vim config from $VIM_CONFIG_DIR to $TEST_DIR/vim_config"
    cp -r "$VIM_CONFIG_DIR" ./vim_config
    
    # Initialize git repo for testing git branch functionality
    git init > /dev/null 2>&1
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    log_success "Test environment setup complete"
}

cleanup_test_environment() {
    log_info "Cleaning up test environment..."
    cd /
    rm -rf "$TEST_DIR"
    log_success "Test environment cleaned up"
}

test_vim_startup_time() {
    log_info "Testing Vim startup time..."
    
    # Measure startup time in milliseconds
    local startup_time
    startup_time=$(timeout 10s vim -es -u "$TEST_DIR/test_vimrc" -c 'qa!' 2>&1 | \
        grep -o '[0-9]\+\.[0-9]\+' | head -1 || echo "999999")
    
    # Convert to milliseconds (remove decimal)
    startup_time=$(echo "$startup_time * 1000" | bc 2>/dev/null || echo "999999")
    
    if (( startup_time <= STARTUP_TIME_THRESHOLD )); then
        log_test_result "Vim Startup Time" "PASS" "${startup_time}ms (threshold: ${STARTUP_TIME_THRESHOLD}ms)"
    else
        log_test_result "Vim Startup Time" "FAIL" "${startup_time}ms exceeds threshold of ${STARTUP_TIME_THRESHOLD}ms"
    fi
}

test_plugin_loading() {
    log_info "Testing plugin loading performance..."
    
    # Test if plugins load without errors
    local plugin_output
    plugin_output=$(timeout 15s vim -es -u "$TEST_DIR/test_vimrc" \
        -c 'try | PlugInstall | catch | echo "Plugin error: " . v:exception | endtry' \
        -c 'qa!' 2>&1 || echo "Timeout or error")
    
    if [[ "$plugin_output" == *"Plugin error"* ]] || [[ "$plugin_output" == *"Timeout"* ]]; then
        log_test_result "Plugin Loading" "FAIL" "Plugin loading errors detected"
    else
        log_test_result "Plugin Loading" "PASS"
    fi
}

test_git_branch_caching() {
    log_info "Testing git branch caching functionality..."
    
    # Create a git branch for testing
    git checkout -b test-branch >/dev/null 2>&1
    
    # Test git branch detection
    local branch_output
    branch_output=$(timeout 5s vim -es -u "$TEST_DIR/test_vimrc" \
        -c 'echo b:git_current_branch' \
        -c 'qa!' 2>&1 || echo "")
    
    if [[ "$branch_output" == *"test-branch"* ]]; then
        log_test_result "Git Branch Detection" "PASS"
    else
        log_test_result "Git Branch Detection" "FAIL" "Could not detect git branch properly"
    fi
}

test_syntax_highlighting() {
    log_info "Testing syntax highlighting performance..."
    
    # Create a test file with various content
    cat > test_file.py << 'EOF'
#!/usr/bin/env python3
"""Test Python file for syntax highlighting."""

import os
import sys
from typing import List, Dict

def test_function(param1: str, param2: int) -> bool:
    """Test function with syntax elements."""
    if param1 and param2 > 0:
        return True
    return False

class TestClass:
    """Test class for syntax highlighting."""
    
    def __init__(self):
        self.value = 42
    
    def method(self) -> None:
        print(f"Value: {self.value}")

if __name__ == "__main__":
    obj = TestClass()
    obj.method()
EOF
    
    # Test syntax highlighting doesn't cause delays
    local syntax_time
    syntax_time=$(timeout 5s vim -es -u "$TEST_DIR/test_vimrc" \
        -c 'syntax on' \
        -c 'set filetype=python' \
        -c 'qa!' 2>&1 | grep -o '[0-9]\+\.[0-9]\+' | head -1 || echo "0")
    
    if [[ -n "$syntax_time" ]] && (( $(echo "$syntax_time < 1.0" | bc -l 2>/dev/null || echo 0) )); then
        log_test_result "Syntax Highlighting" "PASS"
    else
        log_test_result "Syntax Highlighting" "FAIL" "Syntax highlighting taking too long"
    fi
}

test_autocommand_optimization() {
    log_info "Testing autocommand optimizations..."
    
    # Test that autocmds don't fire excessively
    local autocmd_test
    autocmd_test=$(timeout 5s vim -es -u "$TEST_DIR/test_vimrc" \
        -c 'let test_count = 0' \
        -c 'autocmd BufEnter * let test_count += 1' \
        -c 'edit test_file.py' \
        -c 'edit test_file2.py' \
        -c 'echo test_count' \
        -c 'qa!' 2>&1 || echo "0")
    
    # Should have minimal autocmd firings due to optimizations
    if [[ "$autocmd_test" =~ [0-9]+ ]] && [[ "${BASH_REMATCH[0]}" -le 4 ]]; then
        log_test_result "Autocommand Optimization" "PASS"
    else
        log_test_result "Autocommand Optimization" "FAIL" "Too many autocmd firings: $autocmd_test"
    fi
}

test_memory_usage() {
    log_info "Testing memory usage..."
    
    # Test vim doesn't consume excessive memory
    local memory_usage
    memory_usage=$(timeout 5s vim -es -u "$TEST_DIR/test_vimrc" \
        -c 'edit test_file.py' \
        -c 'lua print(collectgarbage("count"))' \
        -c 'qa!' 2>&1 | grep -o '[0-9]\+\.[0-9]\+' | head -1 || echo "999")
    
    # Convert to MB (Lua returns KB)
    memory_usage=$(echo "scale=2; $memory_usage / 1024" | bc 2>/dev/null || echo "999")
    
    if (( $(echo "$memory_usage < 50" | bc -l 2>/dev/null || echo 0) )); then
        log_test_result "Memory Usage" "PASS" "${memory_usage}MB"
    else
        log_test_result "Memory Usage" "FAIL" "${memory_usage}MB exceeds threshold"
    fi
}

run_all_tests() {
    log_info "Starting Vim configuration performance tests..."
    echo
    
    # Check dependencies first
    if ! check_dependencies; then
        log_error "Dependency check failed. Please install missing dependencies."
        return 1
    fi
    
    setup_test_environment
    
    # Run all tests
    test_vim_startup_time
    test_plugin_loading
    test_git_branch_caching
    test_syntax_highlighting
    test_autocommand_optimization
    test_memory_usage
    
    cleanup_test_environment
    
    # Print summary
    echo
    log_info "Test Summary:"
    echo -e "  Total Tests: $TESTS_TOTAL"
    
    # Define colors locally with different names
    local TEST_RED='\033[0;31m'
    local TEST_GREEN='\033[0;32m'
    local TEST_NC='\033[0m'
    
    echo -e "  ${TEST_GREEN}Passed: $TESTS_PASSED${TEST_NC}"
    echo -e "  ${TEST_RED}Failed: $TESTS_FAILED${TEST_NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${TEST_GREEN}✓ All tests passed!${TEST_NC}"
        return 0
    else
        echo -e "\n${TEST_RED}✗ Some tests failed.${TEST_NC}"
        return 1
    fi
}

# Main execution
main() {
    case "${1:-run}" in
        "run")
            run_all_tests
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [run|help]"
            echo "  run  - Run all vim configuration tests (default)"
            echo "  help - Show this help message"
            ;;
        *)
            log_error "Unknown command: $1"
            echo "Use '$0 help' for usage information."
            exit 1
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
