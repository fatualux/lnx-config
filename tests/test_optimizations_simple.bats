#!/usr/bin/env bats

@test "metadata header creation" {
    cd /root/Debian/lnx-config
    source src/install.sh
    
    # Test create_metadata_header function
    run create_metadata_header "bashrc" "5"
    
    # Check that output contains expected metadata
    [[ "$output" =~ "Auto-generated bashrc configuration" ]]
    [[ "$output" =~ "Generated:" ]]
    [[ "$output" =~ "Total modules: 5" ]]
    [[ "$output" =~ "Generator: LNX-CONFIG" ]]
}

@test "bash syntax validation - valid file" {
    cd /root/Debian/lnx-config
    source src/install.sh
    
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
    cd /root/Debian/lnx-config
    source src/install.sh
    
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
    cd /root/Debian/lnx-config
    source src/install.sh
    
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

@test "development mode creation" {
    cd /root/Debian/lnx-config
    source src/install.sh
    
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
    cd /root/Debian/lnx-config
    source src/install.sh
    
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
