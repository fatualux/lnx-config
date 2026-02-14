#!/bin/bash

remove_currently_playing_track() {
	log_func_start "remove_currently_playing_track"
	local PID FILE
	log_debug "Finding MPV process"
	PID=$(pidof mpv)

	if [ -z "$PID" ]; then
		log_warn "No MPV instance is currently running"
		log_func_end "remove_currently_playing_track"
		return 1
	fi

	log_debug "Determining currently playing file from process $PID"
	FILE=$(ls -la /proc/"$PID"/fd/ 2>/dev/null |
		grep -E '\.(mp3|flac|ogg|wav|m4a|opus|wma|aac)$' |
		grep -oP '\-\> \K.*' |
		head -n 1)

	if [ -z "$FILE" ]; then
		log_error "Could not determine the currently playing file"
		log_func_end "remove_currently_playing_track"
		return 1
	fi

	log_info "Currently playing:"
	log_info "$FILE"

	if [ -f "$FILE" ]; then
		log_file_found "$FILE"
		read -p "Delete '$FILE'? (y/N): " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			rm "$FILE" && log_file_deleted "$FILE"
		else
			log_info "Deletion cancelled"
		fi
	else
		log_file_not_found "$FILE"
	fi
	log_func_end "remove_currently_playing_track"
}
