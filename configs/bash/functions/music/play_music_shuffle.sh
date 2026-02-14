#!/bin/bash

play_music_shuffle() {
	alias mm="mpv --input-ipc-server=/tmp/mpvsocket --shuffle \
~/Music/"
}
