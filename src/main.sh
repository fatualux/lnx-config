#!/bin/bash

# Main installation logic module

# Function to display welcome message
show_welcome() {
    echo -e "${COLOR_CYAN}"
    cat << "EOF"

［  ＬＮＸ  －  ＣＯＮＦＩＧ  ］
                                                   
                                                
EOF
    echo -e "${NC}"
    echo -e "${COLOR_CYAN}Linux Configuration Auto-Installer v$VERSION${NC}"
    echo -e "${COLOR_CYAN}======================================${NC}"
    echo ""
}

# Function to validate configuration
validate_config() {
    log_section "Validating configuration"
    
    # Validate MAX_BACKUPS if it exists
    if [[ -n "${MAX_BACKUPS:-}" ]]; then
        if [[ "$MAX_BACKUPS" -lt 1 ]] || [[ "$MAX_BACKUPS" -gt 50 ]]; then
            log_error "MAX_BACKUPS must be between 1 and 50. Current value: $MAX_BACKUPS"
            return 1
        fi
    fi
    
    # Check if running as root (warn but allow)
    if [[ $EUID -eq 0 ]]; then
        log_warn "Running as root. This will modify files in /root instead of a user's home directory."
        if ! prompt_confirm "Continue running as root?"; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi
    
    log_success "Configuration validation passed"
}

# Function to run pre-installation checks
run_pre_checks() {
    log_section "Running pre-installation checks"
    
    # Check if required directories exist
    if [[ ! -d "$SCRIPT_DIR/configs" ]]; then
        log_error "Configuration directory not found: $SCRIPT_DIR/configs"
        return 1
    fi
    
    # Check if applications directory exists
    if [[ ! -d "$SCRIPT_DIR/applications" ]]; then
        log_warn "Applications directory not found: $SCRIPT_DIR/applications"
    fi
    
    # Check available disk space (basic check)
    local available_space
    available_space=$(df "$HOME" | awk 'NR==2 {print $4}')
    local available_mb=$((available_space / 1024))
    
    if [[ $available_mb -lt 100 ]]; then
        log_warn "Low disk space: ${available_mb}MB available"
    else
        log_success "Disk space check passed: ${available_mb}MB available"
    fi
    
    log_success "Pre-installation checks completed"
}

# Function to run installation steps
run_installation() {
    log_section "Starting installation"
    
    # Execute installation steps in order
    clean_old_backups
    create_backup_dir
    backup_files
    remove_existing_configs
    install_packages
    copy_custom_configs
    create_vimrc
    create_bashrc
    create_bash_profile
    
    # Optional steps
    if command -v git &> /dev/null; then
        configure_git
    fi
    
    fix_script_permissions
    create_config_symlinks
    
    log_success "Installation completed successfully!"
}

# Function to run post-installation tasks
run_post_install() {
    log_section "Running post-installation tasks"
    
    # Verify installation
    verify_permissions
    
    # Show summary
    display_summary
    
    # Provide next steps
    echo -e "${COLOR_YELLOW}Next steps:${NC}"
    echo -e "${COLOR_CYAN}1. Run: source ~/.bashrc${NC}"
    echo -e "${COLOR_CYAN}2. Restart your terminal session${NC}"
    echo -e "${COLOR_CYAN}3. Customize your configuration as needed${NC}"
    echo ""
}

# Main installation function
main() {
    show_welcome
    
    # Handle dry run mode
    if [[ "$dry_run" == "true" ]]; then
        log_info "Running in dry-run mode - no changes will be made"
        export LOG_LEVEL=3  # Set to debug level for dry run
    fi
    
    validate_config
    run_pre_checks
    
    if [[ "$dry_run" != "true" ]]; then
        run_installation
        run_post_install
    else
        log_info "Dry run completed - no changes were made"
    fi
}
