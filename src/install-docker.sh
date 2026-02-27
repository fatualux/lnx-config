#!/bin/bash

# Docker installation module

# Set SCRIPT_DIR if not already set
: "${SCRIPT_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Source logger for logging functions
if [[ -f "$SCRIPT_DIR/logger.sh" ]]; then
    source "$SCRIPT_DIR/logger.sh"
fi

# Function to install Docker following official Debian guide
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
    
    log_info "Installing Docker on $PRETTY_NAME ($VERSION_CODENAME)"
    
    # Task 4: Add system compatibility detection
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
        log_info "Supported distributions: ${supported_codenames[*]}"
        log_info "Continuing with repository setup may fail"
        log_info "Alternative: Use Docker's official installation script"
        log_info "Visit: https://docs.docker.com/engine/install/"
    else
        log_success "Distribution $VERSION_CODENAME is supported"
    fi
    
    # Install required dependencies first
    log_info "Installing required dependencies..."
    local required_packages=("ca-certificates" "curl" "gnupg")
    
    if ! sudo apt update; then
        log_error "Failed to update package index"
        log_info "Alternative: Use Docker's official installation script"
        log_info "Visit: https://docs.docker.com/engine/install/"
        return 1
    fi
    
    if ! sudo apt install -y "${required_packages[@]}"; then
        log_error "Failed to install required dependencies: ${required_packages[*]}"
        log_info "Alternative: Install dependencies manually"
        log_info "Commands:"
        log_info "  sudo apt update"
        log_info "  sudo apt install -y ca-certificates curl gnupg"
        return 1
    fi
    
    log_success "Required dependencies installed successfully"
    
    # Step 1: Add Docker's official GPG key and repository
    log_info "Adding Docker's official GPG key and repository..."
    
    # Create keyrings directory
    if ! sudo install -m 0755 -d /etc/apt/keyrings; then
        log_error "Failed to create /etc/apt/keyrings directory"
        log_info "Alternative: Create directory manually with: sudo install -m 0755 -d /etc/apt/keyrings"
        return 1
    fi
    
    # Add Docker's official GPG key with enhanced error handling
    if ! curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg; then
        log_error "Failed to add Docker's GPG key"
        log_error "This may be due to:"
        log_error "  - Network connectivity issues"
        log_error "  - Repository access problems"
        log_error "  - GPG command not available"
        log_info "Alternative: Download GPG key manually and place in /etc/apt/keyrings/docker.gpg"
        log_info "Commands:"
        log_info "  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg"
        return 1
    fi
    
    # Check if keyring file exists
    if [[ ! -f "/etc/apt/keyrings/docker.gpg" ]]; then
        log_error "Docker GPG keyring file not found: /etc/apt/keyrings/docker.gpg"
        log_error "This indicates a problem with the GPG key installation process"
        log_info "Alternative: Create keyring file manually and retry installation"
        log_info "Commands:"
        log_info "  sudo touch /etc/apt/keyrings/docker.gpg"
        log_info "  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg"
        return 1
    fi
    
    log_success "Docker GPG key added successfully"
    
    # Add Docker repository with enhanced error handling
    if ! echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null; then
        log_error "Failed to add Docker repository"
        log_error "This may be due to:"
        log_error "  - OpenPGP signature verification failed"
        log_error "  - Unsupported distribution ($VERSION_CODENAME)"
        log_error "  - Repository signing issues"
        log_info "Alternative: Use Docker's official installation script"
        log_info "Visit: https://docs.docker.com/engine/install/"
        return 1
    fi
    
    log_success "Docker repository added successfully"
    
    # Step 2: Update package index and install Docker packages
    log_info "Updating package index and installing Docker packages..."
    
    if ! sudo apt update; then
        log_error "Failed to update package index"
        log_error "This may be due to repository signing issues"
        log_info "Alternative: Use Docker's official installation script"
        log_info "Visit: https://docs.docker.com/engine/install/"
        return 1
    fi
    
    log_success "Package index updated successfully"
    
    local docker_packages=(
        "docker-ce"
        "docker-ce-cli"
        "containerd.io"
        "docker-buildx-plugin"
        "docker-compose-plugin"
    )
    
    log_info "Installing Docker packages: ${docker_packages[*]}"
    
    if ! sudo apt install -y "${docker_packages[@]}"; then
        log_error "Failed to install Docker packages"
        log_error "This may be due to repository issues or package conflicts"
        log_info "Alternative: Use Docker's official installation script"
        log_info "Visit: https://docs.docker.com/engine/install/"
        return 1
    fi
    
    log_success "Docker packages installed successfully"
    
    # Step 3: Start and enable Docker daemon service
    log_info "Starting and enabling Docker daemon service..."
    
    if ! sudo systemctl enable --now docker; then
        log_error "Failed to start and enable Docker daemon"
        log_info "Alternative: Start Docker daemon manually"
        log_info "Commands:"
        log_info "  sudo systemctl start docker"
        log_info "  sudo systemctl enable docker"
        return 1
    fi
    
    log_success "Docker daemon started and enabled"
    
    # Step 4: Verify Docker daemon is active
    log_info "Verifying Docker daemon status..."
    
    local daemon_status
    daemon_status=$(sudo systemctl is-active docker)
    
    if [[ "$daemon_status" != "active" ]]; then
        log_error "Docker daemon is not active (status: $daemon_status)"
        log_info "Alternative: Check Docker daemon status manually"
        log_info "Commands:"
        log_info "  sudo systemctl status docker"
        log_info "  sudo journalctl -u docker"
        return 1
    fi
    
    log_success "Docker daemon is active"
    
    # Step 5: Test installation with hello-world image
    log_info "Testing Docker installation with hello-world image..."
    
    if ! docker run hello-world; then
        log_error "Docker installation verification failed"
        log_error "This may be due to Docker daemon issues or network problems"
        log_info "Alternative: Test Docker installation manually"
        log_info "Commands:"
        log_info "  docker --version"
        log_info "  docker run hello-world"
        return 1
    fi
    
    log_success "Docker installation verified successfully with hello-world test"
    log_info "Docker is now ready for use!"
    
    return 0
}

# Function to check if Docker is already installed
is_docker_installed() {
    command -v docker &> /dev/null && docker --version &> /dev/null
}

# Function to check if Docker daemon is running
is_docker_daemon_running() {
    systemctl is-active docker &> /dev/null
}

# Function to get Docker version
get_docker_version() {
    if command -v docker &> /dev/null; then
        docker --version | head -n1
    else
        echo "Docker not installed"
    fi
}

# Function to get Docker daemon status
get_docker_daemon_status() {
    if systemctl is-active docker &> /dev/null; then
        echo "active"
    else
        echo "inactive"
    fi
}
