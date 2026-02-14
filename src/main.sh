#!/bin/bash

# Main installation orchestration

main() {
	log_section "Dotfiles Configuration Manager v${VERSION}"
	log_info "Installation mode: Copy project to ~/.lnx-config"
	
	if $dry_run; then
		log_warn "DRY RUN MODE - No changes will be applied"
	fi
	
	log_separator

	if $dry_run; then
		log_section "DRY RUN: Preview Mode"
		log_info "The following actions would be performed:"
		log_info "  1. Back up existing configs to ~/.config_backup-<timestamp>/"
		log_info "  2. Copy entire project to ~/.lnx-config (with .git)"
		log_info "  3. Create required directories"
		log_info "  4. Install ~/.bashrc and ~/.vimrc"
		log_info "  5. Create configuration symlinks (bash, vim, nvim, ranger, joshuto, mpv)"
		log_info "  6. Set appropriate permissions"
		log_info "  7. Initialize git commit"
		log_info "  8. Install NixOS configuration (if on NixOS system)"
		log_separator
		log_warn "No actual changes will be made in dry-run mode"
		return 0
	fi

	# Execute installation steps (backup_existing_configs returns backup_dir path)
	local backup_dir
	backup_dir=$(backup_existing_configs) || {
		log_error "Failed to back up existing configurations"
		return 1
	}
	
	copy_project_to_home || {
		log_error "Failed to copy project to ~/.lnx-config"
		return 1
	}
	
	create_required_directories || {
		log_error "Failed to create required directories"
		return 1
	}
	
	install_rc_files || {
		log_error "Failed to install RC files"
		return 1
	}
	
	create_config_symlinks || {
		log_error "Failed to create configuration symlinks"
		return 1
	}
	
	set_permissions || {
		log_error "Failed to set permissions"
		return 1
	}
	
	initialize_git_commit || {
		log_warn "Git initialization had issues but installation can continue"
	}

	# Install NixOS configuration if on NixOS system
	install_nixos_config "$dry_run" "$auto_yes" || {
		log_warn "NixOS configuration installation had issues but installation can continue"
	}

	# Final summary
	log_separator
	log_section "Installation Complete!"
	log_success "All operations completed successfully"
	log_info "Project installed to: $HOME/.lnx-config"
	if [[ -n "$backup_dir" ]]; then
		log_info "Existing configs backed up to: $backup_dir"
	else
		log_info "No configs were backed up (all skipped by user)"
	fi
	log_info "RC files (.bashrc, .vimrc) installed and updated"
	log_info "Changes are tracked in ~/.lnx-config/.git"
	
	if [[ "$LOG_TO_FILE" == "true" ]]; then
		log_info "Detailed logs saved to: $LOG_FILE"
	fi
	
	log_separator
	
	# Prompt for custom applications installation
	if prompt_install_applications; then
		install_custom_applications
	fi
}
