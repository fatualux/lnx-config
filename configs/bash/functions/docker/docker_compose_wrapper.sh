#!/bin/bash

docker_compose_wrapper() {
	log_func_start "docker_compose_wrapper"
	log_cmd "docker compose $*"
	docker compose "$@"
	log_success "Executed: docker compose $*"
	log_func_end "docker_compose_wrapper"
}

