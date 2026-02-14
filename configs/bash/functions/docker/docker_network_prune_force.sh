#!/bin/bash

docker_network_prune_force() {
	log_func_start "docker_network_prune_force"
	log_cmd "docker network prune -f"
	log_process_start "Pruning Docker networks"
	docker network prune -f
	log_process_complete "Docker networks pruned"
	log_func_end "docker_network_prune_force"
}
