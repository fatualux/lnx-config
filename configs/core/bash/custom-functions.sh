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


# recursively cats all files in a given directory with their names
# if run with no arguments, it cats the current directory
recursive_cat() {
    local dir="${1:-.}"

    # Check if directory exists
    if [[ ! -d "$dir" ]]; then
        echo "Directory does not exist: $dir" >&2
        return 1
    fi

    # Loop through items in the directory
    for item in "$dir"/*; do
        if [[ -d "$item" ]]; then
            # If item is a directory, recurse into it
            recursive_cat "$item"
        elif [[ -f "$item" ]]; then
            # If item is a file, print its name and contents
            echo "==> $item <=="
            cat "$item"
            echo ""
        fi
    done
}


# recursively cats all files in a given directory with their names
# if run with no arguments, it cats the current directory
recursive_cat() {
    local dir="${1:-.}"

    # Check if directory exists
    if [[ ! -d "$dir" ]]; then
        echo "Directory does not exist: $dir" >&2
        return 1
    fi

    # Loop through items in the directory
    for item in "$dir"/*; do
        if [[ -d "$item" ]]; then
            # If item is a directory, recurse into it
            recursive_cat "$item"
        elif [[ -f "$item" ]]; then
            # If item is a file, print its name and contents
            echo "==> $item <=="
            cat "$item"
            echo ""
        fi
    done
}


docker_compose_file() {
	log_func_start "docker_compose_file"
	if [[ -z "$1" ]]; then
		log_error "Usage: docker_compose_file <docker-compose-file>"
		log_func_end "docker_compose_file"
		return 1
	fi
	log_cmd "docker compose --file $*"
	log_file_found "$1"
	docker compose --file "$1" "${@:2}"
	log_success "Executed: docker compose --file $*"
	log_func_end "docker_compose_file"
}


docker_compose_wrapper() {
	log_func_start "docker_compose_wrapper"
	log_cmd "docker compose $*"
	docker compose "$@"
	log_success "Executed: docker compose $*"
	log_func_end "docker_compose_wrapper"
}


docker_container_prune_force() {
	log_func_start "docker_container_prune_force"
	log_cmd "docker container prune -f"
	log_process_start "Pruning Docker containers"
	docker container prune -f
	log_process_complete "Docker containers pruned"
	log_func_end "docker_container_prune_force"
}

docker_network_prune_force() {
	log_func_start "docker_network_prune_force"
	log_cmd "docker network prune -f"
	log_process_start "Pruning Docker networks"
	docker network prune -f
	log_process_complete "Docker networks pruned"
	log_func_end "docker_network_prune_force"
}


docker_system_prune_force() {
	log_func_start "docker_system_prune_force"
	log_cmd "docker system prune"
	log_process_start "Pruning Docker system"
	docker system prune
	log_process_complete "Docker system pruned"
	log_func_end "docker_system_prune_force"
}


kill_docker_containers() {
	log_func_start "kill_docker_containers"
	log_process_start "Stopping and removing all Docker containers"
	local containers
	log_debug "Fetching list of all containers"
	containers=$(docker ps -aq)

	if [ -z "$containers" ]; then
		log_info "No containers to stop and remove"
		log_func_end "kill_docker_containers"
		return
	fi

	local container_count=$(echo "$containers" | wc -l)
	local current=0
	
	for container in $containers; do
		((current++))
		log_debug "Checking container: $container"
		if docker inspect --format='{{.State.Paused}}' "$container" | grep -q "true"; then
			log_warn "Container $container is paused, skipping"
			continue
		fi
		
		# Use spinner for visual feedback while processing each container
		spinner_start "Stopping and removing container ($current/$container_count)"
		docker stop "$container" >/dev/null 2>&1 && docker rm "$container" >/dev/null 2>&1
		local exit_code=$?
		
		if [ $exit_code -eq 0 ]; then
			spinner_stop "Container ${container:0:12} removed" "" 0
		else
			spinner_stop "" "Failed to remove container ${container:0:12}" 1
		fi
	done
	
	log_process_complete "All containers stopped and removed"
	log_func_end "kill_docker_containers"
}


clear_python_caches() {
	if command -v log_func_start >/dev/null 2>&1; then
		log_func_start "clear_python_caches"
	fi
	if command -v log_process_start >/dev/null 2>&1; then
		log_process_start "Clearing Python caches"
	fi
	if command -v log_debug >/dev/null 2>&1; then
		log_debug "Removing __pycache__, .mypy_cache, and .pytest_cache directories"
	fi
	find . -type d \( -name "__pycache__" -o -name ".mypy_cache" -o -name ".pytest_cache" \) -exec rm -r {} +
	if command -v log_debug >/dev/null 2>&1; then
		log_debug "Removing *.pyc files"
	fi
	find . -name "*.pyc" -delete
	if command -v log_process_complete >/dev/null 2>&1; then
		log_process_complete "Python caches cleared"
	fi
	if command -v log_func_end >/dev/null 2>&1; then
		log_func_end "clear_python_caches"
	fi
}


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


play_music_shuffle() {
	music_dir=$1
	if [ -z "$music_dir" ]; then
		echo "Usage: play_music_shuffle <music_directory>"
		return 1
	fi
	mpv --input-ipc-server=/tmp/mpvsocket --shuffle "$music_dir"
}

alias pms='play_music_shuffle'


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
