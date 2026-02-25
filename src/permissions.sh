#!/bin/bash

# Permissions management module

# Function to fix script permissions in a directory
fix_script_permissions() {
    local directory="$1"
    
    if [[ ! -d "$directory" ]]; then
        log_error "Directory not found: $directory"
        return 1
    fi
    
    log_info "Fixing script permissions in: $directory"
    
    # Find and make all .sh files executable
    local scripts_found=0
    while IFS= read -r -d '' script; do
        if [[ -f "$script" && "$script" == *.sh ]]; then
            chmod +x "$script"
            ((scripts_found++))
            log_info "Made executable: $script"
        fi
    done < <(find "$directory" -name "*.sh" -type f 2>/dev/null)
    
    if [[ $scripts_found -gt 0 ]]; then
        log_success "Fixed permissions for $scripts_found script(s)"
    else
        log_info "No shell scripts found in $directory"
    fi
}

# Function to set executable permissions
set_executable() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        log_info "Setting executable permission: $file"
        if chmod +x "$file"; then
            log_success "Made executable: $file"
        else
            log_error "Failed to make executable: $file"
            return 1
        fi
    else
        log_warn "File not found: $file"
        return 1
    fi
}

# Function to set secure permissions
set_secure_permissions() {
    local file="$1"
    local permissions="${2:-600}"
    
    if [[ -f "$file" ]]; then
        log_info "Setting secure permissions ($permissions): $file"
        if chmod "$permissions" "$file"; then
            log_success "Set permissions: $file -> $permissions"
        else
            log_error "Failed to set permissions: $file"
            return 1
        fi
    else
        log_warn "File not found: $file"
        return 1
    fi
}

# Function to fix script permissions
fix_script_permissions() {
    log_section "Fixing script permissions"
    
    local scripts_fixed=0
    
    # Find and fix permissions for shell scripts
    while IFS= read -r -d '' script; do
        if [[ -x "$script" ]]; then
            log_info "Script already executable: $script"
        else
            if set_executable "$script"; then
                ((scripts_fixed++))
            fi
        fi
    done < <(find "$SCRIPT_DIR" -name "*.sh" -type f -print0 2>/dev/null)
    
    log_success "Fixed permissions for $scripts_fixed scripts"
}

# Function to verify file permissions
verify_permissions() {
    log_section "Verifying file permissions"
    
    local issues=0
    
    # Check for world-writable files in home directory (security risk)
    while IFS= read -r -d '' file; do
        if [[ -w "$file" && -O "$file" ]]; then
            log_warn "World-writable file found: $file"
            ((issues++))
        fi
    done < <(find "$HOME" -type f -perm -002 -print0 2>/dev/null)
    
    if [[ $issues -eq 0 ]]; then
        log_success "No permission issues found"
    else
        log_warn "Found $issues permission issues"
    fi
}
