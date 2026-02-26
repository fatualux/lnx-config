#!/bin/bash

# User prompts module

# Function to prompt for confirmation
prompt_confirm() {
    local message="$1"
    local default="${2:-n}"
    
    if [[ "$auto_yes" == "true" ]]; then
        return 0
    fi
    
    while true; do
        read -p "$message [y/N]: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            "" ) 
                if [[ "$default" == "y" ]]; then
                    return 0
                else
                    return 1
                fi
                ;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function to prompt for input
prompt_input() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    if [[ -n "$default" ]]; then
        read -p "$prompt [$default]: " input
        if [[ -z "$input" ]]; then
            input="$default"
        fi
    else
        read -p "$prompt: " input
    fi
    
    if [[ -n "$var_name" ]]; then
        printf -v "$var_name" '%s' "$input"
    fi
    
    echo "$input"
}

# Function to prompt for password (hidden input)
prompt_password() {
    local prompt="$1"
    local var_name="$2"
    
    read -s -p "$prompt: " input
    echo
    
    if [[ -n "$var_name" ]]; then
        printf -v "$var_name" '%s' "$input"
    fi
    
    echo "$input"
}
