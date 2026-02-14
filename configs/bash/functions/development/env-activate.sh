#!/bin/bash

# Source .env files when entering a directory
# Searches for .env* files and sources them

source_env_files() {
    local env_file
    
    # Check for .env files in order of precedence
    if [ -f ".env.local" ]; then
        env_file=".env.local"
    elif [ -f ".env" ]; then
        env_file=".env"
    else
        # Check for any .env* files
        env_file=$(find . -maxdepth 1 -name ".env*" -type f 2>/dev/null | head -1)
    fi
    
    if [ -n "$env_file" ] && [ -f "$env_file" ]; then
        # shellcheck source=/dev/null
        source "$env_file"
    fi
}
