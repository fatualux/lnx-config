#!/bin/bash

docker_system_prune_force() {
	log_func_start "docker_system_prune_force"
	log_cmd "docker system prune"
	log_process_start "Pruning Docker system"
	docker system prune
	log_process_complete "Docker system pruned"
	log_func_end "docker_system_prune_force"
}
