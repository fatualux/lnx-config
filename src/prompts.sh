#!/bin/bash

# User prompt utilities

prompt_user() {
	local message="$1"
	local default="${2:-n}"
	
	# Skip prompt if auto_yes is enabled
	if [[ "$auto_yes" == "true" ]]; then
		log_info "Auto-confirming: $message"
		return 0
	fi
	
	# Skip prompt in dry-run mode
	if [[ "$dry_run" == "true" ]]; then
		return 0
	fi
	
	# Check if we're in an interactive terminal
	if [[ ! -t 0 ]]; then
		log_warn "Not running in interactive terminal - auto-skipping: $message"
		return 1
	fi
	
	local prompt_suffix
	local response
	if [[ "$default" == "y" ]]; then
		prompt_suffix="[Y/n]"
	else
		prompt_suffix="[y/N]"
	fi
	
	# Print prompt to stderr to ensure it's visible before read
	printf "\n${YELLOW}%s${NC} %s " "$message" "$prompt_suffix" >&2
	read -r response
	
	# Use default if no response
	response="${response:-$default}"
	
	case "$response" in
		[Yy]|[Yy][Ee][Ss])
			return 0
			;;
		*)
			return 1
			;;
	esac
}
