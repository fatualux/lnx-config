#!/bin/bash

code_directory() {
	log_func_start "code_directory"
	local chosen_dir
	log_debug "Searching for directories with fzf"
	chosen_dir=$(find . -maxdepth 1 -type d | fzf --height 40% --preview 'tree -C {}' --ansi)

	if [[ -n "$chosen_dir" ]]; then
		log_success "Opening directory in VS Code: $chosen_dir"
		code "$chosen_dir"
	else
		log_warn "No directory selected"
	fi
	log_func_end "code_directory"
}
