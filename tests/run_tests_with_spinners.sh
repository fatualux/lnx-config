#!/bin/bash

# Enhanced test runner with spinner animations for each test

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Spinner characters
SPINNER_CHARS=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

# Test results tracking
declare -A test_results
declare -A test_times
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║          Bash Custom Functions Test Suite                 ║"
echo "║           (With Spinner Animations)                       ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Spinner animation function
show_spinner() {
    local pid=$1
    local i=0
    while kill -0 $pid 2>/dev/null; do
        printf "\r${SPINNER_CHARS[$((i % 10))]}"
        ((i++))
        sleep 0.1
    done
    printf "\r"
}

# Test runner with spinner
run_test_with_spinner() {
    local test_name="$1"
    local test_file="$2"
    local test_path="$SCRIPT_DIR/$test_file"
    
    if [ ! -f "$test_path" ]; then
        echo -e "  ${RED}✗${NC} $test_name (file not found)"
        ((FAILED_TESTS++))
        ((TOTAL_TESTS++))
        test_results["$test_name"]="FAILED"
        return 1
    fi
    
    # Display test name
    printf "  %-35s " "$test_name"
    
    local start_time=$(date +%s%N)
    
    # Run test in background and capture output
    local temp_output=$(mktemp)
    bash "$test_path" > "$temp_output" 2>&1 &
    local pid=$!
    
    # Show spinner
    show_spinner $pid
    wait $pid
    local exit_code=$?
    
    local end_time=$(date +%s%N)
    local elapsed=$(( (end_time - start_time) / 1000000 ))
    
    # Read output
    local output=$(cat "$temp_output")
    rm -f "$temp_output"
    
    # Parse results - look for the final test summary
    local passed=$(echo "$output" | grep -oE 'Passed: [0-9]+' | tail -1 | grep -oE '[0-9]+' || echo "0")
    local failed=$(echo "$output" | grep -oE 'Failed: [0-9]+' | tail -1 | grep -oE '[0-9]+' || echo "0")
    
    # If no summary found, try to count individual test results
    if [[ "$passed" == "0" && "$failed" == "0" ]]; then
        passed=$(echo "$output" | grep -c "✓" || echo "0")
        failed=$(echo "$output" | grep -c "✗" || echo "0")
    fi
    
    # Display result (with better spacing to avoid overlap)
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}✓${NC} (${passed} tests, ${elapsed}ms)"
        ((PASSED_TESTS++))
        test_results["$test_name"]="PASSED"
    else
        echo -e "${RED}✗${NC} (Failed, ${elapsed}ms)"
        ((FAILED_TESTS++))
        test_results["$test_name"]="FAILED"
        echo ""
        echo -e "${YELLOW}Test Output:${NC}"
        echo "$output" | sed 's/^/  /'
        echo ""
    fi
    
    test_times["$test_name"]=$elapsed
    ((TOTAL_TESTS++))
    
    return $exit_code
}

# Array of tests to run
tests=(
    "Module Tests:test_modules.sh"
    "Autocomplete Tests:test_autocomplete.sh"
    "Readline Tests:test_readline.sh"
    "Filesystem Tests:test_filesystem.sh"
    "Alias Tests:test_aliases.sh"
    "Music Player Tests:test_music.sh"
    "Docker Integration Tests:test_docker.sh"
    "Theme Tests:test_themes.sh"
    "Integration Tests:test_integration.sh"
    "Installer WSL Interop Tests:test_wsl_interop.sh"
)

echo ""
echo -e "${BLUE}Running all test suites...${NC}\n"

# Run all tests
for test_entry in "${tests[@]}"; do
    test_name="${test_entry%%:*}"
    test_file="${test_entry##*:}"
    run_test_with_spinner "$test_name" "$test_file"
    sleep 1
done

# Display summary
echo ""
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                   Test Run Summary                        ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo ""
echo -e "${BLUE}Detailed Results:${NC}"

for test_name in "${!test_results[@]}"; do
    status="${test_results[$test_name]}"
    time="${test_times[$test_name]}"
    
    if [ "$status" = "PASSED" ]; then
        echo -e "  ${GREEN}✓${NC} $test_name (${time}ms)"
    else
        echo -e "  ${RED}✗${NC} $test_name (${time}ms)"
    fi
done

echo ""
echo -e "${BLUE}Statistics:${NC}"
echo -e "  ${GREEN}Passed:${NC} $PASSED_TESTS/$TOTAL_TESTS"
echo -e "  ${RED}Failed:${NC} $FAILED_TESTS/$TOTAL_TESTS"

# Calculate success rate
if [ $TOTAL_TESTS -gt 0 ]; then
    success_rate=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    echo -e "  ${BLUE}Success Rate:${NC} ${success_rate}%"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✓ All test suites passed successfully!${NC}\n"
    exit 0
else
    echo -e "${RED}✗ Some test suites failed. Please review the output above.${NC}\n"
    exit 1
fi
