#!/bin/bash

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
