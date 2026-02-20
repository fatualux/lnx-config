#!/bin/bash

# Test utility functions

# Colors for test output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Print test section
print_section() {
    echo ""
    echo "=== $1 ==="
}

# Assert file exists
assert_file_exists() {
    local test_name="$1"
    local file_path="$2"
    
    if [[ -f "$file_path" ]]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name - File not found: $file_path"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Assert command succeeds
assert_success() {
    local test_name="$1"
    local command="$2"
    
    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $test_name - Command failed: $command"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Print test summary
print_summary() {
    echo ""
    echo "Test Summary:"
    echo "  Passed: $TESTS_PASSED"
    echo "  Failed: $TESTS_FAILED"
    echo "  Skipped: $TESTS_SKIPPED"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        return 1
    fi
}
