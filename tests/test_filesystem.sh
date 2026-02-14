#!/bin/bash

# Tests for file system utility functions

source "$(dirname "${BASH_SOURCE[0]}")/test_utils.sh"

# Source bash configuration to load all functions
BASH_CONFIG_PATH="$(dirname "${BASH_SOURCE[0]}")/../configs/bash/main.sh"
unset __BASH_CONFIG_LOADED
if [ -f "$BASH_CONFIG_PATH" ]; then
    BASH_CONFIG_VERBOSE="" source "$BASH_CONFIG_PATH" 2>/dev/null
fi

print_section "File System Functions"

# Test: clear_python_caches - should exist and be a function
assert_success "clear_python_caches function exists" "declare -f clear_python_caches > /dev/null"

# Test: remove_zone_info - should exist and be a function
assert_success "remove_zone_info function exists" "declare -f remove_zone_info > /dev/null"

# Create a temporary directory for testing clear_python_caches
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# Test: clear_python_caches with test directories
(
    cd "$TEST_DIR"
    mkdir -p test_project/{__pycache__,.mypy_cache,.pytest_cache}
    touch test_project/{file1.pyc,file2.pyc}
    
    # Run the function
    clear_python_caches
    
    # Check if directories were removed
    if [ ! -d "test_project/__pycache__" ] && [ ! -d "test_project/.mypy_cache" ]; then
        echo -e "${GREEN}✓${NC} clear_python_caches removes cache directories"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} clear_python_caches removes cache directories"
        ((TESTS_FAILED++))
    fi
    
    # Check if .pyc files were removed
    if [ ! -f "test_project/file1.pyc" ] && [ ! -f "test_project/file2.pyc" ]; then
        echo -e "${GREEN}✓${NC} clear_python_caches removes .pyc files"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} clear_python_caches removes .pyc files"
        ((TESTS_FAILED++))
    fi
)

# Test: remove_zone_info with test files
(
    cd "$TEST_DIR"
    touch file1.txt.Zone.Identifier
    touch file2.Zone.Identifier
    
    # Run the function
    remove_zone_info
    
    # Check if Zone.Identifier files were removed
    if [ ! -f "file1.txt.Zone.Identifier" ] && [ ! -f "file2.Zone.Identifier" ]; then
        echo -e "${GREEN}✓${NC} remove_zone_info removes Zone.Identifier files"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} remove_zone_info removes Zone.Identifier files"
        ((TESTS_FAILED++))
    fi
)

# Test: code_directory - function should exist
assert_success "code_directory function exists" "declare -f code_directory > /dev/null"

print_summary
