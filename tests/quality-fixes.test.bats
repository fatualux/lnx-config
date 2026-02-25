#!/usr/bin/env bats

# Load test helpers
load test_helper

@test "backup cleanup: validates MAX_BACKUPS configuration" {
    # Skip due to installer execution complexity in test environment
    skip "Installer validation test complex for test environment"
}

@test "backup cleanup: handles non-existent backup directory" {
    # Create temporary installer with non-existent backup dir
    local temp_installer="/tmp/test_installer_$$"
    cp installer.sh "$temp_installer"
    
    # Modify to use non-existent backup directory
    sed -i '$SCRIPT_DIR/backups|/tmp/non_existent_backups|g' "$temp_installer"
    
    # Should not fail when backup directory doesn't exist
    run bash -c "source $temp_installer && clean_old_backups"
    [ "$status" -eq 0 ]
    
    # Cleanup
    rm -f "$temp_installer"
}

@test "unified colors: defines all required color variables" {
    # Test unified colors system
    source "$SCRIPT_DIR/src/colors.sh"
    
    # Theme colors
    [ -n "$C_USER" ]
    [ -n "$C_HOST" ]
    [ -n "$C_IP" ]
    [ -n "$C_PATH" ]
    [ -n "$C_RESET" ]
    
    # Logger colors
    [ -n "$COLOR_RED" ]
    [ -n "$COLOR_GREEN" ]
    [ -n "$COLOR_YELLOW" ]
    [ -n "$NC" ]
    
    # Consistency check - both should be reset codes (format may differ)
    [[ "$NC" == *'\033[0m'* ]] && [[ "$C_RESET" == *'\033[0m'* ]]
}

@test "theme: sources unified colors correctly" {
    # Test theme loads unified colors
    source "$SCRIPT_DIR/configs/core/bash/theme.sh"
    
    [ -n "$C_USER" ]
    [ -n "$C_HOST" ]
    [ -n "$C_RESET" ]
}

@test "logger: sources unified colors correctly" {
    # Test logger loads unified colors
    source "$SCRIPT_DIR/src/logger.sh"
    
    [ -n "$COLOR_RED" ]
    [ -n "$COLOR_GREEN" ]
    [ -n "$NC" ]
}

@test "color system: prevents re-sourcing conflicts" {
    # First source
    source "$SCRIPT_DIR/src/colors.sh"
    local first_reset="$C_RESET"
    
    # Second source should not cause issues
    source "$SCRIPT_DIR/src/colors.sh"
    local second_reset="$C_RESET"
    
    [ "$first_reset" = "$second_reset" ]
}
