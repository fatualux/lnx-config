#!/bin/bash

remove_zone_info() {
	if command -v log_func_start >/dev/null 2>&1; then
		log_func_start "remove_zone_info"
	fi
	if command -v log_process_start >/dev/null 2>&1; then
		log_process_start "Removing Zone.Identifier files"
	fi
	local files_removed
	files_removed=$(find . -name '*.Zone.Identifier' -print -exec rm -rf {} \;)

	if [ -z "$files_removed" ]; then
		if command -v log_info >/dev/null 2>&1; then
			log_info "No Zone.Identifier files found to remove"
		fi
	else
		if command -v log_success >/dev/null 2>&1; then
			log_success "Removed Zone.Identifier files:"
		fi
		if command -v log_info >/dev/null 2>&1; then
			log_info "$files_removed"
		fi
	fi
	if command -v log_func_end >/dev/null 2>&1; then
		log_func_end "remove_zone_info"
	fi
}
