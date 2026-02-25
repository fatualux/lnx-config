#!/bin/bash

start_docker() {
  log_docker_starting
  DOCKER_SOCK=/var/run/docker.sock
  MAX_WAIT=30
  INTERVAL=0.2
  START_TIME=$(date +%s)

  log_debug "Starting dockerd with Unix socket"
  log_cmd "sudo dockerd -H unix:///var/run/docker.sock"
  
  sudo dockerd -H unix:///var/run/docker.sock >~/dockerd.log 2>&1 &
  local dockerd_pid=$!
  log_debug "Docker daemon PID: $dockerd_pid"

  spinner_start "Docker startup in progress"
  
  local elapsed=0
  while awk -v e="$elapsed" -v m="$MAX_WAIT" 'BEGIN {exit (e < m) ? 0 : 1}'; do
    if [ -S $DOCKER_SOCK ] && timeout 2 docker info >/dev/null 2>&1; then
      spinner_stop "Docker startup - Complete" "" 0
      log_debug "Docker started successfully"
      log_docker_started
      break
    fi
    
    sleep "$INTERVAL"
    elapsed=$(awk -v e="$elapsed" -v i="$INTERVAL" 'BEGIN {printf "%.1f", e + i}')
  done
  
  if ! [ -S $DOCKER_SOCK ] || ! timeout 2 docker info >/dev/null 2>&1; then
    spinner_stop "" "Docker startup - Failed" 1
    log_docker_failed
    log_error "Docker socket not ready after ${MAX_WAIT}s. Check ~/dockerd.log for details"
    tail -20 ~/dockerd.log | sed 's/^/  /'
    return 1
  fi

  log_info "Starting kind containers..."
  spinner_task "Starting kind nodes" docker ps -a --format '{{.ID}} {{.Image}}' | awk '$2 ~ /kindest\/node/ {print $1}' | xargs -r docker start
}

is_docker_running() {
  log_debug "Checking if Docker is running"
  [ -S /var/run/docker.sock ] && timeout 2 docker info &>/dev/null
}

docker_manager() {
  
  if ! command -v docker &>/dev/null; then
    log_error "Docker is not installed"
    return 1
  fi
}

# Only initialize Docker manager if not already running and command exists
if command -v docker &>/dev/null && [[ -z "$DOCKER_MANAGER_INITIALIZED" ]]; then
    docker_manager
    export DOCKER_MANAGER_INITIALIZED=1
fi
