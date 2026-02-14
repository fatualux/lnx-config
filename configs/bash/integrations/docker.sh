#!/bin/bash

# Source logger with multiple fallback paths and guard against re-sourcing
if [[ -z "$__LOGGER_SOURCED" ]]; then
    _source_logger() {
        local logger_paths=(
            "${BASH_SOURCE%/*}/logger.sh"
            "$(dirname "${BASH_SOURCE[0]}")/logger.sh"
            "$HOME/.config/bash/logger.sh"
            "$HOME/.bashrc.d/logger.sh"
            "/etc/bash/logger.sh"
            "./logger.sh"
        )
        
        for path in "${logger_paths[@]}"; do
            if [ -f "$path" ]; then
                source "$path"
                return 0
            fi
        done
        
        # Fallback: create stub functions if logger not found
        echo "Warning: logger.sh not found in standard paths. Logging disabled." >&2
        log_func_start() { :; }
        log_func_end() { :; }
        log_debug() { :; }
        log_info() { echo "$@"; }
        log_warn() { echo "Warning: $@" >&2; }
        log_error() { echo "Error: $@" >&2; }
        log_docker_starting() { echo "Starting Docker..."; }
        log_docker_started() { echo "[OK] Docker started successfully"; }
        log_docker_failed() { echo "[X] Docker failed to start" >&2; }
        log_docker_running() { echo "[OK] Docker is running"; }
        log_docker_not_running() { echo "[!] Docker is not running"; }
        log_progress() { printf "$@"; }
        log_clear_line() { printf "\r\033[K"; }
        log_cmd() { :; }
        return 1
    }
    
    _source_logger
fi

# Source spinner utilities
if [[ -z "$__SPINNER_SOURCED" ]]; then
    _source_spinner() {
        local spinner_paths=(
            "${BASH_SOURCE%/*}/spinner.sh"
            "$(dirname "${BASH_SOURCE[0]}")/spinner.sh"
            "$HOME/.config/bash/spinner.sh"
            "$HOME/.bashrc.d/spinner.sh"
            "/etc/bash/spinner.sh"
            "./spinner.sh"
        )
        
        for path in "${spinner_paths[@]}"; do
            if [ -f "$path" ]; then
                source "$path"
                return 0
            fi
        done
        
        # Fallback stub functions
        spinner_start() { :; }
        spinner_stop() { :; }
        spinner_task() { eval "$2" >/dev/null 2>&1; }
        return 1
    }
    
    _source_spinner
fi

start_docker() {
  log_func_start "start_docker"
  log_docker_starting
  DOCKER_SOCK=/var/run/docker.sock
  MAX_WAIT=30
  INTERVAL=0.2
  START_TIME=$(date +%s)

  log_debug "Starting dockerd with TCP and Unix socket"
  log_cmd "nohup dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock"
  
  nohup dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock >~/dockerd.log 2>&1 &
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
    log_func_end "start_docker"
    return 1
  fi

  log_info "Starting kind containers..."
  spinner_task "Starting kind nodes" docker ps -a --format '{{.ID}} {{.Image}}' | awk '$2 ~ /kindest\/node/ {print $1}' | xargs -r docker start
  log_func_end "start_docker"
}

is_docker_running() {
  log_debug "Checking if Docker is running"
  [ -S /var/run/docker.sock ] && timeout 2 docker info &>/dev/null
}

docker_manager() {
  
  if ! command -v docker &>/dev/null; then
    log_error "Docker is not installed"
    log_func_end "docker_manager"
    return 1
  fi

  log_debug "Docker command found"
  if is_docker_running; then
    log_docker_running
  else
    log_docker_not_running
    start_docker
  fi
  log_func_end "docker_manager"
}

log_info "Initializing Docker manager"
docker_manager
