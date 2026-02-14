#!/bin/bash

# Main test runner - runs all test suites

# set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$SCRIPT_DIR/tests"
BASH_CONFIG_PATH="$SCRIPT_DIR/configs/bash/main.sh"

# Colors (use local names to avoid readonly collisions)
TEST_GREEN='\033[0;32m'
TEST_RED='\033[0;31m'
TEST_BLUE='\033[0;34m'
TEST_YELLOW='\033[1;33m'
TEST_NC='\033[0m'

# Verbosity (default: verbose)
VERBOSE=1
QUIET=0
if [[ "$1" == "-q" || "$1" == "--quiet" ]]; then
    VERBOSE=0
    QUIET=1
elif [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
    VERBOSE=1
fi

RUN_ID="$(date +%Y%m%d_%H%M%S)"
LOG_DIR="$TESTS_DIR/logs"
mkdir -p "$LOG_DIR"

echo -e "${TEST_BLUE}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║          Bash Custom Functions Test Suite                 ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${TEST_NC}"

# Source bash configuration for all tests
unset __BASH_CONFIG_LOADED
source "$BASH_CONFIG_PATH" 2>/dev/null

# Track overall stats
TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_SKIPPED=0
FAILED_TESTS=()
PASSED_TESTS=()

USE_SPINNER=0
# if declare -f spinner_start >/dev/null 2>&1; then
#     USE_SPINNER=1
# fi

# Run each test file
test_files=(
    "test_modules.sh"
    "test_autocomplete.sh"
    "test_readline.sh"
    "test_filesystem.sh"
    "test_aliases.sh"
    "test_music.sh"
    "test_docker.sh"
    "test_wsl_interop.sh"
)

for test_file in "${test_files[@]}"; do
    test_path="$TESTS_DIR/$test_file"
    if [ -f "$test_path" ]; then
        echo ""
        log_file="$LOG_DIR/${test_file%.sh}_${RUN_ID}.log"
        echo -e "${TEST_BLUE}→ Running ${test_file}${TEST_NC}"

        if [ $VERBOSE -eq 1 ]; then
            bash "$test_path" 2>&1 | tee "$log_file"
            exit_code=${PIPESTATUS[0]}
        else
            bash "$test_path" > "$log_file" 2>&1
            exit_code=$?
        fi

        if [ $exit_code -eq 0 ]; then
            echo -e "${TEST_GREEN}✓${TEST_NC} ${test_file} completed successfully"
            ((TOTAL_PASSED++))
            PASSED_TESTS+=("$test_file")
        else
            echo -e "${TEST_RED}✗${TEST_NC} ${test_file} failed (see log: $log_file)"
            ((TOTAL_FAILED++))
            FAILED_TESTS+=("$test_file")
            if [ $QUIET -eq 1 ]; then
                echo -e "${TEST_YELLOW}Last 20 log lines:${TEST_NC}"
                tail -n 20 "$log_file" | sed 's/^/  /'
                echo ""
            fi
        fi
    else
        echo -e "${TEST_RED}Warning: Test file $test_file not found${TEST_NC}"
        ((TOTAL_FAILED++))
        FAILED_TESTS+=("$test_file (missing)")
    fi
done

echo -e "${TEST_BLUE}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                   Test Run Complete                       ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${TEST_NC}"

echo -e "${TEST_BLUE}Logs:${TEST_NC} $LOG_DIR"

if [ $TOTAL_FAILED -eq 0 ]; then
    echo -e "\n${TEST_GREEN}███████████████████████████████████████████████████████████${TEST_NC}"
    echo -e "${TEST_GREEN}✓ ALL TEST SUITES PASSED${TEST_NC}"
    echo -e "${TEST_GREEN}Passed:${TEST_NC} $TOTAL_PASSED  ${TEST_RED}Failed:${TEST_NC} $TOTAL_FAILED  ${TEST_YELLOW}Skipped:${TEST_NC} $TOTAL_SKIPPED"
    echo -e "${TEST_GREEN}███████████████████████████████████████████████████████████${TEST_NC}\n"
else
    echo -e "\n${TEST_RED}███████████████████████████████████████████████████████████${TEST_NC}"
    echo -e "${TEST_RED}✗ SOME TEST SUITES FAILED${TEST_NC}"
    echo -e "${TEST_GREEN}Passed:${TEST_NC} $TOTAL_PASSED  ${TEST_RED}Failed:${TEST_NC} $TOTAL_FAILED  ${TEST_YELLOW}Skipped:${TEST_NC} $TOTAL_SKIPPED"
    echo -e "${TEST_RED}███████████████████████████████████████████████████████████${TEST_NC}\n"

    echo -e "${TEST_YELLOW}Failed Suites:${TEST_NC}"
    for failed_test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${TEST_RED}✗${TEST_NC} $failed_test"
    done
    echo ""
fi

echo "Run individual test files for detailed results:"
echo "  bash $TESTS_DIR/test_modules.sh"
echo "  bash $TESTS_DIR/test_autocomplete.sh"
echo "  bash $TESTS_DIR/test_readline.sh"
echo "  bash $TESTS_DIR/test_filesystem.sh"
echo "  bash $TESTS_DIR/test_aliases.sh"
echo "  bash $TESTS_DIR/test_music.sh"
echo "  bash $TESTS_DIR/test_docker.sh"

if [ $TOTAL_FAILED -eq 0 ]; then
    exit 0
else
    exit 1
fi
