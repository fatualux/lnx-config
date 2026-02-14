#!/bin/bash

install_joshuto() {
    local os="$1"

    ensure_rust_toolchain "1.90" "$os" || {
        FAILED_PACKAGES+=("joshuto")
        return 1
    }

    case "$os" in
        fedora|rhel|centos)
            log_info "Installing joshuto via COPR (Fedora/RHEL)"

            safe_spinner_start "Enabling COPR: atim/joshuto"
            if ! sudo dnf copr enable atim/joshuto -y >>"$LOG_FILE" 2>>"$LOG_FILE"; then
                safe_spinner_stop "COPR enabled" "COPR enable failed" 1
                log_error "Failed to enable COPR atim/joshuto"
                FAILED_PACKAGES+=("joshuto")
                return 1
            fi
            safe_spinner_stop "COPR enabled" "COPR enable failed" 0

            install_package "joshuto" "$os"
            return $?
            ;;

        arch|manjaro)
            log_info "Installing joshuto via pacman"
            install_package "joshuto" "$os"
            return $?
            ;;

        debian|ubuntu)
            log_info "Installing joshuto via cargo (Debian/Ubuntu)"

            install_package "pkg-config" "$os" || true
            install_package "libssl-dev" "$os" || true

            local cargo_env="$HOME/.cargo/env"
            if [[ -f "$cargo_env" ]]; then
                # shellcheck source=/dev/null
                source "$cargo_env"
            fi

            safe_spinner_start "Installing joshuto (cargo)"
            if cargo install --git https://github.com/kamiyaa/joshuto.git --force >>"$LOG_FILE" 2>>"$LOG_FILE"; then
                safe_spinner_stop "Installed joshuto" "Failed joshuto" 0
                log_success "joshuto installed successfully"
                SUCCESSFUL_PACKAGES+=("joshuto")
                return 0
            fi

            safe_spinner_stop "Installed joshuto" "Failed joshuto" 1
            log_error "Failed to install joshuto via cargo"
            FAILED_PACKAGES+=("joshuto")
            {
                echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to install: joshuto"
                echo "Method: cargo install --git https://github.com/kamiyaa/joshuto.git --force"
                echo "---"
            } >> "$ERROR_LOG_FILE"
            return 1
            ;;

        *)
            log_error "Unsupported OS for joshuto installation: $os"
            FAILED_PACKAGES+=("joshuto")
            return 1
            ;;
    esac
}
