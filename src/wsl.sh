#!/bin/bash

# WSL interop configuration functions

recreate_wsl_interop_config() {
	log_section "WSL: Recreating WSL Interop Configuration"

	local conf_path="/usr/lib/binfmt.d/WSLInterop.conf"
	local cmd="sudo sh -c 'echo :WSLInterop:M::MZ::/init:PF > ${conf_path}'"

	log_info "Target config file: ${conf_path}"
	log_info "Command to execute: ${cmd}"

	if $dry_run; then
		log_warn "DRY RUN: Would recreate WSL Interop configuration with the above command"
		return 0
	fi

	if [[ "$EUID" -ne 0 ]]; then
		log_warn "This operation requires elevated privileges. You may be prompted for your sudo password."
	fi

	# Execute command and log all output
	if eval "$cmd" 2>&1 | while read -r line; do log_debug "$line"; done; then
		log_success "WSL Interop configuration recreated successfully at ${conf_path}"
	else
		log_error "Failed to recreate WSL Interop configuration at ${conf_path}"
		return 1
	fi
}
