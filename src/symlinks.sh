#!/bin/bash

# Symlink creation functions

create_config_symlinks() {
	log_section "Step 5: Creating Configuration Symlinks"
	
	local install_dir="$HOME/.lnx-config"
	local config_dir="$HOME/.config"
	
	# Create .config directory if it doesn't exist
	mkdir -p "$config_dir"
	
	# All applications that need symlinks in ~/.config
	local -a app_configs=("bash" "vim" "nvim" "ranger" "joshuto" "mpv")
	
	for app in "${app_configs[@]}"; do
		local source_path="$install_dir/configs/$app"
		local link_path="$config_dir/$app"
		
		if [[ ! -d "$source_path" ]]; then
			log_debug "Source directory not found, skipping: $source_path"
			continue
		fi
		
		if $dry_run; then
			log_warn "DRY RUN: Would create symlink: $config_dir/$app -> $source_path"
		else
			# Remove existing link or directory if it's a symlink
			if [[ -L "$link_path" ]]; then
				log_info "Removing old symlink: $link_path"
				rm "$link_path"
			elif [[ -d "$link_path" ]]; then
				log_warn "Directory exists at $link_path (not a symlink)"
				if [[ "$app" == "bash" || "$app" == "vim" ]]; then
					if prompt_user "Remove existing $app directory to create symlink?" "y"; then
						log_info "Backing up $app directory"
						mv "$link_path" "$link_path.backup.$(date +%s)"
					else
						log_info "Skipping symlink creation for $app"
						continue
					fi
				else
					log_info "Skipping symlink creation for $app"
					continue
				fi
			fi
			
			# Create symlink
			log_info "Creating symlink for $app"
			ln -s "$source_path" "$link_path"
			log_success "Symlink created: $config_dir/$app -> $source_path"
		fi
	done
	
	log_success "Configuration symlinks created successfully"
}
