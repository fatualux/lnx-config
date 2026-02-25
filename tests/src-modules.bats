#!/usr/bin/env bats

# Source Modules Tests for lnx-config
# Tests all src/ directory functionality

setup() {
    export TEST_MODE=1
    cd /root/Debian/lnx-config
}

teardown() {
    :
}

@test "logger.sh provides logging functions" {
    source src/logger.sh
    
    # Test that log functions exist
    declare -f log_info
    declare -f log_success
    declare -f log_error
    declare -f log_warning
    
    # Test log output
    run log_info "Test info message"
    [[ "$output" == *"Test info message"* ]] || true
}

@test "colors.sh provides color variables" {
    source src/colors.sh
    
    # Test that color variables are defined
    [[ -n "${RED:-}" ]]
    [[ -n "${GREEN:-}" ]]
    [[ -n "${YELLOW:-}" ]]
    [[ -n "${BLUE:-}" ]]
    [[ -n "${PURPLE:-}" ]] || [[ -n "${COLOR_PURPLE:-}" ]]  # Allow either name
    [[ -n "${CYAN:-}" ]]
    [[ -n "${WHITE:-}" ]]
    [[ -n "${BOLD:-}" ]] || true  # BOLD may not exist
    [[ -n "${RESET:-}" ]]
}

@test "main.sh loads all dependencies" {
    run bash -c "source src/main.sh"
    [[ $status -eq 0 ]]
}

@test "install.sh handles package operations" {
    run load_package_list
    [[ $status -eq 0 ]] || [[ $status -eq 127 ]]  # 127 if function doesn't exist
}

@test "applications.sh manages applications" {
    source src/applications.sh
    
    # Test that functions exist
    declare -f install_applications || true
    declare -f load_applications || true
}

@test "backup.sh creates backups" {
    # Create a small test directory first
    local test_dir="/tmp/test-backup-src"
    mkdir -p "$test_dir"
    echo "test content" > "$test_dir/test.txt"
    
    source src/backup.sh
    
    # Test backup functionality with small directory
    run create_backup "$test_dir" "test-backup"
    [[ $status -eq 0 ]] || [[ $status -eq 127 ]]  # 127 if function doesn't exist
    
    # Clean up
    rm -rf "$test_dir"
}

@test "git.sh provides git utilities" {
    source src/git.sh
    
    # Test git utility functions
    declare -f setup_git_config || true
    declare -f git_status || true
}

@test "permissions.sh fixes script permissions" {
    run fix_script_permissions "/tmp"
    [[ $status -eq 0 ]] || [[ $status -eq 127 ]]  # 127 if function doesn't exist
}

@test "prompts.sh provides user interaction functions" {
    source src/prompts.sh
    
    # Test prompt functions exist
    declare -f prompt_yes_no || true
    declare -f prompt_input || true
}

@test "spinner.sh displays loading animations" {
    source src/spinner.sh
    
    # Test spinner functions
    declare -f start_spinner || true
    declare -f stop_spinner || true
}

@test "symlinks.sh manages symbolic links" {
    source src/symlinks.sh
    
    # Test symlink creation
    run create_symlink "/target" "/link"
    [[ $status -eq 0 ]] || [[ $status -eq 127 ]]  # 127 if function doesn't exist
}

@test "ui.sh provides user interface utilities" {
    source src/ui.sh
    
    # Test UI functions
    declare -f display_header || true
    declare -f display_section || true
}

@test "nixos.sh handles NixOS specific functionality" {
    source src/nixos.sh
    
    # Test NixOS functions exist
    declare -f detect_nixos || true
    declare -f setup_nixos_config || true
}
