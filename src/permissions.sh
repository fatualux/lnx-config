#!/bin/bash

# Permission setting functions

set_permissions() {
	log_section "Step 6: Setting Permissions"
	
	local install_dir="$HOME/.lnx-config"
	
	log_info "Setting executable permissions on scripts"
	find "$install_dir/src" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
	find "$install_dir/configs/bash" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
	find "$install_dir/configs/vim" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
	find "$install_dir/configs/nvim" -type f -name "*.lua" -exec chmod +x {} \; 2>/dev/null || true
	
	log_info "Setting read permissions on config files"
	chmod 644 "$HOME/.bashrc" 2>/dev/null || true
	chmod 644 "$HOME/.vimrc" 2>/dev/null || true
	
	log_success "Permissions set successfully"
}
