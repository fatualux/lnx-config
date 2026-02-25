#!/bin/bash

# Permissions management module

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
