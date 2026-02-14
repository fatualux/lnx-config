#!/bin/bash

read_tty() {
    local __var_name="$1"
    local __prompt="$2"
    local __response=""

    echo -ne "$__prompt"

    if [[ -r /dev/tty ]]; then
        IFS= read -r __response </dev/tty
    else
        IFS= read -r __response
    fi

    printf -v "$__var_name" '%s' "$__response"
}

check_apps_file() {
    if [ ! -f "$APPS_FILE" ]; then
        log_error "apps.txt not found at: $APPS_FILE"
        log_error "Current directory: $(pwd)"
        log_error "Script directory: ${SCRIPT_DIR:-unknown}"
        exit 1
    fi

    log_debug "apps.txt found and readable"
}

prompt_install_mode() {
    echo ""
    echo "========================================"
    echo "  Custom Application Installation"
    echo "========================================"
    echo ""
    local response
    read_tty response "${BLUE}Install custom applications? [Y/y/N]: ${NC}"

    case "$response" in
        N)
            INSTALL_MODE="skip"
            log_info "Skipping all custom applications"
            return 1
            ;;
        y)
            INSTALL_MODE="prompt"
            log_info "Prompting for each application"
            return 0
            ;;
        Y|"")
            INSTALL_MODE="all"
            log_info "Installing all applications automatically"
            return 0
            ;;
        *)
            INSTALL_MODE="all"
            log_info "Installing all applications automatically"
            return 0
            ;;
    esac
}

prompt_install_package() {
    local package="$1"
    local response

    read_tty response "${BLUE}Install ${YELLOW}${package}${BLUE}? [Y/n/q]: ${NC}"

    case "$response" in
        q|Q)
            return 2
            ;;
        n|N)
            return 1
            ;;
        Y|y|"")
            return 0
            ;;
        *)
            return 0
            ;;
    esac
}
