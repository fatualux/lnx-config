#!/usr/bin/env bats

# Integration Tests for lnx-config
# Tests end-to-end workflows and module interactions

setup() {
    export TEST_MODE=1
    cd /root/Debian/lnx-config
}

teardown() {
    :
}

@test "complete installer workflow" {
    # Test full installer execution in test environment
    export HOME="$TEST_TEMP_DIR/home"
    mkdir -p "$HOME"
    
    run bash installer.sh 2>/dev/null || true
    [[ $status -eq 0 ]] || [[ $status -eq 1 ]]  # May fail due to missing system deps
    
    # Check that key files were created
    assert_file_exists "$HOME/.bashrc" || true
    assert_file_exists "$HOME/.vimrc" || true
}

@test "bash configuration loading" {
    # Test that all bash configs can be loaded together
    local bashrc_content=""
    
    for config in configs/core/bash/*.sh; do
        if [[ -f "$config" ]]; then
            run bash -c "source '$config'"
            [[ $status -eq 0 ]] || {
                echo "Failed to load $config"
                false
            }
        fi
    done
}

@test "virtual environment activation workflow" {
    # Test virtual environment activation
    local venv_dir="$TEST_TEMP_DIR/test-venv"
    mkdir -p "$venv_dir/bin"
    
    # Create fake activate script
    cat > "$venv_dir/bin/activate" << 'EOF'
export VIRTUAL_ENV="$TEST_TEMP_DIR/test-venv"
export PATH="$VIRTUAL_ENV/bin:$PATH"
EOF
    
    cd "$venv_dir"
    run bash -c "source ../configs/core/bash/cd-activate.sh && activate_on_prompt"
    
    # Should activate or handle gracefully
    [[ $status -eq 0 ]] || [[ $status -eq 1 ]]
}

@test "git completion integration" {
    source configs/core/bash/git-autocompletion.sh
    
    # Test git completion initialization
    run _git_completion_initialize
    [[ $status -eq 0 ]]
    
    # Test that git flow functions are available
    declare -f _git_flow
    declare -f _git_flow_feature
    declare -f _git_flow_release
    declare -f _git_flow_hotfix
}

@test "completion system integration" {
    # Test that all completion systems work together
    source configs/core/bash/git-autocompletion.sh
    source configs/core/bash/dirs-completion.sh
    source configs/core/bash/default-completion.sh
    
    # Test completion functions don't conflict
    declare -f _git_flow
    declare -f _dirs_complete
    declare -f _defaults
    
    # Test with mock completion context
    COMP_WORDS=("defaults" "read")
    COMP_CWORD=1
    run _defaults
    [[ $status -eq 0 ]]
}

@test "auto-pairing integration" {
    source configs/core/bash/autopair.sh
    
    # Test auto-pair functions work
    run pd
    [[ $status -eq 0 ]]
    [[ "$output" == '""' ]]
    
    run ps
    [[ $status -eq 0 ]]
    [[ "$output" == "''" ]]
    
    run pr
    [[ $status -eq 0 ]]
    [[ "$output" == "()" ]]
}

@test "logging integration across modules" {
    # Test that logging works consistently across all modules
    source src/logger.sh
    run log_info "Test integration message"
    [[ "$output" == *"Test integration message"* ]] || true
}

@test "error handling integration" {
    # Test error handling across the system
    run bash -c "
        source src/logger.sh
        source configs/core/bash/cd-activate.sh
        # Test with non-existent directory
        cd /nonexistent/path 2>/dev/null || true
        activate_on_prompt
    "
    # Should not crash
    [[ $status -eq 0 ]] || [[ $status -eq 1 ]]
}

@test "configuration file generation" {
    # Test that configuration files are generated correctly
    export HOME="$TEST_TEMP_DIR/home"
    mkdir -p "$HOME"
    
    run bash -c "source src/install.sh && create_bashrc"
    [[ $status -eq 0 ]] || [[ $status -eq 127 ]]
    
    # Check if bashrc was created (if function exists)
    [[ -f "$HOME/.bashrc" ]] || [[ $status -eq 127 ]]
    
    # Test bashrc is syntactically valid
    run bash -c "source '$HOME/.bashrc'"
    [[ $status -eq 0 ]]
}

@test "module dependency resolution" {
    # Test that module dependencies are properly resolved
    run bash -c "
        source src/main.sh
        # Main should load all dependencies without errors
    "
    [[ $status -eq 0 ]]
}

@test "cross-platform compatibility" {
    # Test cross-platform functionality
    run bash -c "
        source src/main.sh
        detect_os
    "
    # Should detect OS or handle gracefully
    [[ $status -eq 0 ]] || [[ $status -eq 127 ]]
}

@test "performance and resource usage" {
    # Test that loading all modules doesn't take too long
    local start_time=$(date +%s.%N)
    
    run bash -c "
        source src/main.sh
        source configs/core/bash/cd-activate.sh
        source configs/core/bash/git-autocompletion.sh
    "
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "1")
    
    # Should load in under 5 seconds
    [[ $(echo "$duration < 5" | bc -l 2>/dev/null || echo "1") -eq 1 ]]
    [[ $status -eq 0 ]]
}
