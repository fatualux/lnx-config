#!/bin/bash

docker_container_prune_force() {
	log_func_start "docker_container_prune_force"
	log_cmd "docker container prune -f"
	log_process_start "Pruning Docker containers"
	docker container prune -f
	log_process_complete "Docker containers pruned"
	log_func_end "docker_container_prune_force"
}
