#!/bin/bash

# Tests for Docker functions

source "$(dirname "${BASH_SOURCE[0]}")/test_utils.sh"

# Source bash configuration to load all functions
BASH_CONFIG_PATH="$(dirname "${BASH_SOURCE[0]}")/../configs/bash/main.sh"
unset __BASH_CONFIG_LOADED
if [ -f "$BASH_CONFIG_PATH" ]; then
    BASH_CONFIG_VERBOSE="" source "$BASH_CONFIG_PATH" 2>/dev/null
fi

print_section "Docker Functions"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}⊘${NC} Docker is not installed - skipping Docker tests"
    ((TESTS_SKIPPED++))
    print_summary
    exit 0
fi

# Test: docker_container_prune_force function exists
assert_success "docker_container_prune_force function exists" "declare -f docker_container_prune_force > /dev/null"

# Test: docker_network_prune_force function exists
assert_success "docker_network_prune_force function exists" "declare -f docker_network_prune_force > /dev/null"

# Test: docker_system_prune_force function exists
assert_success "docker_system_prune_force function exists" "declare -f docker_system_prune_force > /dev/null"

# Test: docker_compose_wrapper function exists
assert_success "docker_compose_wrapper function exists" "declare -f docker_compose_wrapper > /dev/null"

# Test: docker_compose_file function exists
assert_success "docker_compose_file function exists" "declare -f docker_compose_file > /dev/null"

# Test: kill_docker_containers function exists
assert_success "kill_docker_containers function exists" "declare -f kill_docker_containers > /dev/null"

# Test: docker command availability
assert_success "Docker CLI is available" "command -v docker > /dev/null"

# Test: docker_compose_file with missing argument
if declare -f docker_compose_file > /dev/null 2>&1; then
    docker_compose_file 2>/dev/null
    if [ $? -ne 0 ]; then
        echo -e "${GREEN}✓${NC} docker_compose_file fails without arguments"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} docker_compose_file fails without arguments"
        ((TESTS_FAILED++))
    fi
fi

print_summary
