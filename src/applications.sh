#!/bin/bash

# Applications installation module

# Function to install packages via apt
install_packages() {
    log_section "Installing packages via apt"
    
    # Check if apt is available
    if ! command -v apt &> /dev/null; then
        log_warn "apt is not available, skipping package installation"
        return 0
    fi
    
    local apps_file="$SCRIPT_DIR/applications/apps.txt"
    
    if [[ ! -f "$apps_file" ]]; then
        log_warn "Apps file not found: $apps_file"
        return 0
    fi
    
    log_info "Updating package lists..."
    if apt update; then
        log_success "Package lists updated"
    else
        log_warn "Failed to update package lists, continuing with installation"
    fi
    
    log_info "Upgrading existing packages..."
    if apt upgrade -y; then
        log_success "Packages upgraded"
    else
        log_warn "Failed to upgrade packages, continuing with installation"
    fi
    
    log_info "Installing packages from: $apps_file"
    
    # Read packages from file and separate apt packages from special cases
    local apt_packages=()
    local special_packages=()
    
    while read -r package; do
        # Skip empty lines and comments
        if [[ -n "$package" && ! "$package" =~ ^[[:space:]]*# ]]; then
            case "$package" in
                "joshuto")
                    special_packages+=("$package")
                    ;;
                *)
                    apt_packages+=("$package")
                    ;;
            esac
        fi
    done < "$apps_file"
    
    # Install apt packages (check if already installed)
    if [[ ${#apt_packages[@]} -gt 0 ]]; then
        local packages_to_install=()
        
        for package in "${apt_packages[@]}"; do
            if dpkg -l | grep -q "^ii  $package "; then
                log_info "Package $package is already installed, skipping"
            else
                packages_to_install+=("$package")
            fi
        done
        
        if [[ ${#packages_to_install[@]} -gt 0 ]]; then
            log_info "Installing ${#packages_to_install[@]} apt packages: ${packages_to_install[*]}"
            
            if apt install -y "${packages_to_install[@]}"; then
                log_success "All apt packages installed successfully"
            else
                log_warn "Failed to install some apt packages, continuing with installation"
                # Don't return error - continue with installation
            fi
        else
            log_info "All apt packages are already installed"
        fi
    else
        log_info "No apt packages to install"
    fi
    
    # Install special packages (check if already installed)
    if [[ ${#special_packages[@]} -gt 0 ]]; then
        log_info "Installing ${#special_packages[@]} special packages: ${special_packages[*]}"
        
        for package in "${special_packages[@]}"; do
            case "$package" in
                "joshuto")
                    if command -v joshuto &> /dev/null; then
                        log_info "joshuto is already installed, skipping"
                    else
                        install_joshuto
                    fi
                    ;;
                *)
                    log_warn "Unknown special package: $package"
                    ;;
            esac
        done
    else
        log_info "No special packages to install"
    fi
}

# Function to install joshuto via cargo
install_joshuto() {
    log_info "Installing joshuto via cargo..."
    
    # Check if cargo is available
    if ! command -v cargo &> /dev/null; then
        log_warn "cargo is not available, skipping joshuto installation"
        return 0
    fi
    
    local temp_dir=$(mktemp -d)
    local joshuto_dir="$temp_dir/joshuto"
    
    # Clone joshuto repository
    if git clone https://github.com/kamiyaa/joshuto.git "$joshuto_dir"; then
        cd "$joshuto_dir"
        
        # Build and install joshuto
        if cargo install --path .; then
            log_success "joshuto installed successfully"
        else
            log_warn "Failed to build joshuto, skipping installation"
        fi
    else
        log_warn "Failed to clone joshuto repository, skipping installation"
    fi
    
    # Clean up temporary directory
    rm -rf "$temp_dir"
}
