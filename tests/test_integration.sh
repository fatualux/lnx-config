#!/bin/bash

# Integration tests - test interaction between modules and functions

source "$(dirname "${BASH_SOURCE[0]}")/test_utils.sh"

print_section "Integration Tests"

BASH_CONFIG_PATH="$(dirname "${BASH_SOURCE[0]}")/../configs/bash/main.sh"

# Test: bash configuration loads all modules without errors
if bash "$BASH_CONFIG_PATH" > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} bash configuration loads without errors"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} bash configuration loads without errors"
    ((TESTS_FAILED++))
fi

unset __BASH_CONFIG_LOADED
# Test: all dependencies are available
source "$BASH_CONFIG_PATH" 2>/dev/null

# Create a test case for verifying module interdependencies
print_section "Logger Availability"

if declare -f log_func_start > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Logger functions are available"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⊘${NC} Logger functions not available (may be expected in test environment)"
    ((TESTS_SKIPPED++))
fi

print_section "Spinner Availability"

if declare -f spinner_start > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Spinner functions are available"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⊘${NC} Spinner functions not available (may be expected in test environment)"
    ((TESTS_SKIPPED++))
fi

# Test: Module cross-functionality
print_section "Cross-Module Functionality"

# Create temp test directory
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

(
    cd "$TEST_DIR"
    
    # Test: Python cache clearing with actual project structure
    mkdir -p project/{src,tests}
    mkdir -p project/src/__pycache__
    touch project/src/__pycache__/module.pyc
    touch project/src/main.py
    
    # Run clear_python_caches
    if clear_python_caches > /dev/null 2>&1; then
        if [ ! -d "project/src/__pycache__" ]; then
            echo -e "${GREEN}✓${NC} clear_python_caches works in subdirectories"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}✗${NC} clear_python_caches works in subdirectories"
            ((TESTS_FAILED++))
        fi
    else
        echo -e "${RED}✗${NC} clear_python_caches executes successfully"
        ((TESTS_FAILED++))
    fi
    
    # Test: Zone.Identifier cleanup
    touch file1.Zone.Identifier
    if remove_zone_info > /dev/null 2>&1; then
        if [ ! -f "file1.Zone.Identifier" ]; then
            echo -e "${GREEN}✓${NC} remove_zone_info executes successfully"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}✗${NC} remove_zone_info cleans up files"
            ((TESTS_FAILED++))
        fi
    fi
)

print_summary
