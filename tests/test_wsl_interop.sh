#!/bin/bash

# Tests for WSL interop configuration helper in installer script

# Source test utilities and set up environment
source "$(dirname "${BASH_SOURCE[0]}")/test_utils.sh"

# Set up test environment with logging
PROJECT_ROOT="$(dirname "${BASH_SOURCE[0]}")/.."
export SCRIPT_DIR="$PROJECT_ROOT/src"
export LOG_LEVEL=0
export LOG_TIMESTAMP=true

# Source logging modules for testing (handle multiple sourcing)
source "$PROJECT_ROOT/src/colors.sh"
# Reset logger guard to allow re-sourcing for tests
unset __LOGGER_SOURCED
source "$PROJECT_ROOT/src/logger.sh"

print_section "WSL Interop Configuration Helper"

PROJECT_ROOT="$(dirname "${BASH_SOURCE[0]}")/.."
INSTALLER_MAIN="$PROJECT_ROOT/installer.sh"

# Ensure installer script exists
assert_file_exists "installer.sh exists" "$INSTALLER_MAIN"

# Source installer script without running installation (main is guarded)
source "$INSTALLER_MAIN"

# Test: function exists
assert_success "recreate_wsl_interop_config function exists" \
    "declare -f recreate_wsl_interop_config > /dev/null"

# Test: dry-run mode succeeds without requiring sudo changes
(
    # Subshell to avoid leaking state
    export dry_run=true
    assert_success "recreate_wsl_interop_config succeeds in dry-run mode" \
        "recreate_wsl_interop_config"
)

print_summary
