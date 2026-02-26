#!/usr/bin/env bats

# Test suite for configuration generation optimizations

# Change to project root and source install.sh
cd /root/Debian/lnx-config
source src/install.sh

@test "metadata header creation" {
    # Test create_metadata_header function
    run create_metadata_header "bashrc" "5"
    
    # Check that output contains expected metadata
    [[ "$output" =~ "Auto-generated bashrc configuration" ]]
    [[ "$output" =~ "Generated:" ]]
    [[ "$output" =~ "Total modules: 5" ]]
    [[ "$output" =~ "Generator: LNX-CONFIG" ]]
}

@test "bash syntax validation - valid file" {
    # Create a valid bash file
    local valid_file=$(mktemp)
    echo "echo 'test'" > "$valid_file"
    
    # Test validation passes
    run validate_bash_syntax "$valid_file"
    [[ "$status" -eq 0 ]]
    
    # Cleanup
    rm -f "$valid_file"
}

@test "bash syntax validation - invalid file" {
    # Create an invalid bash file
    local invalid_file=$(mktemp)
    echo "echo 'test" > "$invalid_file"
    
    # Test validation fails
    run validate_bash_syntax "$invalid_file"
    [[ "$status" -eq 1 ]]
    
    # Cleanup
    rm -f "$invalid_file"
}

@test "selective regeneration - force flag" {
    # Create any files
    local source_file=$(mktemp)
    local generated_file=$(mktemp)
    touch "$source_file" "$generated_file"
    
    # Test should_regenerate returns true when force flag is set
    run should_regenerate "$generated_file" "true"
    [[ "$status" -eq 0 ]]
    
    # Cleanup
    rm -f "$source_file" "$generated_file"
}

@test "selective regeneration - file not exists" {
    # Test with non-existent file
    local non_existent_file="/tmp/does-not-exist-$(date +%s)"
    
    # Test should_regenerate returns true when file doesn't exist
    run should_regenerate "$non_existent_file" "false"
    [[ "$status" -eq 0 ]]
}

@test "development mode creation" {
    # Test create_dev_bashrc function
    run create_dev_bashrc
    
    # Check that .bashrc.dev was created
    [[ -f "$HOME/.bashrc.dev" ]]
    
    # Check that it contains development mode markers
    run grep -q "Development Mode" "$HOME/.bashrc.dev"
    [[ "$status" -eq 0 ]]
    
    # Cleanup
    rm -f "$HOME/.bashrc.dev"
}

@test "rollback functionality - backup exists" {
    # Create a backup file
    local config_file=$(mktemp)
    local backup_file="${config_file}.backup"
    echo "original content" > "$backup_file"
    
    # Test rollback restores from backup
    run rollback_config "$config_file"
    [[ -f "$config_file" ]]
    run grep -q "original content" "$config_file"
    
    # Cleanup
    rm -f "$config_file" "$backup_file"
}

@test "rollback functionality - no backup" {
    # Test with no backup file
    local config_file=$(mktemp)
    
    # Test rollback fails when no backup exists
    run rollback_config "$config_file"
    [[ "$status" -eq 1 ]]
    
    # Cleanup
    rm -f "$config_file"
}

@test "file modification time functions" {
    # Create test file with known timestamp
    local test_file=$(mktemp)
    touch "$test_file"
    
    # Test get_generated_time returns a timestamp
    local result=$(get_generated_time "$test_file")
    [[ "$result" =~ ^[0-9]+$ ]]
    
    # Cleanup
    rm -f "$test_file"
}

@test "latest source time function" {
    # Test get_latest_source_time returns a number
    local result=$(get_latest_source_time)
    [[ "$result" =~ ^[0-9]+$ ]]
}
