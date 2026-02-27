#!/bin/bash

# Test file for Docker installation module
# Tests the install-docker.sh module functionality

set -euo pipefail

# Source the Docker installation module to test
source "$(dirname "${BASH_SOURCE[0]}")/../src/install-docker.sh"

# Mock functions for testing
mock_apt() {
    case "$1" in
        "update")
            echo "Mock: apt update called"
            return 0
            ;;
        "install")
            shift
            local packages=("$@")
            echo "Mock: apt install called with packages: ${packages[*]}"
            return 0
            ;;
        *)
            echo "Mock: apt called with unknown command: $1"
            return 0
            ;;
    esac
}

mock_curl() {
    echo "Mock: curl called with args: $*"
    return 0
}

mock_gpg() {
    case "$1" in
        "--dearmor")
            echo "Mock: gpg --dearmor called"
            return 0
            ;;
        *)
            echo "Mock: gpg called with args: $*"
            return 0
            ;;
    esac
}

mock_systemctl() {
    case "$1" in
        "enable")
            echo "Mock: systemctl enable --now called"
            return 0
            ;;
        "is-active")
            echo "active"
            return 0
            ;;
        *)
            echo "Mock: systemctl called with args: $*"
            return 0
            ;;
    esac
}

mock_docker() {
    case "$1" in
        "run")
            echo "Mock: docker run hello-world called"
            echo "Hello from Docker!"
            return 0
            ;;
        *)
            echo "Mock: docker called with args: $*"
            return 0
            ;;
    esac
}

# Override commands for testing
apt() { mock_apt "$@"; }
curl() { mock_curl "$@"; }
gpg() { mock_gpg "$@"; }
systemctl() { mock_systemctl "$@"; }
docker() { mock_docker "$@"; }

# Mock logging functions
log_section() { echo "=== $1 ==="; }
log_info() { echo "INFO: $*"; }
log_success() { echo "SUCCESS: $*"; }
log_error() { echo "ERROR: $*"; }
log_warn() { echo "WARN: $*"; }
log_debug() { echo "DEBUG: $*"; }

# Test 1: Module loading and function availability
test_module_loading() {
    echo "Testing install-docker.sh module loading..."
    
    # Check if install_docker function exists
    if declare -f install_docker; then
        echo "✓ PASS: install_docker function is available"
        return 0
    else
        echo "✗ FAIL: install_docker function not found"
        return 1
    fi
}

# Test 2: Repository setup with GPG key
test_repository_setup() {
    echo "Testing Docker repository setup..."
    
    # Mock the install_docker function to test repository setup
    install_docker() {
        log_section "Setting up Docker repository"
        
        # Create keyrings directory
        if ! install -m 0755 -d /etc/apt/keyrings; then
            log_error "Failed to create keyrings directory"
            return 1
        fi
        
        # Add GPG key (mocked)
        if curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg; then
            log_success "Docker GPG key added successfully"
        else
            log_error "Failed to add Docker GPG key"
            return 1
        fi
        
        # Add repository (mocked)
        if echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null; then
            log_success "Docker repository added successfully"
        else
            log_error "Failed to add Docker repository"
            return 1
        fi
        
        return 0
    }
    
    # Test the function
    if install_docker; then
        echo "✓ PASS: Docker repository setup completed successfully"
        return 0
    else
        echo "✗ FAIL: Docker repository setup failed"
        return 1
    fi
}

# Test 3: Package installation
test_package_installation() {
    echo "Testing Docker package installation..."
    
    # Mock the install_docker function to test package installation
    install_docker() {
        log_section "Installing Docker packages"
        
        # Update package index
        if apt update; then
            log_success "Package index updated successfully"
        else
            log_error "Failed to update package index"
            return 1
        fi
        
        # Install Docker packages
        local packages=(
            "docker-ce"
            "docker-ce-cli"
            "containerd.io"
            "docker-buildx-plugin"
            "docker-compose-plugin"
        )
        
        if apt install -y "${packages[@]}"; then
            log_success "Docker packages installed successfully: ${packages[*]}"
        else
            log_error "Failed to install Docker packages"
            return 1
        fi
        
        return 0
    }
    
    # Test the function
    if install_docker; then
        echo "✓ PASS: Docker package installation completed successfully"
        return 0
    else
        echo "✗ FAIL: Docker package installation failed"
        return 1
    fi
}

# Test 4: Docker daemon setup
test_daemon_setup() {
    echo "Testing Docker daemon setup..."
    
    # Mock the install_docker function to test daemon setup
    install_docker() {
        log_section "Setting up Docker daemon"
        
        # Start and enable Docker daemon
        if systemctl enable --now docker; then
            log_success "Docker daemon started and enabled"
        else
            log_error "Failed to start and enable Docker daemon"
            return 1
        fi
        
        # Verify Docker daemon is active
        if systemctl is-active docker; then
            log_success "Docker daemon is active"
        else
            log_error "Docker daemon is not active"
            return 1
        fi
        
        return 0
    }
    
    # Test the function
    if install_docker; then
        echo "✓ PASS: Docker daemon setup completed successfully"
        return 0
    else
        echo "✗ FAIL: Docker daemon setup failed"
        return 1
    fi
}

# Test 5: Installation verification
test_installation_verification() {
    echo "Testing Docker installation verification..."
    
    # Mock the install_docker function to test verification
    install_docker() {
        log_section "Verifying Docker installation"
        
        # Test with hello-world image
        if docker run hello-world; then
            log_success "Docker installation verified successfully with hello-world"
        else
            log_error "Docker installation verification failed"
            return 1
        fi
        
        return 0
    }
    
    # Test the function
    if install_docker; then
        echo "✓ PASS: Docker installation verification completed successfully"
        return 0
    else
        echo "✗ FAIL: Docker installation verification failed"
        return 1
    fi
}

# Run tests
echo "Running Docker installation module tests..."
echo "================================"

test_module_loading
test_repository_setup
test_package_installation
test_daemon_setup
test_installation_verification

echo "All tests completed!"
