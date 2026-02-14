#!/bin/bash

version_ge() {
    local a="$1" b="$2"

    local a_maj a_min b_maj b_min
    a_maj=${a%%.*}
    a_min=${a#*.}
    a_min=${a_min%%.*}
    b_maj=${b%%.*}
    b_min=${b#*.}
    b_min=${b_min%%.*}

    if [[ "$a_maj" -gt "$b_maj" ]]; then
        return 0
    fi
    if [[ "$a_maj" -lt "$b_maj" ]]; then
        return 1
    fi
    [[ "$a_min" -ge "$b_min" ]]
}

get_rust_version() {
    if ! command -v rustc >/dev/null 2>&1; then
        echo ""
        return 0
    fi

    rustc --version 2>/dev/null | awk '{print $2}'
}

get_cargo_version() {
    if ! command -v cargo >/dev/null 2>&1; then
        echo ""
        return 0
    fi

    cargo --version 2>/dev/null | awk '{print $2}'
}

ensure_rust_toolchain() {
    local required_version="${1:-1.90}"
    local os="$2"

    local rust_ver cargo_ver
    rust_ver=$(get_rust_version)
    cargo_ver=$(get_cargo_version)

    if [[ -n "$rust_ver" && -n "$cargo_ver" ]] && version_ge "$rust_ver" "$required_version" && version_ge "$cargo_ver" "$required_version"; then
        log_success "Rust toolchain OK (rustc $rust_ver, cargo $cargo_ver)"
        return 0
    fi

    log_warning "Rust toolchain insufficient or missing (need rustc/cargo >= $required_version). Installing via rustup."

    if ! command -v curl >/dev/null 2>&1; then
        install_package "curl" "$os" || return 1
    fi

    safe_spinner_start "Installing rustup"
    if ! curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y >>"$LOG_FILE" 2>>"$LOG_FILE"; then
        safe_spinner_stop "rustup installed" "rustup install failed" 1
        log_error "Failed to install rustup"
        FAILED_PACKAGES+=("rustup")
        {
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to install: rustup"
            echo "Method: rustup (curl https://sh.rustup.rs)"
            echo "---"
        } >> "$ERROR_LOG_FILE"
        return 1
    fi
    safe_spinner_stop "rustup installed" "rustup install failed" 0

    local rustup_env="$HOME/.cargo/env"
    if [[ -f "$rustup_env" ]]; then
        # shellcheck source=/dev/null
        source "$rustup_env"
    fi

    safe_spinner_start "Updating Rust toolchain"
    if ! rustup update stable >>"$LOG_FILE" 2>>"$LOG_FILE"; then
        safe_spinner_stop "Rust updated" "Rust update failed" 1
        log_error "rustup update failed"
        FAILED_PACKAGES+=("rustc")
        return 1
    fi
    safe_spinner_stop "Rust updated" "Rust update failed" 0

    rust_ver=$(get_rust_version)
    cargo_ver=$(get_cargo_version)

    if [[ -n "$rust_ver" && -n "$cargo_ver" ]] && version_ge "$rust_ver" "$required_version" && version_ge "$cargo_ver" "$required_version"; then
        log_success "Rust toolchain installed/updated (rustc $rust_ver, cargo $cargo_ver)"
        SUCCESSFUL_PACKAGES+=("rustc")
        return 0
    fi

    log_error "Rust toolchain still below required version after rustup (rustc $rust_ver, cargo $cargo_ver)"
    FAILED_PACKAGES+=("rustc")
    return 1
}
