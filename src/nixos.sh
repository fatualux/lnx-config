#!/bin/bash

# NixOS configuration installation module

install_nixos_config() {
    local dry_run="${1:-false}"
    local auto_yes="${2:-false}"
    
    # Ensure logging functions are available
    if ! declare -f log_section >/dev/null 2>&1; then
        echo "ERROR: Logging functions not available" >&2
        return 1
    fi
    
    log_section "Step 8: Installing NixOS Configuration"
    
    # Check if we're running on NixOS (more robust detection)
    local is_nixos=false
    
    # Check multiple indicators for NixOS
    if [[ -d /nix/store ]] && [[ -f /etc/nixos-version ]]; then
        is_nixos=true
    elif [[ -f /etc/os-release ]] && grep -q "ID=nixos" /etc/os-release 2>/dev/null; then
        is_nixos=true
    elif command -v nixos-version >/dev/null 2>&1; then
        is_nixos=true
    fi
    
    if ! $is_nixos; then
        log_warn "NixOS configuration installation is only available on NixOS systems"
        log_info "Current system does not appear to be NixOS"
        log_debug "NixOS detection checks:"
        log_debug "  - /nix/store exists: $([[ -d /nix/store ]] && echo 'yes' || echo 'no')"
        log_debug "  - /etc/nixos-version exists: $([[ -f /etc/nixos-version ]] && echo 'yes' || echo 'no')"
        log_debug "  - nixos-version command: $(command -v nixos-version >/dev/null 2>&1 && echo 'available' || echo 'not found')"
        return 0
    fi
    
    # Check if NixOS configuration files exist
    local nixos_config_dir="$SCRIPT_DIR/configs/nixos"
    local flake_file="$nixos_config_dir/flake.nix"
    local bash_profile_file="$nixos_config_dir/.bash_profile"
    
    if [[ ! -f "$flake_file" ]]; then
        log_error "NixOS flake.nix not found at: $flake_file"
        return 1
    fi
    
    if [[ ! -f "$bash_profile_file" ]]; then
        log_error "NixOS .bash_profile not found at: $bash_profile_file"
        return 1
    fi
    
    log_info "NixOS configuration files found:"
    log_info "  - flake.nix: $flake_file"
    log_info "  - .bash_profile: $bash_profile_file"
    
    # Ask user for NixOS config installation unless auto-yes is set
    local should_install=false
    
    if [[ "$auto_yes" == "true" ]]; then
        should_install=true
        log_info "Auto-confirming NixOS configuration installation"
    elif [[ "$dry_run" == "true" ]]; then
        should_install=true
        log_info "Dry-run mode: Would install NixOS configuration"
    else
        if prompt_user "🔧 Install NixOS system configuration? This will modify /etc/nixos/configuration.nix" "n"; then
            should_install=true
        else
            log_info "Skipping NixOS configuration installation"
            return 0
        fi
    fi
    
    if ! $should_install; then
        return 0
    fi
    
    # Backup existing configuration
    local config_backup_dir=""
    if [[ -f /etc/nixos/configuration.nix ]]; then
        config_backup_dir="/etc/nixos/configuration.nix.backup-$(date +%Y%m%d_%H%M%S)"
        if [[ "$dry_run" == "false" ]]; then
            log_info "Backing up existing NixOS configuration to: $config_backup_dir"
            sudo cp /etc/nixos/configuration.nix "$config_backup_dir"
            log_success "Backed up existing configuration"
        else
            log_info "Dry-run: Would backup existing configuration to: $config_backup_dir"
        fi
    fi
    
    # Install NixOS configuration
    if [[ "$dry_run" == "false" ]]; then
        log_info "Installing NixOS configuration..."
        
        # Navigate to /etc/nixos directory
        local original_dir="$(pwd)"
        cd /etc/nixos || {
            log_error "Failed to navigate to /etc/nixos directory"
            cd "$original_dir"
            return 1
        }
        
        # Remove existing configuration.nix
        if [[ -f configuration.nix ]]; then
            log_info "Removing existing configuration.nix"
            sudo rm configuration.nix
        fi
        
        # Copy new flake.nix
        log_info "Copying flake.nix to /etc/nixos/"
        sudo cp "$flake_file" /etc/nixos/flake.nix
        
        # Copy .bash_profile to user home
        log_info "Copying .bash_profile to home directory"
        cp "$bash_profile_file" "$HOME/.bash_profile"
        
        # Rebuild NixOS configuration
        log_info "Rebuilding NixOS configuration with flake..."
        
        # Check if spinner functions are available
        if declare -f spinner_start >/dev/null 2>&1; then
            spinner_start "Rebuilding NixOS configuration"
        else
            log_info "Starting NixOS configuration rebuild..."
        fi
        
        local rebuild_output=""
        local rebuild_exit_code=0
        
        if rebuild_output=$(sudo nixos-rebuild switch --flake /etc/nixos#nixos 2>&1); then
            if declare -f spinner_stop >/dev/null 2>&1; then
                spinner_stop "NixOS configuration rebuilt" "Failed to rebuild NixOS configuration" 0
            else
                log_success "NixOS configuration rebuild completed"
            fi
            log_success "NixOS configuration installed successfully"
            echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] NixOS configuration rebuilt" >> "$LOG_FILE"
            
            # Show summary of changes
            if echo "$rebuild_output" | grep -q "packages"; then
                log_info "Package changes detected and applied"
            fi
            
            if echo "$rebuild_output" | grep -q "services"; then
                log_info "Service configuration changes detected and applied"
            fi
            
        else
            if declare -f spinner_stop >/dev/null 2>&1; then
                spinner_stop "NixOS configuration rebuilt" "Failed to rebuild NixOS configuration" 1
            else
                log_error "NixOS configuration rebuild failed"
            fi
            rebuild_exit_code=$?
            log_error "Failed to rebuild NixOS configuration"
            echo "$(date '+%Y-%m-%d %H:%M:%S') [FAILED] NixOS configuration rebuild failed" >> "$LOG_FILE"
            echo "$rebuild_output" >> "$LOG_FILE"
            
            # Restore backup if rebuild failed
            if [[ -n "$config_backup_dir" ]] && [[ -f "$config_backup_dir" ]]; then
                log_warn "Attempting to restore backup configuration..."
                sudo cp "$config_backup_dir" /etc/nixos/configuration.nix
                log_info "Backup configuration restored"
            fi
        fi
        
        # Return to original directory
        cd "$original_dir"
        
    else
        log_info "Dry-run mode: Would execute the following:"
        log_info "  1. Navigate to /etc/nixos"
        log_info "  2. Remove existing configuration.nix"
        log_info "  3. Copy flake.nix to /etc/nixos/"
        log_info "  4. Copy .bash_profile to ~/"
        log_info "  5. Run: sudo nixos-rebuild switch --flake /etc/nixos#nixos"
    fi
    
    log_success "NixOS configuration installation completed"
    return ${rebuild_exit_code:-0}
}

# Function to check if NixOS configuration needs updating
check_nixos_config_status() {
    local nixos_config_dir="$SCRIPT_DIR/configs/nixos"
    local system_config="/etc/nixos/configuration.nix"
    local repo_config="$nixos_config_dir/flake.nix"
    
    # Use the same robust NixOS detection
    local is_nixos=false
    
    if [[ -d /nix/store ]] && [[ -f /etc/nixos-version ]]; then
        is_nixos=true
    elif [[ -f /etc/os-release ]] && grep -q "ID=nixos" /etc/os-release 2>/dev/null; then
        is_nixos=true
    elif command -v nixos-version >/dev/null 2>&1; then
        is_nixos=true
    fi
    
    if ! $is_nixos; then
        echo "Not running on NixOS"
        return 1
    fi
    
    if [[ ! -f "$system_config" ]]; then
        echo "No system configuration found"
        return 1
    fi
    
    if [[ ! -f "$repo_config" ]]; then
        echo "No repository configuration found"
        return 1
    fi
    
    # Simple comparison - in a real implementation, you might want more sophisticated comparison
    local system_hash=$(sudo sha256sum "$system_config" 2>/dev/null | cut -d' ' -f1)
    local repo_hash=$(sha256sum "$repo_config" 2>/dev/null | cut -d' ' -f1)
    
    if [[ "$system_hash" == "$repo_hash" ]]; then
        echo "NixOS configuration is up to date"
        return 0
    else
        echo "NixOS configuration differs from repository"
        return 1
    fi
}
