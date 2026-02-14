#!/bin/bash

log_info() {
    local msg="[INFO] $1"
    echo -e "${BLUE}${msg}${NC}" >&2
    echo "$(date '+%Y-%m-%d %H:%M:%S') ${msg}" >> "$LOG_FILE"
}

log_success() {
    local msg="[SUCCESS] $1"
    echo -e "${GREEN}${msg}${NC}" >&2
    echo "$(date '+%Y-%m-%d %H:%M:%S') ${msg}" >> "$LOG_FILE"
}

log_warning() {
    local msg="[WARNING] $1"
    echo -e "${YELLOW}${msg}${NC}" >&2
    echo "$(date '+%Y-%m-%d %H:%M:%S') ${msg}" >> "$LOG_FILE"
}

log_error() {
    local msg="[ERROR] $1"
    echo -e "${RED}${msg}${NC}" >&2
    echo "$(date '+%Y-%m-%d %H:%M:%S') ${msg}" >> "$LOG_FILE"
}

log_debug() {
    local msg="[DEBUG] $1"
    echo -e "${NC}${msg}${NC}" >&2
    echo "$(date '+%Y-%m-%d %H:%M:%S') ${msg}" >> "$LOG_FILE"
}
