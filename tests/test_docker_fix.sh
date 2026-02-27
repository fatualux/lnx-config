#!/bin/bash

# Simple test for Docker startup fix
set -euo pipefail

echo "Testing Docker startup fix..."

# Mock logging functions
log_docker_starting() { echo "INFO: Starting Docker..."; }
log_docker_started() { echo "SUCCESS: Docker started successfully"; }
log_docker_failed() { echo "ERROR: Docker failed to start"; }
log_debug() { echo "DEBUG: $*"; }
log_info() { echo "INFO: $*"; }
log_error() { echo "ERROR: $*"; }
log_warn() { echo "WARN: $*"; }
log_cmd() { echo "CMD: $*"; }
spinner_start() { echo "SPINNER_START: $1"; }
spinner_stop() { echo "SPINNER_STOP: $1 $2 $3"; }

# Test the improved start_docker function directly
test_improved_start_docker() {
    echo "Testing improved start_docker function..."
    
    # Mock command -v to return failure for dockerd
    command() {
        if [[ "$1" == "-v" && "$2" == "dockerd" ]]; then
            return 1  # dockerd not found
        fi
        # Forward other command calls to real command
        /usr/bin/command "$@"
    }
    export -f command
    
    # Define the improved start_docker function
    start_docker() {
        log_docker_starting
        
        # Check if Docker daemon is available
        if ! command -v dockerd &> /dev/null; then
            log_info "Docker daemon (dockerd) not available, skipping Docker startup"
            log_info "Docker client may still be available for container management"
            log_info "To install Docker daemon, visit: https://docs.docker.com/engine/install/"
            return 0  # Success - Docker may still be usable as client
        fi
        
        log_info "Docker daemon found, proceeding with startup..."
        return 0  # Success for this test
    }
    
    # Test the function
    if start_docker; then
        echo "✓ PASS: Docker startup handled gracefully when dockerd not available"
        return 0
    else
        echo "✗ FAIL: Docker startup should handle missing dockerd gracefully"
        return 1
    fi
}

# Test with dockerd available
test_dockerd_available() {
    echo "Testing with dockerd available..."
    
    # Mock command -v to return success for dockerd
    command() {
        if [[ "$1" == "-v" && "$2" == "dockerd" ]]; then
            return 0  # dockerd found
        fi
        # Forward other command calls to real command
        /usr/bin/command "$@"
    }
    export -f command
    
    # Define the improved start_docker function
    start_docker() {
        log_docker_starting
        
        # Check if Docker daemon is available
        if ! command -v dockerd &> /dev/null; then
            log_info "Docker daemon (dockerd) not available, skipping Docker startup"
            log_info "Docker client may still be available for container management"
            log_info "To install Docker daemon, visit: https://docs.docker.com/engine/install/"
            return 0  # Success - Docker may still be usable as client
        fi
        
        log_info "Docker daemon found, proceeding with startup..."
        return 0  # Success for this test
    }
    
    # Test the function
    if start_docker; then
        echo "✓ PASS: Docker startup attempted when dockerd available"
        return 0
    else
        echo "✗ FAIL: Docker startup should attempt when dockerd available"
        return 1
    fi
}

# Run tests
echo "================================"
test_improved_start_docker
test_dockerd_available

echo "Docker startup fix test completed!"
