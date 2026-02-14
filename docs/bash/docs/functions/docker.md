# functions/docker/ Overview

## Purpose
Docker maintenance utilities to prune resources and manage compose usage.

## Contents
- docker_compose_file.sh: Run docker compose with a specific file.
- docker_compose_wrapper.sh: Wrapper around docker compose for convenience.
- docker_container_prune_force.sh: Force-prune unused containers.
- docker_network_prune_force.sh: Force-prune unused networks.
- docker_system_prune_force.sh: Force-prune unused system resources.
- kill_docker_containers.sh: Stop and remove all containers.
- OVERVIEW.md: This file.

## Usage Notes
- Requires Docker CLI and permissions to manage containers.
- Use with caution in shared environments.
