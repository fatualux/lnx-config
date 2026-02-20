#!/bin/bash

# Guard against re-sourcing to prevent readonly variable conflicts
[[ -n "${__LOGGER_SOURCED:-}" ]] && return 0

# Logger module - centralized logging system for bash configuration
# Usage: source this file after sourcing colors.sh

# Source colors if not already loaded - with multiple fallback paths
if [ -z "$COLOR_GREEN" ]; then
    _source_colors() {
        local color_paths=(
            "${BASH_SOURCE%/*}/colors.sh"
            "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
            "$HOME/.config/bash/colors.sh"
            "$HOME/.bashrc.d/colors.sh"
            "/etc/bash/colors.sh"
            "./colors.sh"
        )

        for path in "${color_paths[@]}"; do
            if [ -f "$path" ]; then
                source "$path"
                return 0
            fi
        done

        # If colors not found, define minimal fallback colors
        readonly COLOR_BLACK='\033[0;30m'
        readonly COLOR_RED='\033[0;31m'
        readonly COLOR_GREEN='\033[0;32m'
        readonly COLOR_YELLOW='\033[0;33m'
        readonly COLOR_BLUE='\033[0;34m'
        readonly COLOR_MAGENTA='\033[0;35m'
        readonly COLOR_CYAN='\033[0;36m'
        readonly COLOR_WHITE='\033[0;37m'
        readonly COLOR_BOLD_RED='\033[1;31m'
        readonly COLOR_BOLD_GREEN='\033[1;32m'
        readonly COLOR_BOLD_CYAN='\033[1;36m'
        readonly COLOR_BOLD_YELLOW='\033[1;33m'
        readonly COLOR_DIM='\033[2m'
        readonly NC='\033[0m'
        readonly COLOR_BG_BLACK='\033[40m'
        readonly CHAR_CHECKMARK='[OK] '
        readonly CHAR_CROSS='[X]'
        readonly CHAR_WARNING='[!]'
        readonly CHAR_INFO='[i] '
        readonly CHAR_ARROW='[->] '
        readonly CHAR_BULLET='[- ] '
        readonly CHAR_STAR='[* ]'
        return 1
    }
    _source_colors
fi

# Log level configuration
# Set LOG_LEVEL environment variable to control verbosity
# 0 = DEBUG, 1 = INFO, 2 = SUCCESS, 3 = WARNING, 4 = ERROR, 5 = CRITICAL
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_SUCCESS=2
readonly LOG_LEVEL_WARNING=3
readonly LOG_LEVEL_ERROR=4
readonly LOG_LEVEL_CRITICAL=5

# Default log level (INFO)
: "${LOG_LEVEL:=1}"

# Normalize LOG_LEVEL if it's not a number (e.g., from .env files)
if ! [[ "$LOG_LEVEL" =~ ^[0-9]+$ ]]; then
    # Try to convert string level names to numbers
    case "${LOG_LEVEL^^}" in
        DEBUG) LOG_LEVEL=0 ;;
        INFO) LOG_LEVEL=1 ;;
        SUCCESS) LOG_LEVEL=2 ;;
        WARNING|WARN) LOG_LEVEL=3 ;;
        ERROR) LOG_LEVEL=4 ;;
        CRITICAL|CRIT) LOG_LEVEL=5 ;;
        *) LOG_LEVEL=1 ;;  # Default to INFO for unknown values
    esac
fi

# Enable/disable logging to file
: "${LOG_TO_FILE:=false}"
: "${LOG_FILE:=$HOME/.bash_config.log}"

# Enable/disable timestamps
: "${LOG_TIMESTAMP:=false}"

# Internal function to get timestamp
_log_timestamp() {
    if [ "$LOG_TIMESTAMP" = true ]; then
        date '+[%Y-%m-%d %H:%M:%S]'
    fi
}

# Internal function to write to log file
_write_to_file() {
    local level="$1"
    local message="$2"

    if [ "$LOG_TO_FILE" = true ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" >>"$LOG_FILE"
    fi
}

# Internal function to check if message should be logged
_should_log() {
    local level=$1
    [ "$level" -ge "$LOG_LEVEL" ]
}

# Debug log - detailed information for debugging
log_debug() {
    if _should_log $LOG_LEVEL_DEBUG; then
        local timestamp=$(_log_timestamp)
        echo -e "${COLOR_DIM}${timestamp} ${CHAR_BULLET} DEBUG: $*${NC}" >&2
        _write_to_file "DEBUG" "$*"
    fi
}

# Info log - general informational messages
log_info() {
    if _should_log $LOG_LEVEL_INFO; then
        local timestamp=$(_log_timestamp)
        echo -e "${COLOR_CYAN}${timestamp} ${CHAR_INFO} $*${NC}"
        _write_to_file "INFO" "$*"
    fi
}

# Success log - successful operations
log_success() {
    if _should_log $LOG_LEVEL_SUCCESS; then
        local timestamp=$(_log_timestamp)
        echo -e "${COLOR_GREEN}${timestamp} ${CHAR_CHECKMARK} $*${NC}"
        _write_to_file "SUCCESS" "$*"
    fi
}

# Warning log - warning messages
log_warn() {
    if _should_log $LOG_LEVEL_WARNING; then
        local timestamp=$(_log_timestamp)
        echo -e "${COLOR_YELLOW}${timestamp} ${CHAR_WARNING} $*${NC}"
        _write_to_file "WARNING" "$*"
    fi
}

# Error log - error messages
log_error() {
    if _should_log $LOG_LEVEL_ERROR; then
        local timestamp=$(_log_timestamp)
        echo -e "${COLOR_RED}${timestamp} ${CHAR_CROSS} $*${NC}" >&2
        _write_to_file "ERROR" "$*"
    fi
}

# Critical log - critical error messages
log_critical() {
    if _should_log $LOG_LEVEL_CRITICAL; then
        local timestamp=$(_log_timestamp)
        echo -e "${COLOR_BOLD_RED}${COLOR_BG_BLACK}${timestamp} ${CHAR_CROSS} CRITICAL: $*${NC}" >&2
        _write_to_file "CRITICAL" "$*"
    fi
}

# Progress log - for progress indicators (no newline)
log_progress() {
    local timestamp=$(_log_timestamp)
    printf "\r${COLOR_BLUE}${timestamp} ${CHAR_ARROW} %s${NC}" "$*"
}

# Clear progress line
log_clear_line() {
    printf "\r\033[K"
}

# Command execution logger
log_cmd() {
    local cmd="$*"
    log_debug "Executing: $cmd"
    _write_to_file "COMMAND" "$cmd"
}

# Function execution logger
log_func_start() {
    log_debug "Function started: $1"
}

log_func_end() {
    log_debug "Function ended: $1"
}

# Section headers for better organization
log_section() {
    if _should_log $LOG_LEVEL_INFO; then
        local timestamp=$(_log_timestamp)
        echo -e "\n${COLOR_BOLD_CYAN}${timestamp} === $* ===${NC}"
        _write_to_file "SECTION" "$*"
    fi
}

# File operation loggers
log_file_found() {
    log_success "File found: $1"
}

log_file_not_found() {
    log_warn "File not found: $1"
}

log_file_created() {
    log_success "File created: $1"
}

log_file_deleted() {
    log_success "File deleted: $1"
}

log_dir_created() {
    log_success "Directory created: $1"
}

log_dir_not_found() {
    log_warn "Directory not found: $1"
}

# Process loggers
log_process_start() {
    log_info "Starting: $*"
}

log_process_complete() {
    log_success "Completed: $*"
}

log_process_failed() {
    log_error "Failed: $*"
}

# Docker-specific loggers
log_docker_running() {
    log_success "Docker is running"
}

log_docker_not_running() {
    log_warn "Docker is not running"
}

log_docker_starting() {
    log_info "Starting Docker..."
}

log_docker_started() {
    log_success "Docker started successfully"
}

log_docker_failed() {
    log_error "Docker failed to start"
}

# Environment loggers
log_env_activated() {
    log_success "Virtual environment activated: $1"
}

log_env_not_found() {
    log_info "No virtual environment found"
}

# Git loggers
log_git_status() {
    log_info "Git status: $*"
}

log_git_branch() {
    log_info "Current branch: $1"
}

# Utility function for yes/no prompts
log_prompt() {
    local prompt="$1"
    local default="${2:-N}"

    if [ "$default" = "Y" ] || [ "$default" = "y" ]; then
        echo -e -n "${COLOR_YELLOW}${CHAR_ARROW} ${prompt} [Y/n]: ${NC}"
    else
        echo -e -n "${COLOR_YELLOW}${CHAR_ARROW} ${prompt} [y/N]: ${NC}"
    fi
}

# Print a separator line
log_separator() {
    echo -e "${COLOR_DIM}$(printf '%0.s-' {1..80})${NC}"
}

# Print current log level
log_show_level() {
    case $LOG_LEVEL in
    0) echo "Current log level: DEBUG" ;;
    1) echo "Current log level: INFO" ;;
    2) echo "Current log level: SUCCESS" ;;
    3) echo "Current log level: WARNING" ;;
    4) echo "Current log level: ERROR" ;;
    5) echo "Current log level: CRITICAL" ;;
    *) echo "Current log level: UNKNOWN ($LOG_LEVEL)" ;;
    esac
}

# Mark logger as sourced to prevent re-sourcing
readonly __LOGGER_SOURCED=1
