#!/bin/bash

# Tests for autocomplete module

source "$(dirname "${BASH_SOURCE[0]}")/test_utils.sh"

print_section "Autocomplete Module Tests"

CONFIG_DIR="$(dirname "${BASH_SOURCE[0]}")/../configs/bash"
COMPLETION_DIR="$CONFIG_DIR/completion"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/bash-smart-complete"

assert_dir_exists "completion directory exists" "$COMPLETION_DIR"
assert_file_exists "autocomplete.sh exists" "$COMPLETION_DIR/autocomplete.sh"

print_section "Module Syntax Validation"
assert_success "autocomplete.sh syntax OK" "bash -n \"$COMPLETION_DIR/autocomplete.sh\""

print_section "Smart Completion Functions"

# Test option extraction
assert_success "_smart_extract_opts function exists" "bash -c 'source \"$COMPLETION_DIR/autocomplete.sh\" && declare -f _smart_extract_opts > /dev/null'"

# Test git completion
assert_success "_smart_git_complete function exists" "bash -c 'source \"$COMPLETION_DIR/autocomplete.sh\" && declare -f _smart_git_complete > /dev/null'"

# Test universal completion
assert_success "_smart_complete function exists" "bash -c 'source \"$COMPLETION_DIR/autocomplete.sh\" && declare -f _smart_complete > /dev/null'"

print_section "Caching System"

# Test cache directory creation
bash -c "source \"$COMPLETION_DIR/autocomplete.sh\" && _smart_extract_opts docker > /dev/null" 2>&1

if [[ -d "$CACHE_DIR" ]]; then
    echo -e "${GREEN}✓${NC} cache directory created"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} cache directory not created"
    ((TESTS_FAILED++))
fi

# Test cache file generation
if [[ -f "$CACHE_DIR/docker.opts" ]]; then
    echo -e "${GREEN}✓${NC} docker.opts cache file created"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} docker.opts cache file not created"
    ((TESTS_FAILED++))
fi

# Test cache contains valid options
if grep -q "^--" "$CACHE_DIR/docker.opts" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} cache contains valid options"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} cache doesn't contain valid options"
    ((TESTS_FAILED++))
fi

print_section "Git Specific Features"

# Test git cache generation
bash -c "source \"$COMPLETION_DIR/autocomplete.sh\" && _smart_extract_opts git > /dev/null" 2>&1

if [[ -f "$CACHE_DIR/git.opts" ]] && grep -q "^--" "$CACHE_DIR/git.opts"; then
    echo -e "${GREEN}✓${NC} git options extracted and cached"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} git options not properly cached"
    ((TESTS_FAILED++))
fi

print_summary
