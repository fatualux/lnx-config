#!/bin/bash

# Backup functions for existing configurations

backup_existing_configs() {
	local -i backed_up=0
	local backup_dir=""
	local backup_dir_created=false
	local backup_timestamp=""  # Declare once at function level
	
	log_section "Step 1: Backing Up Existing Configurations"
	
	# List of config directories to check
	local -a config_dirs=("bash" "vim" "nvim" "ranger" "joshuto" "mpv")
	
	# Ask user for backup strategy
	local backup_strategy="ask"
	
	# Check if we're in an interactive terminal
	if [[ -t 0 && "$dry_run" == "false" && "$auto_yes" == "false" ]]; then
		printf "\n${YELLOW}%s${NC}\n" "Backup strategy:" >&2
		printf "  ${BLUE}Y${NC} - Back up all configurations\n" >&2
		printf "  ${BLUE}N${NC} - Skip all backups\n" >&2
		printf "  ${BLUE}y${NC} - Choose per-directory (default)\n" >&2
		printf "${YELLOW}%s${NC} " "Select strategy [y/N/Y]:" >&2
		read -r strategy_response
		
		case "$strategy_response" in
			Y)
				backup_strategy="all"
				log_info "Backing up all configurations"
				;;
			N)
				backup_strategy="none"
				log_info "Skipping all backups"
				;;
			y|"")
				backup_strategy="ask"
				log_info "Will prompt for each configuration"
				;;
			*)
				backup_strategy="ask"
				;;
		esac
	fi
	
	# Check and handle each config directory
	for config_type in "${config_dirs[@]}"; do
		local source_path="$HOME/.config/$config_type"
		
		if [[ ! -d "$source_path" ]]; then
			log_debug "No existing $config_type configuration found"
			continue
		fi
		
		local should_backup=false
		
		case "$backup_strategy" in
			all)
				should_backup=true
				;;
			none)
				log_info "Skipped backup of $config_type (user chose to skip all)"
				continue
				;;
			ask)
				if prompt_user "📁 Back up $config_type configuration ($source_path)?" "y"; then
					should_backup=true
				fi
				;;
		esac
		
		if $should_backup; then
			# Create backup directory only on first backup
			if [[ "$backup_dir_created" == "false" ]]; then
				backup_timestamp=$(date +%Y%m%d_%H%M%S)
				backup_dir="$HOME/.config_backup-$backup_timestamp"
				mkdir -p "$backup_dir"
				backup_dir_created=true
				log_info "Created backup directory: $backup_dir"
			fi
			
			log_info "Backing up $config_type configuration"
			# Exclude .git directories to avoid embedded repository warnings
			rsync -a --exclude='.git' "$source_path/" "$backup_dir/$config_type/" 2>/dev/null || cp -r "$source_path" "$backup_dir/$config_type"
			log_success "Backed up: $source_path → $backup_dir/$config_type"
			((backed_up++))
		else
			log_info "Skipped backup of $config_type"
		fi
	done
	
	# Check and prompt for .bashrc
	if [[ -f "$HOME/.bashrc" ]]; then
		local should_backup_bashrc=false
		
		case "$backup_strategy" in
			all)
				should_backup_bashrc=true
				;;
			none)
				log_info "Skipped backup of .bashrc (user chose to skip all)"
				;;
			ask)
				if prompt_user "📄 Back up .bashrc ($HOME/.bashrc)?" "y"; then
					should_backup_bashrc=true
				fi
				;;
		esac
		
		if $should_backup_bashrc; then
			if [[ "$backup_dir_created" == "false" ]]; then
				backup_timestamp=$(date +%Y%m%d_%H%M%S)
				backup_dir="$HOME/.config_backup-$backup_timestamp"
				mkdir -p "$backup_dir"
				backup_dir_created=true
				log_info "Created backup directory: $backup_dir"
			fi
			
			log_info "Backing up .bashrc"
			cp "$HOME/.bashrc" "$backup_dir/.bashrc"
			log_success "Backed up: $HOME/.bashrc"
			((backed_up++))
		fi
	fi
	
	# Check and prompt for .vimrc
	if [[ -f "$HOME/.vimrc" ]]; then
		local should_backup_vimrc=false
		
		case "$backup_strategy" in
			all)
				should_backup_vimrc=true
				;;
			none)
				log_info "Skipped backup of .vimrc (user chose to skip all)"
				;;
			ask)
				if prompt_user "📄 Back up .vimrc ($HOME/.vimrc)?" "y"; then
					should_backup_vimrc=true
				fi
				;;
		esac
		
		if $should_backup_vimrc; then
			if [[ "$backup_dir_created" == "false" ]]; then
				backup_timestamp=$(date +%Y%m%d_%H%M%S)
				backup_dir="$HOME/.config_backup-$backup_timestamp"
				mkdir -p "$backup_dir"
				backup_dir_created=true
				log_info "Created backup directory: $backup_dir"
			fi
			
			log_info "Backing up .vimrc"
			cp "$HOME/.vimrc" "$backup_dir/.vimrc"
			log_success "Backed up: $HOME/.vimrc"
			((backed_up++))
		fi
	fi
	
	# Summary
	if [[ $backed_up -eq 0 ]]; then
		log_warn "No items were backed up"
	else
		log_success "Backed up $backed_up items to $backup_dir"
	fi
	
	# Return the backup directory path (may be empty if nothing was backed up)
	echo "$backup_dir"
	return 0
}
