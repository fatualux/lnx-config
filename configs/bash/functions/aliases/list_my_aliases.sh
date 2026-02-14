#!/bin/bash

list_my_aliases() {
	log_func_start "list_my_aliases"
	# Use BASH_CONFIG_DIR to find alias file in current installation
	local alias_file="${BASH_CONFIG_DIR:-$HOME/.lnx-config/configs/bash}/aliases/alias.sh"
	
	if [[ ! -f "$alias_file" ]]; then
		log_error "Alias file not found: $alias_file"
		return 1
	fi
	
	log_section "Custom Aliases from $alias_file"
	cat "$alias_file" | sed "s/alias //g" | awk -F= '{printf "\033[1;34m%-20s\033[0m = \033[1;32m%s\033[0m\n", $1, $2}'
	log_func_end "list_my_aliases"
}
