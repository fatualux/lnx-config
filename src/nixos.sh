#!/bin/bash

# NixOS compatibility module

# Function to detect NixOS
is_nixos() {
    [[ -f "/etc/nixos/version" ]] || [[ -n "${NIX_PATH:-}" ]]
}

# Function to check if running on NixOS
check_nixos() {
    if is_nixos; then
        log_info "Detected NixOS system"
        return 0
    else
        log_info "Not running on NixOS"
        return 1
    fi
}

# Function to install packages via nix
install_nix_packages() {
    if ! is_nixos; then
        log_warn "Not on NixOS, skipping nix package installation"
        return 0
    fi
    
    log_section "Installing packages via Nix"
    
    local packages_file="$SCRIPT_DIR/applications/nix-packages.txt"
    
    if [[ ! -f "$packages_file" ]]; then
        log_warn "Nix packages file not found: $packages_file"
        return 0
    fi
    
    # Read packages from file
    local packages=()
    while read -r package; do
        # Skip empty lines and comments
        if [[ -n "$package" && ! "$package" =~ ^[[:space:]]*# ]]; then
            packages+=("$package")
        fi
    done < "$packages_file"
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        log_info "No nix packages to install"
        return 0
    fi
    
    log_info "Installing ${#packages[@]} nix packages: ${packages[*]}"
    
    # Install packages using nix-env
    if nix-env -iA nixpkgs.${packages[@]}; then
        log_success "Nix packages installed successfully"
    else
        log_error "Failed to install nix packages"
        return 1
    fi
}

# Function to create NixOS configuration symlink
setup_nixos_config() {
    if ! is_nixos; then
        return 0
    fi
    
    log_section "Setting up NixOS configuration"
    
    local nixos_config_dir="/etc/nixos"
    local user_config_dir="$HOME/.config/nixos"
    
    # Create user config directory
    mkdir -p "$user_config_dir"
    
    # Copy configuration if available
    local source_config="$SCRIPT_DIR/configs/nixos/configuration.nix"
    if [[ -f "$source_config" ]]; then
        log_info "Copying NixOS configuration to user directory"
        if cp "$source_config" "$user_config_dir/"; then
            log_success "NixOS configuration copied"
        else
            log_error "Failed to copy NixOS configuration"
            return 1
        fi
    else
        log_info "No NixOS configuration found"
    fi
}

# Function to rebuild NixOS configuration
rebuild_nixos() {
    if ! is_nixos; then
        log_warn "Not on NixOS, cannot rebuild configuration"
        return 1
    fi
    
    if [[ $EUID -ne 0 ]]; then
        log_error "NixOS rebuild requires root privileges"
        return 1
    fi
    
    log_info "Rebuilding NixOS configuration"
    if nixos-rebuild switch; then
        log_success "NixOS configuration rebuilt successfully"
    else
        log_error "Failed to rebuild NixOS configuration"
        return 1
    fi
}
