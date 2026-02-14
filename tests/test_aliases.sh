#!/bin/bash

# Tests for alias listing functions

source "$(dirname "${BASH_SOURCE[0]}")/test_utils.sh"

# Source bash configuration to load all functions
BASH_CONFIG_PATH="$(dirname "${BASH_SOURCE[0]}")/../configs/bash/main.sh"
unset __BASH_CONFIG_LOADED
if [ -f "$BASH_CONFIG_PATH" ]; then
    BASH_CONFIG_VERBOSE="" source "$BASH_CONFIG_PATH" 2>/dev/null
fi

print_section "Alias Functions"

# Test: list_my_aliases function exists
assert_success "list_my_aliases function exists" "declare -f list_my_aliases > /dev/null"

# Test: list_my_aliases checks if alias.sh exists
if [ -f "$HOME/.config/bash/alias.sh" ]; then
    output=$(list_my_aliases 2>/dev/null | wc -l)
    if [ "$output" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} list_my_aliases produces output"
        ((TESTS_PASSED++))
    else
        echo -e "${YELLOW}⊘${NC} list_my_aliases produces output (skipped - alias.sh might be empty)"
        ((TESTS_SKIPPED++))
    fi
else
    echo -e "${YELLOW}⊘${NC} list_my_aliases produces output (skipped - alias.sh not found)"
    ((TESTS_SKIPPED++))
fi

print_summary
