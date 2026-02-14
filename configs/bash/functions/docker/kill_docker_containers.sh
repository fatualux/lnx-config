#!/bin/bash

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
		docker stop "$container" && docker rm "$container"
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
