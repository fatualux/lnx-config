#!/bin/bash

# Test utilities and helper functions

# Colors for output (only define if not already set)
if [[ -z "${RED:-}" ]]; then
    RED='\033[0;31m'
fi
if [[ -z "${GREEN:-}" ]]; then
    GREEN='\033[0;32m'
fi
if [[ -z "${YELLOW:-}" ]]; then
    YELLOW='\033[1;33m'
fi
if [[ -z "${BLUE:-}" ]]; then
    BLUE='\033[0;34m'
fi
if [[ -z "${NC:-}" ]]; then
    NC='\033[0m' # No Color
fi

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Assert functions
assert_success() {
    local test_name="$1"
    local command="$2"
    
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_failure() {
    local test_name="$1"
    local command="$2"
    
    if ! eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_equals() {
    local test_name="$1"
    local expected="$2"
    local actual="$3"
    
    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name (expected: '$expected', got: '$actual')"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_file_exists() {
    local test_name="$1"
    local file="$2"
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name (file not found: $file)"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_dir_exists() {
    local test_name="$1"
    local dir="$2"
    
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name (directory not found: $dir)"
        ((TESTS_FAILED++))
        return 1
    fi
}

skip_test() {
    local test_name="$1"
    echo -e "${YELLOW}⊘${NC} $test_name (skipped)"
    ((TESTS_SKIPPED++))
}

print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_summary() {
    echo -e "\n${BLUE}=== Test Summary ===${NC}"
    echo -e "${GREEN}Passed:${NC} $TESTS_PASSED"
    echo -e "${RED}Failed:${NC} $TESTS_FAILED"
    echo -e "${YELLOW}Skipped:${NC} $TESTS_SKIPPED"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "\n${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "\n${RED}Some tests failed!${NC}"
        return 1
    fi
}


