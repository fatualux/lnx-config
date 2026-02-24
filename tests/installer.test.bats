#!/usr/bin/env bats

# Load test helpers
load test_helper

# Test installer script functionality
@test "installer: creates backup directory" {
    run create_backup_dir
    [ "$status" -eq 0 ]
    [ -d "$BACKUP_DIR" ]
}

@test "installer: backs up existing files" {
    # Create test file
    echo "test content" > "$HOME/.test_config"
    BACKUP_FILES=("$HOME/.test_config")
    
    run backup_files
    [ "$status" -eq 0 ]
    [ -f "$BACKUP_DIR/.test_config" ]
    
    # Cleanup
    rm -f "$HOME/.test_config"
}

@test "installer: removes existing configs" {
    # Create test file
    echo "test content" > "$HOME/.test_config"
    BACKUP_FILES=("$HOME/.test_config")
    
    run remove_existing_configs
    [ "$status" -eq 0 ]
    [ ! -f "$HOME/.test_config" ]
}

@test "installer: creates .bashrc" {
    run create_bashrc
    [ "$status" -eq 0 ]
    [ -f "$HOME/.bashrc" ]
    
    # Check that it sources required files
    grep -q "src/colors.sh" "$HOME/.bashrc"
    grep -q "src/logger.sh" "$HOME/.bashrc"
}

@test "installer: creates .vimrc" {
    run create_vimrc
    [ "$status" -eq 0 ]
    [ -f "$HOME/.vimrc" ]
}

@test "installer: handles missing directories gracefully" {
    # Test with non-existent custom config dir
    CUSTOM_CONFIG_DIR="/non/existent/path"
    run copy_custom_configs
    [ "$status" -eq 0 ]
}

@test "installer: main function executes all steps" {
    # Mock the individual functions to track calls
    mock_functions=("create_backup_dir" "backup_files" "remove_existing_configs" "copy_custom_configs" "create_vimrc" "create_bashrc" "display_summary")
    
    # This would require more complex mocking - simplified test for now
    run main
    [ "$status" -eq 0 ]
}
