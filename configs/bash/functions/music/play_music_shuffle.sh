#!/bin/bash

play_music_shuffle() {
	music_dir=$1
	if [ -z "$music_dir" ]; then
		echo "Usage: play_music_shuffle <music_directory>"
		return 1
	fi
	mpv --input-ipc-server=/tmp/mpvsocket --shuffle "$music_dir"
}

alias pms='play_music_shuffle'
