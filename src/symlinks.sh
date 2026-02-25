#!/bin/bash

# Symlinks management module

# Function to create symbolic link
create_symlink() {
    local source="$1"
    local target="$2"
    
    if [[ -L "$target" ]]; then
        log_info "Removing existing symlink: $target"
        rm "$target"
    elif [[ -e "$target" ]]; then
        log_warn "Target exists and is not a symlink: $target"
        return 1
    fi
    
    log_info "Creating symlink: $target -> $source"
    if ln -s "$source" "$target"; then
        log_success "Created symlink: $target"
    else
        log_error "Failed to create symlink: $target"
        return 1
    fi
}

# Function to create symlinks from configuration
create_config_symlinks() {
    log_section "Creating configuration symlinks"
    
    # Example symlinks - customize as needed
    # create_symlink "$HOME/.config/some-app/config" "$HOME/.some-app-config"
    
    log_info "No symlinks configured"
}

# Function to verify symlinks
verify_symlinks() {
    log_section "Verifying symlinks"
    
    local broken_links=()
    
    # Find broken symlinks in home directory
    while IFS= read -r -d '' link; do
        if [[ ! -e "$link" ]]; then
            broken_links+=("$link")
        fi
    done < <(find "$HOME" -type l -print0 2>/dev/null)
    
    if [[ ${#broken_links[@]} -gt 0 ]]; then
        log_warn "Found ${#broken_links[@]} broken symlinks:"
        for link in "${broken_links[@]}"; do
            echo "  $link"
        done
    else
        log_success "No broken symlinks found"
    fi
}
