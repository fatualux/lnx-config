#!/bin/bash

set -uo pipefail

# Enable verbose mode if DEBUG=1
[[ "${DEBUG:-0}" == "1" ]] && set -x

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source spinner and colors
source "$PROJECT_ROOT/src/colors.sh" 2>/dev/null || {
    # Fallback color definitions
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly NC='\033[0m'
}
source "$PROJECT_ROOT/src/spinner.sh" 2>/dev/null || {
    # Fallback spinner functions
    spinner_start() { :; }
    spinner_stop() { :; }
    spinner_cleanup() { :; }
}

# Cleanup function for script exit
cleanup_on_exit() {
    tput cnorm 2>/dev/null || true
    printf "\r\033[K"
}

# File paths
APPS_FILE="${SCRIPT_DIR}/apps.txt"
LOG_FILE="${SCRIPT_DIR}/install.log"
ERROR_LOG_FILE="${SCRIPT_DIR}/install_errors.log"

# Arrays to track results
FAILED_PACKAGES=()
SUCCESSFUL_PACKAGES=()
SKIPPED_PACKAGES=()

safe_spinner_start() {
    if declare -F spinner_cleanup >/dev/null 2>&1; then
        spinner_cleanup
    fi
    spinner_start "$@"
}

safe_spinner_stop() {
    spinner_stop "$@"
}

combined_cleanup_on_exit() {
    if declare -F spinner_cleanup >/dev/null 2>&1; then
        spinner_cleanup
    fi
    cleanup_on_exit
}

trap combined_cleanup_on_exit EXIT INT TERM
