#!/bin/bash

print_summary() {
    if declare -F spinner_cleanup >/dev/null 2>&1; then
        spinner_cleanup
    fi

    echo ""
    echo "========================================"
    echo "  Installation Summary"
    echo "========================================"
    echo ""

    {
        echo ""
        echo "========================================"
        echo "  Installation Summary"
        echo "========================================"
        echo ""
    } >> "$LOG_FILE"

    log_success "Successfully installed: ${#SUCCESSFUL_PACKAGES[@]} packages"
    {
        echo "$(date '+%Y-%m-%d %H:%M:%S') [SUMMARY] Successfully installed: ${#SUCCESSFUL_PACKAGES[@]} packages"
        if [ ${#SUCCESSFUL_PACKAGES[@]} -gt 0 ]; then
            for pkg in "${SUCCESSFUL_PACKAGES[@]}"; do
                echo "  ✓ $pkg"
            done
        fi
    } >> "$LOG_FILE"

    if [ ${#SUCCESSFUL_PACKAGES[@]} -gt 0 ]; then
        for pkg in "${SUCCESSFUL_PACKAGES[@]}"; do
            echo "  ✓ $pkg"
        done
    fi

    echo ""

    if [ ${#SKIPPED_PACKAGES[@]} -gt 0 ]; then
        echo -e "${YELLOW}Skipped: ${#SKIPPED_PACKAGES[@]} packages${NC}"
        {
            echo "$(date '+%Y-%m-%d %H:%M:%S') [SUMMARY] Skipped: ${#SKIPPED_PACKAGES[@]} packages"
        } >> "$LOG_FILE"
        for pkg in "${SKIPPED_PACKAGES[@]}"; do
            echo "  ○ $pkg"
            echo "  ○ $pkg" >> "$LOG_FILE"
        done
        echo ""
    fi

    if [ ${#FAILED_PACKAGES[@]} -gt 0 ]; then
        log_error "Failed to install: ${#FAILED_PACKAGES[@]} packages"
        {
            echo "$(date '+%Y-%m-%d %H:%M:%S') [SUMMARY] Failed to install: ${#FAILED_PACKAGES[@]} packages"
        } >> "$LOG_FILE"
        for pkg in "${FAILED_PACKAGES[@]}"; do
            echo "  ✗ $pkg"
            echo "  ✗ $pkg" >> "$LOG_FILE"
        done
        echo ""
        log_warning "Error details saved to: $ERROR_LOG_FILE"
        if [ -f "$ERROR_LOG_FILE" ] && [ -s "$ERROR_LOG_FILE" ]; then
            echo ""
            echo "Error details:" >&2
            cat "$ERROR_LOG_FILE" >&2
        fi
    else
        if [ ${#SUCCESSFUL_PACKAGES[@]} -gt 0 ]; then
            log_success "All attempted packages installed successfully!"
            echo "$(date '+%Y-%m-%d %H:%M:%S') [SUMMARY] All attempted packages installed successfully!" >> "$LOG_FILE"
        fi
        [ -f "$ERROR_LOG_FILE" ] && [ ! -s "$ERROR_LOG_FILE" ] && rm -f "$ERROR_LOG_FILE"
    fi

    echo ""
    echo "========================================"
    log_info "Complete log saved to: $LOG_FILE"
    echo "========================================"

    {
        echo ""
        echo "========================================"
        echo "$(date '+%Y-%m-%d %H:%M:%S') Installation completed"
        echo "========================================"
    } >> "$LOG_FILE"
}
