#!/bin/bash

# Tests for env-activate function - sourcing .env files on directory change

source "$(dirname "${BASH_SOURCE[0]}")/test_utils.sh"

print_section "ENV-Activate Function Tests"

# Source the env-activate function
ENV_ACTIVATE_PATH="$(dirname "${BASH_SOURCE[0]}")/../configs/bash/functions/development/env-activate.sh"
source "$ENV_ACTIVATE_PATH"

# Create a temporary test directory
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

print_section "Test 1: .env.local precedence"

(
    cd "$TEST_DIR"
    
    # Create both .env and .env.local files
    echo "export ENV_TEST=local" > .env.local
    echo "export ENV_TEST=default" > .env
    
    # Source env files in a subshell to capture output
    output=$(source_env_files 2>&1)
    
    if [[ "$output" == *".env.local"* ]]; then
        echo -e "${GREEN}✓${NC} .env.local is sourced with higher precedence"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} .env.local is sourced with higher precedence"
        ((TESTS_FAILED++))
    fi
)

print_section "Test 2: .env file sourcing"

(
    cd "$TEST_DIR"
    rm -f .env.local .env
    
    echo "export ENV_TEST=env_file" > .env
    output=$(source_env_files 2>&1)
    
    if [[ "$output" == *".env"* ]] && [[ "$output" != *".env."* ]]; then
        echo -e "${GREEN}✓${NC} .env is sourced when .env.local doesn't exist"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} .env is sourced when .env.local doesn't exist"
        ((TESTS_FAILED++))
    fi
)

print_section "Test 3: .env* wildcard file sourcing"

(
    cd "$TEST_DIR"
    rm -f .env.local .env
    
    echo "export ENV_TEST=custom" > .env.custom
    output=$(source_env_files 2>&1)
    
    if [[ "$output" == *".env.custom"* ]]; then
        echo -e "${GREEN}✓${NC} .env* files are sourced when no .env or .env.local exists"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} .env* files are sourced when no .env or .env.local exists"
        ((TESTS_FAILED++))
    fi
)

print_section "Test 4: No .env file present"

(
    cd "$TEST_DIR"
    rm -f .env.local .env .env.*
    
    output=$(source_env_files 2>&1)
    
    if [[ -z "$output" ]]; then
        echo -e "${GREEN}✓${NC} No output when no .env files present"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} No output when no .env files present (got: $output)"
        ((TESTS_FAILED++))
    fi
)

print_section "Test 5: Variables are actually exported"

(
    cd "$TEST_DIR"
    rm -f .env.local .env
    
    echo "export MY_TEST_VAR=test_value" > .env
    
    # Source in subshell and check if variable is available
    (source_env_files > /dev/null && [[ "$MY_TEST_VAR" == "test_value" ]]) && {
        echo -e "${GREEN}✓${NC} Environment variables are properly exported"
        ((TESTS_PASSED++))
    } || {
        echo -e "${RED}✗${NC} Environment variables are properly exported"
        ((TESTS_FAILED++))
    }
)

print_section "Test 6: Function exists and is callable"

if declare -f source_env_files > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} source_env_files function is defined"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} source_env_files function is defined"
    ((TESTS_FAILED++))
fi

print_section "Test 7: .env.local overrides .env values"

(
    cd "$TEST_DIR"
    
    echo "export OVERRIDE_TEST=default" > .env
    echo "export OVERRIDE_TEST=override" > .env.local
    
    source_env_files > /dev/null
    
    if [[ "$OVERRIDE_TEST" == "override" ]]; then
        echo -e "${GREEN}✓${NC} .env.local values override .env values"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} .env.local values override .env values (got: $OVERRIDE_TEST)"
        ((TESTS_FAILED++))
    fi
)

# Print final summary
print_summary
