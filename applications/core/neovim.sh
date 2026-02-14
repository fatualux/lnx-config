#!/bin/bash

install_neovim() {
    local os="$1"
    local exit_code=0

    case "$os" in
        arch|manjaro)
            if [[ "${NEOVIM_DEV:-0}" == "1" ]]; then
                if command -v yay >/dev/null 2>&1; then
                    log_info "Installing neovim-git (AUR) via yay"
                    if yay -S --noconfirm neovim-git 2>&1 | tee -a "$LOG_FILE" >/dev/null; then
                        log_success "neovim-git installed successfully"
                        SUCCESSFUL_PACKAGES+=("neovim-git")
                        return 0
                    fi
                    log_error "Failed to install neovim-git"
                    FAILED_PACKAGES+=("neovim-git")
                    return 1
                else
                    log_warning "NEOVIM_DEV=1 set but yay not found; falling back to official neovim package"
                fi
            fi

            log_info "Installing neovim via pacman"
            install_package "neovim" "$os"
            ;;

        debian|ubuntu)
            log_info "Installing Neovim from source (Debian/Ubuntu)"
            sudo apt-get update -y 2>&1 | tee -a "$LOG_FILE" || true

            local deps=(ninja-build gettext cmake unzip curl git build-essential pkg-config)
            log_info "Installing build prerequisites: ${deps[*]}"
            safe_spinner_start "Neovim: installing build prerequisites"
            if ! sudo apt-get install -y "${deps[@]}" 2>&1 | tee -a "$LOG_FILE"; then
                safe_spinner_stop "Neovim prerequisites installed" "Neovim prerequisites failed" 1
                log_error "Failed to install Neovim build prerequisites"
                FAILED_PACKAGES+=("neovim")
                return 1
            fi
            safe_spinner_stop "Neovim prerequisites installed" "Neovim prerequisites failed" 0

            local build_dir
            build_dir=$(mktemp -d 2>/dev/null || echo "")
            if [[ -z "$build_dir" ]]; then
                log_error "Failed to create temporary build directory"
                FAILED_PACKAGES+=("neovim")
                return 1
            fi

            safe_spinner_start "Neovim: building from source"
            (
                set -e
                cd "$build_dir"
                git clone https://github.com/neovim/neovim
                cd neovim
                make CMAKE_BUILD_TYPE=RelWithDebInfo
                sudo make install
            ) > >(tee -a "$LOG_FILE") 2> >(tee -a "$LOG_FILE" >&2) || exit_code=$?

            if [[ $exit_code -ne 0 ]]; then
                safe_spinner_stop "Neovim build complete" "Neovim build failed" "$exit_code"
                log_error "Neovim build/install failed"
                FAILED_PACKAGES+=("neovim")
                {
                    echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to install: neovim"
                    echo "Method: build from source (Debian/Ubuntu)"
                    echo "Exit Code: $exit_code"
                    echo "Build dir: $build_dir"
                    echo "Log: $LOG_FILE"
                    echo "---"
                } >> "$ERROR_LOG_FILE"
                rm -rf "$build_dir" 2>/dev/null || true
                return 1
            fi

            safe_spinner_stop "Neovim build complete" "Neovim build failed" 0

            rm -rf "$build_dir" 2>/dev/null || true
            log_success "Neovim installed successfully"
            SUCCESSFUL_PACKAGES+=("neovim")
            return 0
            ;;

        fedora|rhel|centos)
            log_info "Installing Neovim from source (Fedora/RHEL)"

            local deps=(ninja-build cmake gcc gcc-c++ make pkgconfig unzip patch gettext curl git)
            log_info "Installing build prerequisites: ${deps[*]}"
            safe_spinner_start "Neovim: installing build prerequisites"
            if ! sudo dnf install -y "${deps[@]}" 2>&1 | tee -a "$LOG_FILE"; then
                safe_spinner_stop "Neovim prerequisites installed" "Neovim prerequisites failed" 1
                log_error "Failed to install Neovim build prerequisites"
                FAILED_PACKAGES+=("neovim")
                return 1
            fi
            safe_spinner_stop "Neovim prerequisites installed" "Neovim prerequisites failed" 0

            local build_dir
            build_dir=$(mktemp -d 2>/dev/null || echo "")
            if [[ -z "$build_dir" ]]; then
                log_error "Failed to create temporary build directory"
                FAILED_PACKAGES+=("neovim")
                return 1
            fi

            safe_spinner_start "Neovim: building from source"
            (
                set -e
                cd "$build_dir"
                git clone https://github.com/neovim/neovim
                cd neovim
                git checkout stable
                make CMAKE_BUILD_TYPE=RelWithDebInfo
                sudo make install
            ) > >(tee -a "$LOG_FILE") 2> >(tee -a "$LOG_FILE" >&2) || exit_code=$?

            if [[ $exit_code -ne 0 ]]; then
                safe_spinner_stop "Neovim build complete" "Neovim build failed" "$exit_code"
                log_error "Neovim build/install failed"
                FAILED_PACKAGES+=("neovim")
                {
                    echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to install: neovim"
                    echo "Method: build from source (Fedora/RHEL)"
                    echo "Exit Code: $exit_code"
                    echo "Build dir: $build_dir"
                    echo "Log: $LOG_FILE"
                    echo "---"
                } >> "$ERROR_LOG_FILE"
                rm -rf "$build_dir" 2>/dev/null || true
                return 1
            fi

            spinner_stop "Neovim build complete" "Neovim build failed" 0

            rm -rf "$build_dir" 2>/dev/null || true
            log_success "Neovim installed successfully"
            SUCCESSFUL_PACKAGES+=("neovim")
            return 0
            ;;

        *)
            log_error "Unsupported OS for Neovim installation: $os"
            FAILED_PACKAGES+=("neovim")
            return 1
            ;;
    esac
}
