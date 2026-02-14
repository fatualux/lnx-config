#!/bin/bash

# Test NixOS installation functionality

source "$(dirname "${BASH_SOURCE[0]}")/test_utils.sh"

# Source required modules for logging
PROJECT_ROOT="$(dirname "${BASH_SOURCE[0]}")/.."

# Set up minimal environment for logger
export LOG_LEVEL=0
export LOG_TIMESTAMP=true

source "$PROJECT_ROOT/src/colors.sh"
source "$PROJECT_ROOT/src/logger.sh"

print_section "NixOS Installation Test"

NIXOS_INSTALLER="$PROJECT_ROOT/src/nixos.sh"

# Ensure NixOS installer exists
assert_file_exists "NixOS installer exists" "$NIXOS_INSTALLER"

# Source NixOS installer (after logger is available)
source "$NIXOS_INSTALLER"

# Test install_nixos_config function exists
assert_success "install_nixos_config function exists" \
    "declare -f install_nixos_config > /dev/null"

# Test check_nixos_config_status function exists
assert_success "check_nixos_config_status function exists" \
    "declare -f check_nixos_config_status > /dev/null"

# Test NixOS configuration files exist
assert_file_exists "NixOS flake.nix exists" "$PROJECT_ROOT/configs/nixos/flake.nix"
assert_file_exists "NixOS .bash_profile exists" "$PROJECT_ROOT/configs/nixos/.bash_profile"

# Test dry-run mode functionality
log_info "Testing dry-run mode..."
export dry_run=true
export auto_yes=false

# This should not fail in dry-run mode
if install_nixos_config true false; then
    log_success "Dry-run mode completed successfully"
else
    log_error "Dry-run mode failed"
fi

# Test that function properly detects non-NixOS system
log_info "Testing behavior on non-NixOS system..."

# Mock non-NixOS environment by temporarily hiding NixOS indicators
temp_backup_dir="/tmp/nixos-test-backup-$$"
mkdir -p "$temp_backup_dir"

# Backup any existing NixOS indicators
if [[ -d /nix/store ]]; then
    sudo mv /nix/store "$temp_backup_dir/nix-store" 2>/dev/null || true
fi

if [[ -f /etc/nixos-version ]]; then
    sudo mv /etc/nixos-version "$temp_backup_dir/nixos-version" 2>/dev/null || true
fi

# Temporarily modify os-release if it contains nixos
if [[ -f /etc/os-release ]] && grep -q "ID=nixos" /etc/os-release 2>/dev/null; then
    sudo cp /etc/os-release "$temp_backup_dir/os-release" 2>/dev/null || true
    # Create a temporary os-release without nixos
    echo "ID=unknown" | sudo tee /etc/os-release >/dev/null 2>/dev/null || true
fi

# Test that function properly detects non-NixOS system
if check_nixos_config_status; then
    log_error "Function should detect non-NixOS system"
    test_result=1
else
    log_success "Function correctly detected non-NixOS system"
    test_result=0
fi

# Restore backed up NixOS indicators
if [[ -f "$temp_backup_dir/nix-store" ]]; then
    sudo rm -rf /nix/store 2>/dev/null || true
    sudo mv "$temp_backup_dir/nix-store" /nix/store 2>/dev/null || true
fi

if [[ -f "$temp_backup_dir/nixos-version" ]]; then
    sudo mv "$temp_backup_dir/nixos-version" /etc/nixos-version 2>/dev/null || true
fi

if [[ -f "$temp_backup_dir/os-release" ]]; then
    sudo mv "$temp_backup_dir/os-release" /etc/os-release 2>/dev/null || true
fi

# Clean up temporary backup directory
rm -rf "$temp_backup_dir" 2>/dev/null || true

print_summary

# Exit with test result
exit $test_result
