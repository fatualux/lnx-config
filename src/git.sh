#!/bin/bash

# Git repository functions

initialize_git_commit() {
	log_section "Step 7: Updating Git Repository"
	
	local install_dir="$HOME/.lnx-config"
	
	# Configure git user if provided
	if [[ -n "${user_name:-}" ]] || [[ -n "${user_email:-}" ]]; then
		log_info "Configuring git user identity"
		if [[ -n "${user_name:-}" ]]; then
			git config --global user.name "$user_name"
			log_debug "Set git user.name to: $user_name"
		fi
		if [[ -n "${user_email:-}" ]]; then
			git config --global user.email "$user_email"
			log_debug "Set git user.email to: $user_email"
		fi
	else
		log_debug "No git user configuration provided, checking existing settings"
		
		# Check if git user is configured, prompt if needed
		local current_name=$(git config --global user.name 2>/dev/null || echo "")
		local current_email=$(git config --global user.email 2>/dev/null || echo "")
		
		if [[ -z "$current_name" ]] || [[ -z "$current_email" ]]; then
			log_info "No git user configuration found"
			
			# Prompt user for git configuration if not in dry-run mode
			if [[ "$dry_run" != "true" ]]; then
				# Prompt for name if not set
				if [[ -z "$current_name" ]]; then
					echo ""
					echo "Git user name is not configured."
					echo "This is needed for committing changes to your dotfiles."
					echo ""
					read -p "Enter your git user name: " user_name_input
					if [[ -n "$user_name_input" ]]; then
						git config --global user.name "$user_name_input"
						log_info "Set git user.name to: $user_name_input"
					fi
				fi
				
				# Prompt for email if not set
				if [[ -z "$current_email" ]]; then
					echo ""
					echo "Git user email is not configured."
					echo "This is needed for committing changes to your dotfiles."
					echo ""
					read -p "Enter your git user email: " user_email_input
					if [[ -n "$user_email_input" ]]; then
						git config --global user.email "$user_email_input"
						log_info "Set git user.email to: $user_email_input"
					fi
				fi
				
				# Show current configuration
				echo ""
				echo "Current git configuration:"
				echo "  Name: $(git config --global user.name 2>/dev/null || echo '(not set)')"
				echo "  Email: $(git config --global user.email 2>/dev/null || echo '(not set)')"
				echo ""
			else
				log_debug "Existing git configuration found, using current settings"
			fi
		fi
	fi
	
	pushd "$install_dir" > /dev/null
	
	# Ensure .gitignore excludes backup directories
	if ! grep -q ".config_backup-" .gitignore 2>/dev/null; then
		log_debug "Adding backup directory pattern to .gitignore"
		echo ".config_backup-*" >> .gitignore
		echo "*.backup.*" >> .gitignore
	fi
	
	# Add any untracked files and commit
	git add .
	git commit -m "Configuration update via lnx-config v${VERSION}" --allow-empty 2>&1
	local commit_result=$?
	
	if [[ $commit_result -eq 0 ]]; then
		log_success "Git repository updated"
	else
		log_error "Git commit failed with exit code: $commit_result"
		log_error "This may be due to missing git user configuration"
	fi
	
	popd > /dev/null
}
