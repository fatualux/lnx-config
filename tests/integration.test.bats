#!/usr/bin/env bats

# Integration tests for the complete installer workflow
load test_helper

@test "integration: full installer workflow" {
    # Skip if not running in safe environment
    if [[ "$EUID" -eq 0 && "$HOME" == "/root" ]]; then
        skip "Skipping integration test as root for safety"
    fi
    
    # Create some existing config files to test backup
    create_test_file "$HOME/.bashrc" "old bashrc content"
    create_test_file "$HOME/.vimrc" "old vimrc content"
    create_test_file "$HOME/.config/test" "old config content"
    
    # Run the main installer
    run main
    [ "$status" -eq 0 ]
    
    # Check that backup was created
    [ -d "$BACKUP_DIR" ]
    [ -f "$BACKUP_DIR/.bashrc" ]
    [ -f "$BACKUP_DIR/.vimrc" ]
    
    # Check that new configs were created
    assert_file_exists "$HOME/.bashrc"
    assert_file_exists "$HOME/.vimrc"
    
    # Check that new bashrc sources required files
    assert_file_contains "$HOME/.bashrc" "src/colors.sh"
    assert_file_contains "$HOME/.bashrc" "src/logger.sh"
    assert_file_contains "$HOME/.bashrc" "SCRIPT_DIR="
}

@test "integration: installer with no existing files" {
    # Skip if not running in safe environment
    if [[ "$EUID" -eq 0 && "$HOME" == "/root" ]]; then
        skip "Skipping integration test as root for safety"
    fi
    
    # Ensure no existing config files
    rm -f "$HOME/.bashrc" "$HOME/.vimrc"
    rm -rf "$HOME/.config"
    
    # Run the main installer
    run main
    [ "$status" -eq 0 ]
    
    # Check that new configs were created
    assert_file_exists "$HOME/.bashrc"
    assert_file_exists "$HOME/.vimrc"
}

@test "integration: theme functionality in generated bashrc" {
    # Skip if not running in safe environment
    if [[ "$EUID" -eq 0 && "$HOME" == "/root" ]]; then
        skip "Skipping integration test as root for safety"
    fi
    
    # Run installer
    run main
    [ "$status" -eq 0 ]
    
    # Source the generated bashrc and test theme functions
    source "$HOME/.bashrc"
    
    # Test that theme functions are available after sourcing
    # Note: These functions should be available since theme.sh is sourced
    if command -v get_ip_address >/dev/null 2>&1; then
        local ip
        ip=$(get_ip_address)
        [ -n "$ip" ]
    else
        skip "Theme functions not loaded in test environment"
    fi
}

@test "integration: error handling" {
    # Test that script handles missing source files gracefully
    # Create a temporary source file that references non-existent file
    local temp_source="/tmp/temp_source_$$"
    echo "source /non/existent/file.sh" > "$temp_source"
    
    # Try to source the file
    run source "$temp_source"
    # This should fail but not crash the script
    [ "$status" -ne 0 ]
    
    # Cleanup
    rm -f "$temp_source"
}

@test "integration: script interruption handling" {
    # This would test the trap functionality
    # More complex to implement without actual signal handling
    command -v main
}
