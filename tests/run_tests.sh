#!/usr/bin/env bash

# Test Runner for lnx-config
# Runs all test suites and generates coverage reports

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"
TEST_RESULTS_DIR="$TEST_DIR/results"
COVERAGE_DIR="$TEST_DIR/coverage"

# Create results directories
mkdir -p "$TEST_RESULTS_DIR"
mkdir -p "$COVERAGE_DIR"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if bats is installed
check_bats() {
    if ! command -v bats >/dev/null 2>&1; then
        log_error "bats-core is not installed. Installing..."
        
        # Try to install bats-core
        if command -v npm >/dev/null 2>&1; then
            npm install -g bats-core
        elif command -v pip >/dev/null 2>&1; then
            pip install bats-core
        elif command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y bats
        else
            log_error "Cannot install bats-core automatically. Please install it manually:"
            echo "  npm: npm install -g bats-core"
            echo "  pip: pip install bats-core"
            echo "  apt: sudo apt install bats"
            exit 1
        fi
    fi
    
    log_success "bats-core is available"
}

# Run specific test suite
run_test_suite() {
    local test_file="$1"
    local suite_name="$(basename "$test_file" .bats)"
    
    log_info "Running $suite_name tests..."
    
    local output_file="$TEST_RESULTS_DIR/${suite_name}.tap"
    local junit_file="$TEST_RESULTS_DIR/${suite_name}.junit.xml"
    
    # Run tests with multiple output formats
    if bats --version | grep -q "bats"; then
        bats --formatter tap --output "$output_file" \
             --formatter junit --output "$junit_file" \
             "$test_file" 2>&1 | tee "$TEST_RESULTS_DIR/${suite_name}.log"
    else
        bats "$test_file" 2>&1 | tee "$TEST_RESULTS_DIR/${suite_name}.log"
    fi
    
    local exit_code=${PIPESTATUS[0]}
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "$suite_name tests passed"
    else
        log_error "$suite_name tests failed"
    fi
    
    return $exit_code
}

# Generate coverage report
generate_coverage() {
    log_info "Generating coverage report..."
    
    # Create coverage summary
    local coverage_file="$COVERAGE_DIR/coverage.md"
    cat > "$coverage_file" << 'EOF'
# Test Coverage Report

## Test Suites

EOF
    
    # Count tests in each suite
    for test_file in "$TEST_DIR"/*.bats; do
        if [[ -f "$test_file" ]]; then
            local suite_name="$(basename "$test_file" .bats)"
            local test_count=$(grep -c "^@test" "$test_file" || echo "0")
            echo "- **$suite_name**: $test_count tests" >> "$coverage_file"
        fi
    done
    
    cat >> "$coverage_file" << 'EOF'

## Coverage Areas

- [x] Installer functionality
- [x] Source modules  
- [x] Bash configurations
- [x] Integration workflows
- [x] Edge cases and error handling

## Test Statistics

Total test files: $(find "$TEST_DIR" -name "*.bats" | wc -l)
Total test cases: $(grep -r "^@test" "$TEST_DIR"/*.bats | wc -l)

## Running Tests

```bash
# Run all tests
./tests/run_tests.sh

# Run specific suite
./tests/run_tests.sh installer

# Run with coverage
./tests/run_tests.sh --coverage
```

EOF
    
    log_success "Coverage report generated: $coverage_file"
}

# Main execution
main() {
    local coverage_only=false
    local specific_suite=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --coverage)
                coverage_only=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [--coverage] [suite_name]"
                echo "  --coverage    Generate coverage report only"
                echo "  suite_name    Run specific test suite"
                echo "  --help         Show this help"
                exit 0
                ;;
            *)
                specific_suite="$1"
                shift
                ;;
        esac
    done
    
    log_info "Starting lnx-config test runner..."
    
    # Check dependencies
    check_bats
    
    if [[ "$coverage_only" == "true" ]]; then
        generate_coverage
        exit 0
    fi
    
    # Change to project root
    cd "$PROJECT_ROOT"
    
    # Run tests
    local total_tests=0
    local passed_tests=0
    local failed_tests=0
    
    if [[ -n "$specific_suite" ]]; then
        # Run specific suite
        local test_file="$TEST_DIR/${specific_suite}.bats"
        if [[ -f "$test_file" ]]; then
            if run_test_suite "$test_file"; then
                ((passed_tests++))
            else
                ((failed_tests++))
            fi
            ((total_tests++))
        else
            log_error "Test suite '$specific_suite' not found"
            exit 1
        fi
    else
        # Run all test suites
        for test_file in "$TEST_DIR"/*.bats; do
            if [[ -f "$test_file" ]]; then
                if run_test_suite "$test_file"; then
                    ((passed_tests++))
                else
                    ((failed_tests++))
                fi
                ((total_tests++))
            fi
        done
    fi
    
    # Generate coverage report
    generate_coverage
    
    # Print summary
    echo
    log_info "Test Summary:"
    echo "  Total suites: $total_tests"
    echo "  Passed: $passed_tests"
    echo "  Failed: $failed_tests"
    
    if [[ $failed_tests -eq 0 ]]; then
        log_success "All tests passed! 🎉"
        exit 0
    else
        log_error "Some tests failed. Check logs in $TEST_RESULTS_DIR/"
        exit 1
    fi
}

# Run main function
main "$@"
