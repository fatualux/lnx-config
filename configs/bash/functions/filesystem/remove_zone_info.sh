#!/bin/bash

remove_zone_info() {
	log_func_start "remove_zone_info"
	log_process_start "Removing Zone.Identifier files"
	local files_removed
	files_removed=$(find . -name '*.Zone.Identifier' -print -exec rm -rf {} \;)

	if [ -z "$files_removed" ]; then
		log_info "No Zone.Identifier files found to remove"
	else
		log_success "Removed Zone.Identifier files:"
		log_info "$files_removed"
	fi
	log_func_end "remove_zone_info"
}
