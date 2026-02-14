#!/bin/bash
# Test suite for make-dir-tree.sh script

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
MAKE_DIR_TREE="$PROJECT_DIR/scripts/make-dir-tree.sh"

# Source logger if available
if [ -f "$PROJECT_DIR/configs/bash/core/logger.sh" ]; then
    source "$PROJECT_DIR/configs/bash/core/logger.sh"
else
    log_info() { echo "[INFO] $*"; }
    log_success() { echo "[✓] $*"; }
    log_error() { echo "[✗] $*"; }
    log_warning() { echo "[!] $*"; }
fi

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Setup test environment
setup_test_env() {
    TEST_DIR=$(mktemp -d)
    log_info "Created test directory: $TEST_DIR"
    
    # Create test directory structure
    mkdir -p "$TEST_DIR/test-project"
    mkdir -p "$TEST_DIR/test-project/src/components"
    mkdir -p "$TEST_DIR/test-project/src/utils"
    mkdir -p "$TEST_DIR/test-project/tests"
    mkdir -p "$TEST_DIR/test-project/node_modules/package1"
    mkdir -p "$TEST_DIR/test-project/.git/hooks"
    
    # Create test files
    touch "$TEST_DIR/test-project/README.md"
    touch "$TEST_DIR/test-project/package.json"
    touch "$TEST_DIR/test-project/.gitignore"
    touch "$TEST_DIR/test-project/.env"
    touch "$TEST_DIR/test-project/src/index.js"
    touch "$TEST_DIR/test-project/src/components/Button.js"
    touch "$TEST_DIR/test-project/src/components/Input.js"
    touch "$TEST_DIR/test-project/src/utils/helpers.js"
    touch "$TEST_DIR/test-project/tests/test.js"
    touch "$TEST_DIR/test-project/node_modules/package1/index.js"
}

# Cleanup test environment
cleanup_test_env() {
    if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
        log_info "Cleaned up test directory"
    fi
}

# Test helper function
run_test() {
    local test_name="$1"
    local test_func="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    log_info "Running test: $test_name"
    
    if $test_func; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        log_success "$test_name"
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        log_error "$test_name"
    fi
}

# Assertion helper
assert_file_exists() {
    local file="$1"
    if [ -f "$file" ]; then
        return 0
    else
        log_error "File does not exist: $file"
        return 1
    fi
}

assert_file_contains() {
    local file="$1"
    local pattern="$2"
    
    if grep -q "$pattern" "$file"; then
        return 0
    else
        log_error "File does not contain pattern: $pattern"
        return 1
    fi
}

assert_file_not_contains() {
    local file="$1"
    local pattern="$2"
    
    if ! grep -q "$pattern" "$file"; then
        return 0
    else
        log_error "File should not contain pattern: $pattern"
        return 1
    fi
}

#═══════════════════════════════════════════════════════════════════════════════
# TEST CASES
#═══════════════════════════════════════════════════════════════════════════════

test_basic_tree_generation() {
    local output="$TEST_DIR/basic_output.md"
    
    "$MAKE_DIR_TREE" "$TEST_DIR/test-project" "$output" &>/dev/null
    
    assert_file_exists "$output" || return 1
    assert_file_contains "$output" "# Directory Structure" || return 1
    assert_file_contains "$output" "test-project/" || return 1
    assert_file_contains "$output" "README.md" || return 1
    assert_file_contains "$output" "src/" || return 1
    
    return 0
}

test_default_output_file() {
    cd "$TEST_DIR" || return 1
    
    "$MAKE_DIR_TREE" "$TEST_DIR/test-project" &>/dev/null
    
    assert_file_exists "$TEST_DIR/structure.md" || return 1
    
    cd - > /dev/null || return 1
    return 0
}

test_hidden_files_flag() {
    local output="$TEST_DIR/hidden_output.md"
    
    # Test WITHOUT -a flag
    "$MAKE_DIR_TREE" "$TEST_DIR/test-project" "$output" &>/dev/null
    assert_file_not_contains "$output" ".gitignore" || return 1
    assert_file_not_contains "$output" ".env" || return 1
    
    # Test WITH -a flag
    "$MAKE_DIR_TREE" -a "$TEST_DIR/test-project" "$output" &>/dev/null
    assert_file_contains "$output" ".gitignore" || return 1
    assert_file_contains "$output" ".env" || return 1
    assert_file_contains "$output" ".git/" || return 1
    
    return 0
}

test_depth_limit() {
    local output="$TEST_DIR/depth_output.md"
    
    # Test depth 1
    "$MAKE_DIR_TREE" -d 1 "$TEST_DIR/test-project" "$output" &>/dev/null
    assert_file_contains "$output" "src/" || return 1
    assert_file_not_contains "$output" "components/" || return 1
    
    # Test depth 2
    "$MAKE_DIR_TREE" -d 2 "$TEST_DIR/test-project" "$output" &>/dev/null
    assert_file_contains "$output" "src/" || return 1
    assert_file_contains "$output" "components/" || return 1
    assert_file_not_contains "$output" "Button.js" || return 1
    
    return 0
}

test_ignore_directories() {
    local output="$TEST_DIR/ignore_output.md"
    
    "$MAKE_DIR_TREE" -i "node_modules,.git" "$TEST_DIR/test-project" "$output" &>/dev/null
    
    assert_file_not_contains "$output" "node_modules/" || return 1
    assert_file_not_contains "$output" ".git/" || return 1
    assert_file_contains "$output" "src/" || return 1
    
    return 0
}

test_tree_structure_characters() {
    local output="$TEST_DIR/chars_output.md"
    
    "$MAKE_DIR_TREE" "$TEST_DIR/test-project" "$output" &>/dev/null
    
    # Check for tree characters
    assert_file_contains "$output" "├──" || return 1
    assert_file_contains "$output" "└──" || return 1
    
    return 0
}

test_help_option() {
    local help_output
    help_output=$("$MAKE_DIR_TREE" --help 2>&1)
    
    if echo "$help_output" | grep -q "Usage:"; then
        return 0
    else
        log_error "Help output does not contain 'Usage:'"
        return 1
    fi
}

test_error_nonexistent_directory() {
    local output="$TEST_DIR/error_output.md"
    local error_output
    
    error_output=$("$MAKE_DIR_TREE" "/nonexistent/directory/path" "$output" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        return 0
    else
        log_error "Should fail with non-existent directory"
        return 1
    fi
}

test_combined_flags() {
    local output="$TEST_DIR/combined_output.md"
    
    "$MAKE_DIR_TREE" -a -d 2 -i "node_modules" "$TEST_DIR/test-project" "$output" &>/dev/null
    
    # Should have hidden files
    assert_file_contains "$output" ".gitignore" || return 1
    
    # Should not have ignored directories
    assert_file_not_contains "$output" "node_modules/" || return 1
    
    # Should respect depth limit (no files in components/)
    assert_file_contains "$output" "components/" || return 1
    assert_file_not_contains "$output" "Button.js" || return 1
    
    return 0
}

#═══════════════════════════════════════════════════════════════════════════════
# MAIN TEST EXECUTION
#═══════════════════════════════════════════════════════════════════════════════

main() {
    echo "════════════════════════════════════════════════════════════════"
    echo "  Testing make-dir-tree.sh"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    
    # Check if script exists
    if [ ! -f "$MAKE_DIR_TREE" ]; then
        log_error "Script not found: $MAKE_DIR_TREE"
        exit 1
    fi
    
    # Setup
    setup_test_env
    
    # Run tests
    run_test "Basic tree generation" test_basic_tree_generation
    run_test "Default output file" test_default_output_file
    run_test "Hidden files flag (-a)" test_hidden_files_flag
    run_test "Depth limit (-d)" test_depth_limit
    run_test "Ignore directories (-i)" test_ignore_directories
    run_test "Tree structure characters" test_tree_structure_characters
    run_test "Help option (--help)" test_help_option
    run_test "Error handling (nonexistent directory)" test_error_nonexistent_directory
    run_test "Combined flags" test_combined_flags
    
    # Cleanup
    cleanup_test_env
    
    # Print results
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "  Test Results"
    echo "════════════════════════════════════════════════════════════════"
    echo "  Tests Run:    $TESTS_RUN"
    echo "  Tests Passed: $TESTS_PASSED"
    echo "  Tests Failed: $TESTS_FAILED"
    echo "════════════════════════════════════════════════════════════════"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        log_success "All tests passed!"
        exit 0
    else
        log_error "Some tests failed!"
        exit 1
    fi
}

# Trap cleanup on exit
trap cleanup_test_env EXIT

# Run main
main
