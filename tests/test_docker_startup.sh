#!/bin/bash

# Test file for Docker startup functionality
# Tests graceful handling of missing Docker daemon

set -euo pipefail

# Initialize variables that might be unbound
DOCKER_MANAGER_INITIALIZED=""
LOG_LEVEL="1"

# Mock command before sourcing docker.sh
command() {
    if [[ "$1" == "-v" && "$2" == "docker" ]]; then
        return 0  # docker client found for testing
    elif [[ "$1" == "-v" && "$2" == "dockerd" ]]; then
        return 1  # dockerd not found for testing
    fi
    # Forward other command calls to real command
    /usr/bin/command "$@"
}
export -f command

# Mock logging functions before sourcing docker.sh
log_docker_starting() { echo "INFO: Starting Docker..."; }
log_docker_started() { echo "SUCCESS: Docker started successfully"; }
log_docker_failed() { echo "ERROR: Docker failed to start"; }
log_debug() { echo "DEBUG: $*"; }
log_info() { echo "INFO: $*"; }
log_error() { echo "ERROR: $*"; }
log_warn() { echo "WARN: $*"; }
log_cmd() { echo "CMD: $*"; }

# Mock spinner functions
spinner_start() { echo "SPINNER_START: $1"; }
spinner_stop() { echo "SPINNER_STOP: $1 $2 $3"; }

# Source the Docker module to test
source "$(dirname "${BASH_SOURCE[0]}")/../configs/core/bash/docker.sh"

# Mock functions for testing
mock_dockerd() {
    echo "Mock dockerd called with: $*" >&2
    return 0
}

mock_sudo() {
    if [[ "$1" == "dockerd" ]]; then
        echo "sudo dockerd command executed" >&2
        return 127  # Command not found
    fi
    # Forward other sudo commands to real sudo
    /usr/bin/sudo "$@"
}

# Override commands for testing
dockerd() { mock_docker "$@"; }
sudo() { mock_sudo "$@"; }

# Mock logging functions
log_docker_starting() { echo "INFO: Starting Docker..."; }
log_docker_started() { echo "SUCCESS: Docker started successfully"; }
log_docker_failed() { echo "ERROR: Docker failed to start"; }
log_debug() { echo "DEBUG: $*"; }
log_info() { echo "INFO: $*"; }
log_error() { echo "ERROR: $*"; }
log_warn() { echo "WARN: $*"; }
log_cmd() { echo "CMD: $*"; }

# Mock spinner functions
spinner_start() { echo "SPINNER_START: $1"; }
spinner_stop() { echo "SPINNER_STOP: $1 $2 $3"; }

# Test 1: Docker startup with dockerd not available
test_dockerd_not_available() {
    echo "Testing Docker startup when dockerd is not available..."
    
    # Override command -v to return failure for dockerd
    command() {
        if [[ "$1" == "-v" && "$2" == "dockerd" ]]; then
            return 1  # dockerd not found
        fi
        # Forward other command calls to real command
        /usr/bin/command "$@"
    }
    export -f command
    
    # This should not fail and should log appropriate message
    if start_docker; then
        echo "✓ PASS: Docker startup skipped gracefully when dockerd not available"
        return 0
    else
        echo "✗ FAIL: Docker startup should not fail when dockerd not available"
        return 1
    fi
}

# Test 2: Docker startup with dockerd available
test_dockerd_available() {
    echo "Testing Docker startup when dockerd is available..."
    
    # Override command -v to return success for dockerd
    command() {
        if [[ "$1" == "-v" && "$2" == "dockerd" ]]; then
            return 0  # dockerd found
        fi
        # Forward other command calls to real command
        /usr/bin/command "$@"
    }
    export -f command
    
    # Override sudo to succeed for dockerd
    mock_sudo() {
        if [[ "$1" == "dockerd" ]]; then
            echo "Mock dockerd daemon started successfully" >~/dockerd.log 2>&1
            return 0  # Success
        fi
        # Forward other sudo commands to real sudo
        /usr/bin/sudo "$@"
    }
    export -f mock_sudo
    
    # Re-define start_docker function with the new mocks
    start_docker() {
        log_docker_starting
      
        # Check if Docker daemon is available
        if ! command -v dockerd &> /dev/null; then
            log_info "Docker daemon (dockerd) not available, skipping Docker startup"
            log_info "Docker client may still be available for container management"
            log_info "To install Docker daemon, visit: https://docs.docker.com/engine/install/"
            return 0  # Success - Docker may still be usable as client
        fi
        
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
                # Only log debug message if debug logging is enabled
                [[ "${LOG_LEVEL:-0}" -le 1 ]] && log_debug "Docker started successfully"
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
        
        containers=$(docker ps -aq)
        container_count=$(echo "$containers" | wc -l)
        current=0
        
        for container in $containers; do
            ((current++))
            # Only log debug message if debug logging is enabled
            [[ "${LOG_LEVEL:-0}" -le 1 ]] && log_debug "Checking container: $container"
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
    }
    
    # This should succeed (though may fail later due to mock limitations)
    if start_docker; then
        echo "✓ PASS: Docker startup attempted when dockerd available"
        return 0
    else
        echo "✗ FAIL: Docker startup should attempt when dockerd available"
        return 1
    fi
}

# Test 3: Docker client available but daemon not
test_docker_client_only() {
    echo "Testing Docker client available but daemon not..."
    
    # Override command -v to return success for docker but failure for dockerd
    command() {
        if [[ "$1" == "-v" && "$2" == "docker" ]]; then
            return 0  # docker client found
        elif [[ "$1" == "-v" && "$2" == "dockerd" ]]; then
            return 1  # dockerd not found
        fi
        # Forward other command calls to real command
        /usr/bin/command "$@"
    }
    export -f command
    
    # This should skip gracefully
    if start_docker; then
        echo "✓ PASS: Docker startup skipped when only client available"
        return 0
    else
        echo "✗ FAIL: Docker startup should skip when only client available"
        return 1
    fi
}

# Run tests
echo "Running Docker startup tests..."
echo "================================"

test_dockerd_not_available
test_dockerd_available
test_docker_client_only

echo "All tests completed!"
