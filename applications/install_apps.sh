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
        log_warning "Unable to detect OS. Will try available package managers..."
        local managers=($(detect_package_managers))
        if [[ ${#managers[@]} -eq 0 ]]; then
            log_error "No supported package managers found. Please install one of: apt, dnf, yum, pacman, pkg, apk, zypper"
            exit 1
        fi
        log_info "Found package managers: ${managers[*]}"
        
        # Use fallback mode for unknown OS
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

        # Update cache for each available package manager
        for manager in "${managers[@]}"; do
            local fallback_os=$(map_pm_to_os "$manager")
            log_info "Updating $manager package cache..."
            update_package_cache "$fallback_os" || true
        done

        echo ""
        log_info "Reading applications from: $APPS_FILE"
        log_info "Starting package installation with fallback..."
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
                # Try neovim installation with fallback
                local neovim_success=false
                for manager in "${managers[@]}"; do
                    local fallback_os=$(map_pm_to_os "$manager")
                    if install_neovim "$fallback_os"; then
                        log_success "Successfully installed neovim using $manager"
                        neovim_success=true
                        break
                    else
                        log_warning "Failed to install neovim with $manager"
                    fi
                done
                if ! $neovim_success; then
                    log_error "Failed to install neovim with all available package managers"
                fi
            elif [[ "$package" == "rustc" ]]; then
                # Try rust installation with fallback
                local rust_success=false
                for manager in "${managers[@]}"; do
                    local fallback_os=$(map_pm_to_os "$manager")
                    if ensure_rust_toolchain "1.90" "$fallback_os"; then
                        log_success "Successfully installed rust toolchain using $manager"
                        rust_success=true
                        break
                    else
                        log_warning "Failed to install rust toolchain with $manager"
                    fi
                done
                if ! $rust_success; then
                    log_error "Failed to install rust toolchain with all available package managers"
                fi
            elif [[ "$package" == "joshuto" ]]; then
                # Try joshuto installation with fallback
                local joshuto_success=false
                for manager in "${managers[@]}"; do
                    local fallback_os=$(map_pm_to_os "$manager")
                    if install_joshuto "$fallback_os"; then
                        log_success "Successfully installed joshuto using $manager"
                        joshuto_success=true
                        break
                    else
                        log_warning "Failed to install joshuto with $manager"
                    fi
                done
                if ! $joshuto_success; then
                    log_error "Failed to install joshuto with all available package managers"
                fi
            else
                # Use fallback installation for regular packages
                try_install_with_fallback "$package" || true
            fi
        done < "$APPS_FILE"

        print_summary
        exit 0
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
