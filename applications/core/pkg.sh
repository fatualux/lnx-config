#!/bin/bash

resolve_package_name() {
    local package="$1"
    local os="$2"

    case "$os" in
        debian|ubuntu)
            case "$package" in
                python)
                    echo "python3"
                    return 0
                    ;;
                openssh)
                    echo "openssh-client"
                    return 0
                    ;;
                code)
                    if command -v apt-cache >/dev/null 2>&1 && apt-cache show code >/dev/null 2>&1; then
                        echo "code"
                        return 0
                    fi
                    echo ""
                    return 0
                    ;;
            esac
            ;;
        arch|manjaro)
            case "$package" in
                python)
                    echo "python"
                    return 0
                    ;;
                openssh)
                    echo "openssh"
                    return 0
                    ;;
            esac
            ;;
        fedora|rhel|centos)
            case "$package" in
                python)
                    echo "python3"
                    return 0
                    ;;
                openssh)
                    echo "openssh-clients"
                    return 0
                    ;;
            esac
            ;;
        alpine)
            case "$package" in
                python)
                    echo "python3"
                    return 0
                    ;;
                openssh)
                    echo "openssh"
                    return 0
                    ;;
            esac
            ;;
        opensuse)
            case "$package" in
                python)
                    echo "python3"
                    return 0
                    ;;
                openssh)
                    echo "openssh"
                    return 0
                    ;;
            esac
            ;;
    esac

    echo "$package"
}

update_package_cache() {
    local os="$1"
    local output=""

    log_info "Updating package manager cache..."

    safe_spinner_start "Updating package cache"

    case "$os" in
        debian|ubuntu)
            if output=$(sudo apt-get update -y 2>&1); then
                log_debug "apt-get update completed successfully"
            else
                log_warning "apt-get update had some warnings"
                echo "$output" >> "$LOG_FILE"
            fi
            ;;
        arch|manjaro)
            if output=$(sudo pacman -Sy 2>&1); then
                log_debug "pacman -Sy completed successfully"
            else
                log_warning "pacman -Sy had some warnings"
                echo "$output" >> "$LOG_FILE"
            fi
            ;;
        fedora|rhel|centos)
            output=$(sudo dnf check-update 2>&1 || true)
            log_debug "dnf check-update completed"
            ;;
        alpine)
            if output=$(sudo apk update 2>&1); then
                log_debug "apk update completed successfully"
            else
                log_warning "apk update had some warnings"
                echo "$output" >> "$LOG_FILE"
            fi
            ;;
        opensuse)
            if output=$(sudo zypper refresh 2>&1); then
                log_debug "zypper refresh completed successfully"
            else
                log_warning "zypper refresh had some warnings"
                echo "$output" >> "$LOG_FILE"
            fi
            ;;
    esac

    safe_spinner_stop "Package cache updated" "Package cache update failed" 0

    log_success "Package cache updated"
}

install_package() {
    local package="$1"
    local os="$2"
    local resolved_package=""
    local install_cmd=""
    local output=""
    local exit_code=0

    resolved_package=$(resolve_package_name "$package" "$os")
    if [[ -z "$resolved_package" ]]; then
        log_warning "Skipping $package: package not available in current repositories (may require adding a vendor repo)"
        SKIPPED_PACKAGES+=("$package")
        echo "$(date '+%Y-%m-%d %H:%M:%S') [SKIPPED] $package - Not available" >> "$LOG_FILE"
        {
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Skipped install: $package"
            echo "Reason: package not available in current repositories"
            echo "---"
        } >> "$ERROR_LOG_FILE"
        return 0
    fi

    case "$os" in
        debian|ubuntu)
            install_cmd="apt-get install -y $resolved_package"
            ;;
        arch|manjaro)
            install_cmd="pacman -S --noconfirm $resolved_package"
            ;;
        fedora|rhel|centos)
            install_cmd="dnf install -y $resolved_package"
            ;;
        alpine)
            install_cmd="apk add $resolved_package"
            ;;
        opensuse)
            install_cmd="zypper install -y $resolved_package"
            ;;
        *)
            log_error "Unsupported OS: $os"
            return 1
            ;;
    esac

    if [[ "$resolved_package" != "$package" ]]; then
        log_info "Installing $package (as $resolved_package)..."
    else
        log_info "Installing $package..."
    fi

    safe_spinner_start "Installing $package"
    output=$(sudo $install_cmd 2>&1) || exit_code=$?
    safe_spinner_stop "Installed $package" "Failed $package" "$exit_code"

    if [ $exit_code -eq 0 ]; then
        log_success "$package installed successfully"
        echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] Installed: $package" >> "$LOG_FILE"
        SUCCESSFUL_PACKAGES+=("$package")
    else
        log_error "Failed to install $package (exit code: $exit_code)"
        echo "$(date '+%Y-%m-%d %H:%M:%S') [FAILED] $package - Exit code: $exit_code" >> "$LOG_FILE"
        echo "$output" >> "$LOG_FILE"
        FAILED_PACKAGES+=("$package")
        {
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to install: $package"
            echo "Command: sudo $install_cmd"
            echo "Exit Code: $exit_code"
            echo "Output: $output"
            echo "---"
        } >> "$ERROR_LOG_FILE"
    fi

    return $exit_code
}

# Try installing package with multiple package managers gracefully
try_install_with_fallback() {
    local package="$1"
    local managers=($(detect_package_managers))
    local last_error=""
    local success=false
    
    log_info "Attempting to install $package with available package managers..."
    
    for manager in "${managers[@]}"; do
        local os=$(map_pm_to_os "$manager")
        log_info "Trying $manager (OS: $os)..."
        
        if install_package "$package" "$os"; then
            log_success "Successfully installed $package using $manager"
            success=true
            break
        else
            last_error="Failed with $manager"
            log_warning "$last_error"
        fi
    done
    
    if ! $success; then
        log_error "Failed to install $package with all available package managers"
        log_error "Available managers: ${managers[*]}"
        log_error "Last error: $last_error"
        FAILED_PACKAGES+=("$package")
        return 1
    fi
    
    return 0
}
