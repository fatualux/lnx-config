#!/bin/bash

# Tests for module sourcing and availability

source "$(dirname "${BASH_SOURCE[0]}")/test_utils.sh"

print_section "Module Sourcing Tests"

FUNCTIONS_DIR="$(dirname "${BASH_SOURCE[0]}")/../configs/bash/functions"
BASH_CONFIG_PATH="$(dirname "${BASH_SOURCE[0]}")/../configs/bash/main.sh"

# Test: functions directory exists
assert_dir_exists "functions directory exists" "$FUNCTIONS_DIR"

# Test: bash configuration exists
assert_file_exists "bash configuration main.sh exists" "$BASH_CONFIG_PATH"

unset __BASH_CONFIG_LOADED
# Test: source bash configuration
BASH_CONFIG_VERBOSE="" source "$BASH_CONFIG_PATH" 2>&1 > /dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} main.sh sources successfully"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗${NC} main.sh sources successfully"
    ((TESTS_FAILED++))
    print_summary
    exit 1
fi

# List of expected modules organized by category
EXPECTED_MODULE_CATEGORIES=(
    "filesystem"
    "docker"
    "music"
    "aliases"
    "development"
)

# Test: all module category directories exist
print_section "Module Category Tests"
for category in "${EXPECTED_MODULE_CATEGORIES[@]}"; do
    assert_dir_exists "Category $category exists" "$FUNCTIONS_DIR/$category"
done

# Test: all modules have valid bash syntax
print_section "Module Syntax Validation"
for category_dir in "$FUNCTIONS_DIR"/*; do
    if [ -d "$category_dir" ]; then
        for module in "$category_dir"/*.sh; do
            if [ -f "$module" ]; then
                bash -n "$module" > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✓${NC} $(basename "$module") syntax OK"
                    ((TESTS_PASSED++))
                else
                    echo -e "${RED}✗${NC} $(basename "$module") has syntax errors"
                    ((TESTS_FAILED++))
                fi
            fi
        done
    fi
done

# Test: all functions are defined
print_section "Function Definition Tests"
EXPECTED_FUNCTIONS=(
    "code_directory"
    "clear_python_caches"
    "remove_zone_info"
    "play_music_shuffle"
    "remove_currently_playing_track"
    "add_track_to_playlist"
    "list_my_aliases"
    "docker_container_prune_force"
    "docker_network_prune_force"
    "docker_system_prune_force"
    "docker_compose_wrapper"
    "docker_compose_file"
    "kill_docker_containers"
)

for func in "${EXPECTED_FUNCTIONS[@]}"; do
    if declare -f "$func" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Function '$func' is defined"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} Function '$func' is NOT defined"
        ((TESTS_FAILED++))
    fi
done

print_summary
