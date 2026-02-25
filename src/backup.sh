#!/bin/bash

# Backup management module

# Configuration
BACKUP_DIR="$SCRIPT_DIR/backups/$(date '+%y-%m-%d_%H-%M-%S')"
MAX_BACKUPS=5  # Keep only 5 most recent backups
BACKUP_FILES=("$HOME/.config" "$HOME/.bashrc" "$HOME/.vimrc")

# Function to clean old backups
clean_old_backups() {
    local backups_dir="$SCRIPT_DIR/backups"
    
    if [[ ! -d "$backups_dir" ]]; then
        return 0
    fi
    
    log_info "Cleaning old backups (keeping latest $MAX_BACKUPS)"
    
    # Use subshell to avoid changing working directory
    local backup_count removed_count
    backup_count=$(find "$backups_dir" -maxdepth 1 -type d -name "??-??-??_??-??-??" 2>/dev/null | wc -l)
    
    if [[ "$backup_count" -gt "$MAX_BACKUPS" ]]; then
        # Find and remove old backups using absolute paths
        removed_count=$(find "$backups_dir" -maxdepth 1 -type d -name "??-??-??_??-??-??" -printf "%T@ %p\n" 2>/dev/null | sort -n | head -n -$MAX_BACKUPS | cut -d' ' -f2- | xargs -r rm -rf | wc -l)
        log_success "Removed $removed_count old backup(s)"
    else
        log_info "No cleanup needed (have $backup_count backups, limit is $MAX_BACKUPS)"
    fi
}

# Function to create backup directory
create_backup_dir() {
    log_info "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    log_success "Backup directory created: $BACKUP_DIR"
}

# Function to backup existing files
backup_files() {
    log_section "Backing up existing configuration files"
    
    local backed_up=false
    
    for file in "${BACKUP_FILES[@]}"; do
        if [[ -e "$file" ]]; then
            local basename_file
            basename_file=$(basename "$file")
            local backup_path="$BACKUP_DIR/$basename_file"
            
            log_info "Backing up: $file -> $backup_path"
            
            if cp -r "$file" "$backup_path"; then
                log_success "Backed up: $file"
                backed_up=true
            else
                log_error "Failed to backup: $file"
                return 1
            fi
        else
            log_info "File does not exist, skipping: $file"
        fi
    done
    
    if $backed_up; then
        log_success "All files backed up successfully"
    else
        log_info "No files to backup"
    fi
}

# Function to remove existing config files
remove_existing_configs() {
    log_section "Removing existing configuration files"
    
    for file in "${BACKUP_FILES[@]}"; do
        if [[ -e "$file" ]]; then
            log_info "Removing: $file"
            if rm -rf "$file"; then
                log_success "Removed: $file"
            else
                log_error "Failed to remove: $file"
                return 1
            fi
        else
            log_info "File does not exist, skipping: $file"
        fi
    done
    
    log_success "Existing configuration files removed"
}
