#!/bin/bash

# Test file for package installation functionality
# Tests graceful handling of unavailable packages

set -euo pipefail

# Source the applications module to test
source "$(dirname "${BASH_SOURCE[0]}")/../src/applications.sh"

# Mock logging functions
log_section() { echo "=== $1 ==="; }
log_info() { echo "INFO: $1"; }
log_warn() { echo "WARN: $1"; }
log_success() { echo "SUCCESS: $1"; }

# Mock functions for testing
mock_apt() {
    case "$1" in
        "update")
            return 0  # Success
            ;;
        "upgrade")
            return 0  # Success
            ;;
        "install")
            shift
            local packages=("$@")
            # Simulate some packages failing
            for pkg in "${packages[@]}"; do
                case "$pkg" in
                    "docker"|"docker-compose-plugin"|"python3.11"|"python3.11-venv")
                        echo "E: Unable to locate package $pkg" >&2
                        return 1
                        ;;
                    *)
                        return 0  # Success
                        ;;
                esac
            done
            return 0
            ;;
        *)
            echo "Unknown apt command: $1" >&2
            return 1
            ;;
    esac
}

mock_dpkg() {
    case "$1" in
        "-l")
            # Simulate some packages already installed
            echo "ii  curl 1.0.0"
            echo "ii  git 2.0.0"
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Override commands for testing
apt() { mock_apt "$@"; }
dpkg() { mock_dpkg "$@"; }

# Test 1: Package installation with some unavailable packages
test_partial_package_failure() {
    echo "Testing package installation with some unavailable packages..."
    
    # Create test apps file with problematic packages
    mkdir -p /tmp/applications
    echo "curl
git
docker
python3.11
docker-compose-plugin" > /tmp/applications/apps.txt
    
    # Override apps file path for the test
    local original_script_dir="${SCRIPT_DIR:-}"
    SCRIPT_DIR="/tmp"
    
    # Run the function and capture result
    if install_packages; then
        echo "✓ PASS: Installation completed despite package failures"
        result=0
    else
        echo "✗ FAIL: Installation should not fail completely"
        result=1
    fi
    
    # Restore original SCRIPT_DIR if it existed
    if [[ -n "$original_script_dir" ]]; then
        SCRIPT_DIR="$original_script_dir"
    fi
    
    # Cleanup
    rm -rf /tmp/applications
    
    return $result
}

# Test 2: All packages available
test_all_packages_available() {
    echo "Testing installation when all packages are available..."
    
    # Create test apps file with available packages only
    mkdir -p /tmp/applications
    echo "curl
git" > /tmp/applications/apps.txt
    
    # Override apps file path for the test
    local original_script_dir="${SCRIPT_DIR:-}"
    SCRIPT_DIR="/tmp"
    
    # Run the function and capture result
    if install_packages; then
        echo "✓ PASS: Installation succeeded with all available packages"
        result=0
    else
        echo "✗ FAIL: Installation should succeed with available packages"
        result=1
    fi
    
    # Restore original SCRIPT_DIR if it existed
    if [[ -n "$original_script_dir" ]]; then
        SCRIPT_DIR="$original_script_dir"
    fi
    
    # Cleanup
    rm -rf /tmp/applications
    
    return $result
}

# Test 3: No packages to install
test_no_packages() {
    echo "Testing installation with no packages..."
    
    mkdir -p /tmp/applications
    echo "" > /tmp/applications/apps.txt
    
    # Override apps file path for the test
    local original_script_dir="${SCRIPT_DIR:-}"
    SCRIPT_DIR="/tmp"
    
    # Run the function and capture result
    if install_packages; then
        echo "✓ PASS: Installation succeeded with no packages"
        result=0
    else
        echo "✗ FAIL: Installation should succeed with no packages"
        result=1
    fi
    
    # Restore original SCRIPT_DIR if it existed
    if [[ -n "$original_script_dir" ]]; then
        SCRIPT_DIR="$original_script_dir"
    fi
    
    # Cleanup
    rm -rf /tmp/applications
    
    return $result
}

# Run tests
echo "Running package installation tests..."
echo "================================"

test_partial_package_failure
test_all_packages_available
test_no_packages

# Cleanup
rm -f /tmp/test_apps.txt

echo "All tests completed!"
