#!/bin/bash

add_track_to_playlist() {
	log_func_start "add_track_to_playlist"
	local PID FILE PLAYLIST
	PLAYLIST="/mnt/c/Users/100700092024/Music/fz/_favourites.m3u"
	log_debug "Finding MPV process"
	PID=$(pidof mpv)

	if [ -z "$PID" ]; then
		log_warn "No MPV instance is currently running"
		log_func_end "add_track_to_playlist"
		return 1
	fi

	log_debug "Determining currently playing file from process $PID"
	FILE=$(ls -la /proc/"$PID"/fd/ 2>/dev/null |
		grep -E '\.(mp3|flac|ogg|wav|m4a|opus|wma|aac)$' |
		grep -oP '\-\> \K.*' |
		head -n 1)

	if [ -z "$FILE" ]; then
		log_error "Could not determine the currently playing file"
		log_func_end "add_track_to_playlist"
		return 1
	fi

	log_debug "Adding $(basename "$FILE") to playlist $PLAYLIST"
	echo "./$(basename "$FILE")" >>"$PLAYLIST"
	log_success "Added to playlist: $(basename "$FILE")"
	log_func_end "add_track_to_playlist"
}
