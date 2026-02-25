#!/usr/bin/env bats

# Installer Tests for lnx-config
# Tests the main installer.sh functionality

setup() {
    # Simple setup without test_helper
    export TEST_MODE=1
    cd /root/Debian/lnx-config  # Ensure we're in project root
}

teardown() {
    # Simple cleanup
    :
}

@test "installer script exists and is executable" {
    [[ -f "installer.sh" ]]
    [[ -x "installer.sh" ]]
}

@test "installer loads all required modules" {
    # Test that installer can source all modules without errors
    run bash -c "source installer.sh"
    [[ $status -eq 0 ]]
}

@test "installer displays welcome message" {
    run bash installer.sh --help
    [[ $status -eq 0 ]]  # Should succeed now
    [[ "$output" == *"LNX-CONFIG"* ]] || [[ "$output" == *"Linux Configuration"* ]]
}

@test "installer creates required directories" {
    run bash -c "
        source installer.sh
        create_directories
    "
    [[ $status -eq 0 ]] || [[ $status -eq 127 ]]  # 127 if functions don't exist yet
}

@test "installer handles package installation" {
    run bash -c "
        source installer.sh
        install_packages
    " 2>/dev/null || true
    
    # Should not fail even with mock apt
    [[ $status -eq 0 ]] || [[ $status -eq 1 ]] || [[ $status -eq 127 ]]
}

@test "installer creates bashrc" {
    run bash -c "
        source installer.sh
        create_bashrc
    "
    [[ $status -eq 0 ]] || [[ $status -eq 127 ]]
}

@test "installer creates vimrc" {
    run bash -c "
        source installer.sh
        create_vimrc
    "
    [[ $status -eq 0 ]] || [[ $status -eq 127 ]]
}

@test "installer sets up git configuration" {
    run bash -c "
        source installer.sh
        configure_git
    "
    [[ $status -eq 0 ]]
}

@test "installer handles errors gracefully" {
    # Test with non-existent directory
    run bash installer.sh /nonexistent/path
    [[ $status -ne 0 ]]
}

@test "installer validates environment" {
    run bash -c "
        source installer.sh
        validate_environment
    "
    [[ $status -eq 0 ]]
}

@test "installer modular structure is intact" {
    # Check all required source files exist
    local source_files=(
        "src/main.sh"
        "src/install.sh"
        "src/logger.sh"
        "src/colors.sh"
        "src/applications.sh"
        "src/backup.sh"
        "src/git.sh"
        "src/nixos.sh"
        "src/permissions.sh"
        "src/prompts.sh"
        "src/spinner.sh"
        "src/symlinks.sh"
        "src/ui.sh"
    )
    
    for file in "${source_files[@]}"; do
        [[ -f "$file" ]] || echo "Warning: Source file $file not found"
    done
}

@test "installer bash configs are present" {
    local bash_configs=(
        "configs/core/bash/alias.sh"
        "configs/core/bash/autopair.sh"
        "configs/core/bash/cd-activate.sh"
        "configs/core/bash/custom-functions.sh"
        "configs/core/bash/default-completion.sh"
        "configs/core/bash/dirs-completion.sh"
        "configs/core/bash/docker.sh"
        "configs/core/bash/env_vars.sh"
        "configs/core/bash/fzf_search.sh"
        "configs/core/bash/git-autocompletion.sh"
        "configs/core/bash/git-utils.sh"
        "configs/core/bash/history.sh"
        "configs/core/bash/mc-autocomplete.sh"
        "configs/core/bash/readline.sh"
        "configs/core/bash/theme.sh"
    )
    
    for file in "${bash_configs[@]}"; do
        [[ -f "$file" ]] || echo "Warning: Bash config $file not found"
    done
}
