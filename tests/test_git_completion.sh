#!/bin/bash
# Git Completion Testing Script
# Location: ~/.lnx-config/tests/test_git_completion.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source the git completion module
source "$PROJECT_ROOT/configs/bash/completion/git-completion.sh"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
test_completion() {
    local test_name="$1"
    local function_name="$2"
    local expected_contains="$3"
    
    echo -n "Testing $test_name... "
    
    if declare -f "$function_name" > /dev/null 2>&1; then
        local result=$($function_name 2>/dev/null || true)
        
        if [[ "$result" == *"$expected_contains"* ]] || [[ -z "$expected_contains" ]]; then
            echo -e "${GREEN}✓ PASS${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}✗ FAIL${NC} (Expected: $expected_contains)"
            ((TESTS_FAILED++))
        fi
    else
        echo -e "${RED}✗ FAIL${NC} (Function not found)"
        ((TESTS_FAILED++))
    fi
}

test_alias_checkout_completion() {
    local test_name="$1"

    echo -n "Testing $test_name... "

    local -a COMP_WORDS=("git" "co" "-")
    local COMP_CWORD=2
    COMPREPLY=()

    _git_advanced_complete

    if printf '%s\n' "${COMPREPLY[@]}" | grep -q -- "--track"; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC} (Expected: --track)"
        ((TESTS_FAILED++))
    fi
}

# ============================================================================
# Run Tests
# ============================================================================

echo "==========================================================================="
echo "Git Completion Module Tests"
echo "==========================================================================="
echo ""

# Test helper functions exist
echo "1. Testing Helper Functions:"
test_completion "get_local_branches" "_git_get_local_branches" ""
test_completion "get_remote_branches" "_git_get_remote_branches" ""
test_completion "get_all_branches" "_git_get_all_branches" ""
test_completion "get_tags" "_git_get_tags" ""
test_completion "get_remotes" "_git_get_remotes" ""
test_completion "get_stashes" "_git_get_stashes" ""
test_completion "get_subcommands" "_git_get_subcommands" ""
echo ""

# Test completion functions for specific commands
echo "2. Testing Command-Specific Completions:"
test_completion "add command" "_git_complete_add" "--all"
test_completion "checkout command" "_git_complete_checkout" "--track"
test_alias_checkout_completion "alias co -> checkout"
test_completion "commit command" "_git_complete_commit" "--message"
test_completion "branch command" "_git_complete_branch" "--list"
test_completion "merge command" "_git_complete_merge" "--no-ff"
test_completion "push command" "_git_complete_push" "--force"
test_completion "pull command" "_git_complete_pull" "--rebase"
test_completion "fetch command" "_git_complete_fetch" "--all"
test_completion "reset command" "_git_complete_reset" "--hard"
test_completion "rebase command" "_git_complete_rebase" "--interactive"
test_completion "tag command" "_git_complete_tag" "--annotate"
test_completion "stash command" "_git_complete_stash" "list"
test_completion "remote command" "_git_complete_remote" "add"
test_completion "config command" "_git_complete_config" "--global"
test_completion "log command" "_git_complete_log" "--oneline"
test_completion "diff command" "_git_complete_diff" "--stat"
test_completion "show command" "_git_complete_show" "--patch"
test_completion "clone command" "_git_complete_clone" "--depth"
test_completion "status command" "_git_complete_status" "--short"
echo ""

# Test main completion function registration
echo "3. Testing Main Completion Function:"
if declare -f "_git_advanced_complete" > /dev/null 2>&1; then
    echo -e "Testing main completion function... ${GREEN}✓ PASS${NC}"
    ((TESTS_PASSED++))
else
    echo -e "Testing main completion function... ${RED}✗ FAIL${NC}"
    ((TESTS_FAILED++))
fi
echo ""

# ============================================================================
# Summary
# ============================================================================
echo "==========================================================================="
echo "Test Summary"
echo "==========================================================================="
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed!${NC}"
    exit 1
fi
