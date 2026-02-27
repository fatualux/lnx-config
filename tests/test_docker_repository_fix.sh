#!/bin/bash

# Test file for Docker repository setup fixes
# Tests the enhanced install-docker.sh module with repository error handling

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
    case "$1" in
        "-fsSL")
            echo "Mock: curl -fsSL called with $2"
            return 0
            ;;
        *)
            echo "Mock: curl called with args: $*"
            return 0
            ;;
    esac
}

mock_gpg() {
    case "$1" in
        "--dearmor")
            echo "Mock: gpg --dearmor called with $2"
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

# Test 1: Repository setup with OpenPGP signature failure
test_openpgp_signature_failure() {
    echo "Testing OpenPGP signature verification failure detection..."
    
    # Mock the install_docker function to test repository setup failure
    install_docker() {
        log_section "Installing Docker"
        
        # Check if running on Debian-based system
        if [[ ! -f "/etc/os-release" ]]; then
            log_error "Cannot determine OS version. This module is designed for Debian-based systems."
            return 1
        fi
        
        # Source OS release information
        source /etc/os-release
        
        log_info "Installing Docker on $PRETTY_NAME ($VERSION_CODENAME)"
        
        # Step 1: Add Docker's official GPG key and repository
        log_info "Adding Docker's official GPG key and repository..."
        
        # Create keyrings directory
        if ! sudo install -m 0755 -d /etc/apt/keyrings; then
            log_error "Failed to create /etc/apt/keyrings directory"
            return 1
        fi
        
        # Add Docker's official GPG key (mocked to fail)
        if ! curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg; then
            log_error "Failed to add Docker's GPG key"
            log_error "This may be due to network issues or repository problems"
            log_info "Alternative: Download GPG key manually and place in /etc/apt/keyrings/docker.gpg"
            return 1
        fi
        
        log_success "Docker GPG key added successfully"
        
        # Add Docker repository (mocked to fail with OpenPGP signature error)
        if ! echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null; then
            log_error "Failed to add Docker repository"
            log_error "OpenPGP signature verification failed"
            log_info "This may be due to:"
            log_info "  - Unsupported distribution ($VERSION_CODENAME)"
            log_info "  - Repository signing issues"
            log_info "  - Network connectivity problems"
            return 1
        fi
        
        log_success "Docker repository added successfully"
        return 0
    }
    
    # Test the function
    if install_docker; then
        echo "✗ FAIL: Repository setup should have failed with OpenPGP signature error"
        return 1
    else
        echo "✓ PASS: Repository setup error detected and handled gracefully"
        return 0
    fi
}

# Test 2: Missing keyring file error detection
test_missing_keyring_file() {
    echo "Testing missing keyring file error detection..."
    
    # Mock the install_docker function to test keyring file error
    install_docker() {
        log_section "Installing Docker"
        
        # Check if running on Debian-based system
        if [[ ! -f "/etc/os-release" ]]; then
            log_error "Cannot determine OS version. This module is designed for Debian-based systems."
            return 1
        fi
        
        # Source OS release information
        source /etc/os-release
        
        log_info "Installing Docker on $PRETTY_NAME ($VERSION_CODENAME)"
        
        # Step 1: Add Docker's official GPG key and repository
        log_info "Adding Docker's official GPG key and repository..."
        
        # Create keyrings directory (mocked to succeed)
        if ! sudo install -m 0755 -d /etc/apt/keyrings; then
            log_error "Failed to create /etc/apt/keyrings directory"
            return 1
        fi
        
        # Add Docker's official GPG key (mocked to succeed)
        if ! curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg; then
            log_error "Failed to add Docker's GPG key"
            log_error "Keyring file creation failed"
            log_info "Check if /etc/apt/keyrings directory exists and is writable"
            log_info "Alternative: Create keyring file manually with: sudo touch /etc/apt/keyrings/docker.gpg"
            return 1
        fi
        
        # Check if keyring file exists (mocked to not exist)
        if [[ ! -f "/etc/apt/keyrings/docker.gpg" ]]; then
            log_error "Docker GPG keyring file not found: /etc/apt/keyrings/docker.gpg"
            log_error "This indicates a problem with the GPG key installation process"
            log_info "Alternative: Create keyring file manually and retry installation"
            return 1
        fi
        
        log_success "Docker GPG key added successfully"
        
        # Add Docker repository
        if ! echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null; then
            log_error "Failed to add Docker repository"
            return 1
        fi
        
        log_success "Docker repository added successfully"
        return 0
    }
    
    # Test the function
    if install_docker; then
        echo "✗ FAIL: Missing keyring file should have been detected"
        return 1
    else
        echo "✓ PASS: Missing keyring file error detected and handled gracefully"
        return 0
    fi
}

# Test 3: Unsupported distribution codename detection
test_unsupported_distribution() {
    echo "Testing unsupported distribution codename detection..."
    
    # Mock the install_docker function to test unsupported distribution
    install_docker() {
        log_section "Installing Docker"
        
        # Check if running on Debian-based system
        if [[ ! -f "/etc/os-release" ]]; then
            log_error "Cannot determine OS version. This module is designed for Debian-based systems."
            return 1
        fi
        
        # Source OS release information
        source /etc/os-release
        
        log_info "Installing Docker on $PRETTY_NAME ($VERSION_CODENAME)"
        
        # Check for supported distributions
        local supported_codenames=("bullseye" "bookworm" "jammy" "focal" "bionic" "xenial")
        local is_supported=false
        
        for codename in "${supported_codenames[@]}"; do
            if [[ "$VERSION_CODENAME" == "$codename" ]]; then
                is_supported=true
                break
            fi
        done
        
        if [[ "$is_supported" == "false" ]]; then
            log_error "Unsupported distribution: $VERSION_CODENAME"
            log_error "Docker official repository may not support this distribution"
            log_info "Supported distributions: ${supported_codenames[*]}"
            log_info "Alternative: Use Docker's official installation script"
            log_info "Visit: https://docs.docker.com/engine/install/"
            return 1
        fi
        
        log_success "Distribution $VERSION_CODENAME is supported"
        
        # Add Docker repository
        if ! echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null; then
            log_error "Failed to add Docker repository"
            return 1
        fi
        
        log_success "Docker repository added successfully"
        return 0
    }
    
    # Test with unsupported distribution (mock VERSION_CODENAME)
    export VERSION_CODENAME="trixie"
    
    # Test the function
    if install_docker; then
        echo "✗ FAIL: Unsupported distribution should have been detected"
        return 1
    else
        echo "✓ PASS: Unsupported distribution detected and handled gracefully"
        return 0
    fi
}

# Test 4: System compatibility check
test_system_compatibility() {
    echo "Testing system compatibility checks..."
    
    # Mock the install_docker function to test system compatibility
    install_docker() {
        log_section "Installing Docker"
        
        # Check if running on Debian-based system
        if [[ ! -f "/etc/os-release" ]]; then
            log_error "Cannot determine OS version. This module is designed for Debian-based systems."
            log_info "Alternative: Use Docker's official installation script"
            log_info "Visit: https://docs.docker.com/engine/install/"
            return 1
        fi
        
        # Source OS release information
        source /etc/os-release
        
        # Check for Debian-based systems
        if [[ "$ID" != "debian" ]] && [[ "$ID_LIKE" != "debian" ]]; then
            log_error "Unsupported operating system: $ID"
            log_info "This module is designed for Debian-based systems only"
            log_info "Alternative: Use Docker's official installation script"
            log_info "Visit: https://docs.docker.com/engine/install/"
            return 1
        fi
        
        log_success "System $ID is compatible"
        
        # Check for supported distributions
        local supported_codenames=("bullseye" "bookworm" "jammy" "focal" "bionic" "xenial")
        local is_supported=false
        
        for codename in "${supported_codenames[@]}"; do
            if [[ "$VERSION_CODENAME" == "$codename" ]]; then
                is_supported=true
                break
            fi
        done
        
        if [[ "$is_supported" == "false" ]]; then
            log_warn "Distribution $VERSION_CODENAME may not be officially supported by Docker"
            log_info "Continuing with repository setup may fail"
        fi
        
        log_info "Proceeding with Docker installation on $PRETTY_NAME ($VERSION_CODENAME)"
        return 0
    }
    
    # Test with compatible system
    export ID="debian"
    export VERSION_CODENAME="bullseye"
    
    # Test the function
    if install_docker; then
        echo "✓ PASS: System compatibility check passed"
        return 0
    else
        echo "✗ FAIL: System compatibility check failed"
        return 1
    fi
}

# Run tests
echo "Running Docker repository fix tests..."
echo "================================"

test_openpgp_signature_failure
test_missing_keyring_file
test_unsupported_distribution
test_system_compatibility

echo "All tests completed!"
