#!/bin/bash
set -uo pipefail

CORE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/core" && pwd)"

source "$CORE_DIR/bootstrap.sh"
source "$CORE_DIR/logging.sh"
source "$CORE_DIR/os.sh"
source "$CORE_DIR/ui.sh"
source "$CORE_DIR/pkg.sh"
source "$CORE_DIR/rust.sh"
source "$CORE_DIR/neovim.sh"
source "$CORE_DIR/joshuto.sh"
source "$CORE_DIR/summary.sh"

# Main installation process
main() {
    {
        echo "========================================"
        echo "  Application Installer - $(date '+%Y-%m-%d %H:%M:%S')"
        echo "========================================"
        echo ""
    } > "$LOG_FILE"

    echo "========================================"
    echo "  Application Installer - $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================"
    echo ""

    log_debug "Script started from: $(pwd)"
    log_debug "Apps file path: $APPS_FILE"
    log_debug "Log file path: $LOG_FILE"
    log_debug "Error log file path: $ERROR_LOG_FILE"
    log_debug "User: $(whoami)"
    log_debug "UID: $(id -u)"

    local os
    os=$(detect_os)
    log_info "Detected OS: $os"

    if [[ "$os" == "unknown" ]]; then
        log_error "Unable to detect OS. Supported: Debian/Ubuntu, Arch/Manjaro, Fedora/RHEL"
        exit 1
    fi

    check_apps_file

    > "$ERROR_LOG_FILE"
    log_debug "Cleared error log file"

    if ! prompt_install_mode; then
        log_warning "Skipping all custom application installations"
        echo ""
        echo "========================================"
        echo "  Installation Skipped"
        echo "========================================"
        exit 0
    fi

    : "${INSTALL_MODE:=all}"

    update_package_cache "$os"

    echo ""
    log_info "Reading applications from: $APPS_FILE"
    log_info "Starting package installation..."
    echo ""

    local line_num=0
    while IFS= read -r package || [ -n "$package" ]; do
        ((line_num++))

        if [[ -z "$package" || "$package" =~ ^[[:space:]]*# ]]; then
            continue
        fi

        package=$(echo "$package" | xargs)
        if [[ -z "$package" ]]; then
            continue
        fi

        if [[ "$INSTALL_MODE" == "prompt" ]]; then
            prompt_install_package "$package"
            case $? in
                0)
                    :
                    ;;
                1)
                    SKIPPED_PACKAGES+=("$package")
                    echo "$(date '+%Y-%m-%d %H:%M:%S') [SKIPPED] $package - User skipped" >> "$LOG_FILE"
                    continue
                    ;;
                2)
                    log_warning "User requested quit during package prompts"
                    break
                    ;;
            esac
        fi

        if [[ "$package" == "neovim" ]]; then
            install_neovim "$os" || true
        elif [[ "$package" == "rustc" ]]; then
            ensure_rust_toolchain "1.90" "$os" || true
        elif [[ "$package" == "joshuto" ]]; then
            install_joshuto "$os" || true
        else
            install_package "$package" "$os" || true
        fi
    done < "$APPS_FILE"

    print_summary
}

# Run main function
main "$@"
