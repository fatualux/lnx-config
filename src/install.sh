#!/bin/bash

# Installation functions

copy_project_to_home() {
	local project_root="$SCRIPT_DIR"
	local install_dir="$HOME/.lnx-config"
	
	log_section "Step 2: Installing Project to ~/.lnx-config"
	
	if [[ -d "$install_dir" ]]; then
		log_warn "Installation directory already exists: $install_dir"
		log_info "Removing existing installation for clean copy"
		rm -rf "$install_dir"
	fi
	
	log_info "Creating installation directory"
	mkdir -p "$install_dir"
	
	log_info "Copying project files (including .git)"
	cp -r "$project_root"/* "$install_dir/"
	
	# Ensure .git is copied (it may be hidden)
	if [[ -d "$project_root/.git" ]]; then
		log_debug "Copying .git directory"
		cp -r "$project_root/.git" "$install_dir/"
	fi
	
	# Copy .gitignore if it exists
	if [[ -f "$project_root/.gitignore" ]]; then
		log_debug "Copying .gitignore"
		cp "$project_root/.gitignore" "$install_dir/"
	fi
	
	# Remove any backup directories that might have accidentally been copied
	log_debug "Cleaning up any backup directories from installation"
	rm -rf "$install_dir"/.config_backup-* 2>/dev/null || true
	
	log_success "Project installed to: $install_dir"
}

create_required_directories() {
	log_section "Step 3: Creating Required Directories"
	
	local install_dir="$HOME/.lnx-config"
	
	# Only create configs directories - the bash, vim, nvim directories at root level
	# should NOT be created as they conflict with the configs/ subdirectories
	local -a required_dirs=(
		"configs/bash"
		"configs/vim"
		"configs/nvim"
		"configs/ranger"
		"configs/joshuto"
		"configs/mpv"
	)
	
	for dir in "${required_dirs[@]}"; do
		local full_path="$install_dir/$dir"
		if [[ ! -d "$full_path" ]]; then
			log_info "Creating directory: $dir"
			mkdir -p "$full_path"
			log_success "Created: $full_path"
		else
			log_debug "Directory already exists: $dir"
		fi
	done
	
	# Copy configuration files from the project if they don't exist in the install location
	# This ensures the configs are populated with actual files
	local project_configs="$SCRIPT_DIR/configs"
	
	log_info "Ensuring configuration files are copied"
	
	# Copy bash configs
	if [[ -d "$project_configs/bash" ]]; then
		# First copy main configs
		rsync -av --ignore-existing "$project_configs/bash/" "$install_dir/configs/bash/" 2>/dev/null || {
			log_debug "rsync failed for bash configs, trying cp"
			cp -rn "$project_configs/bash/"* "$install_dir/configs/bash/" 2>/dev/null || true
		}
		
		# Then copy core files from src (overwrites if different)
		if [[ -d "$SRC_DIR" ]]; then
			log_info "Copying core bash files from src"
			# Copy core files from src to configs/bash/core
			mkdir -p "$install_dir/configs/bash/core"
			if ! cp -rf "$SRC_DIR"/*.sh "$install_dir/configs/bash/core/" 2>/dev/null; then
				log_warn "Failed to copy some core bash files from src"
			fi
		fi
		
		log_debug "Bash configuration files ensured"
	fi
	
	# Copy nvim configs
	if [[ -d "$project_configs/nvim" ]]; then
		rsync -av --ignore-existing "$project_configs/nvim/" "$install_dir/configs/nvim/" 2>/dev/null || {
			log_debug "rsync failed for nvim, trying cp"
			cp -rn "$project_configs/nvim/"* "$install_dir/configs/nvim/" 2>/dev/null || true
		}
		log_debug "Neovim configuration files ensured"
	fi
	
	# Copy other configs
	for config_type in "vim" "ranger" "joshuto" "mpv"; do
		if [[ -d "$project_configs/$config_type" ]]; then
			rsync -av --ignore-existing "$project_configs/$config_type/" "$install_dir/configs/$config_type/" 2>/dev/null || {
				log_debug "rsync failed for $config_type, trying cp"
				cp -rn "$project_configs/$config_type/"* "$install_dir/configs/$config_type/" 2>/dev/null || true
			}
			log_debug "$config_type configuration files ensured"
		fi
	done
	
	log_success "Configuration directories and files ensured"
}

install_rc_files() {
	log_section "Step 4: Installing RC Files"
	
	local install_dir="$HOME/.lnx-config"
	
	# Install .bashrc
	local bashrc_src="$install_dir/configs/.bashrc"
	local bashrc_dst="$HOME/.bashrc"
	
	if [[ -f "$bashrc_src" ]]; then
		log_info "Installing .bashrc"
		cp "$bashrc_src" "$bashrc_dst"
		log_success ".bashrc installed"
	else
		log_error ".bashrc not found at $bashrc_src"
		return 1
	fi
	
	# Install .vimrc
	local vimrc_src="$install_dir/configs/.vimrc"
	local vimrc_dst="$HOME/.vimrc"
	
	if [[ -f "$vimrc_src" ]]; then
		log_info "Installing .vimrc"
		cp "$vimrc_src" "$vimrc_dst"
		log_success ".vimrc installed"
	else
		log_error ".vimrc not found at $vimrc_src"
		return 1
	fi
}
