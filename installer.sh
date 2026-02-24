#!/bin/bash

# Linux Configuration Auto-Installer
# Backups existing configs, removes old ones, and sets up new configuration

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source required modules
source "$SCRIPT_DIR/src/colors.sh"
source "$SCRIPT_DIR/src/logger.sh"

# Configuration
BACKUP_DIR="$SCRIPT_DIR/backups/$(date '+%y-%m-%d_%H-%M-%S')"
CONFIG_SOURCE_DIR="$SCRIPT_DIR/configs"
CUSTOM_CONFIG_DIR="$CONFIG_SOURCE_DIR/custom"
CORE_BASH_DIR="$CONFIG_SOURCE_DIR/core/bash"
CORE_VIM_DIR="$CONFIG_SOURCE_DIR/core/vim"
SRC_DIR="$SCRIPT_DIR/src"

# Files to backup
BACKUP_FILES=("$HOME/.config" "$HOME/.bashrc" "$HOME/.vimrc")

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

# Function to copy custom configs to ~/.config
copy_custom_configs() {
    log_section "Copying custom configurations to ~/.config"
    
    if [[ ! -d "$CUSTOM_CONFIG_DIR" ]]; then
        log_warn "Custom config directory not found: $CUSTOM_CONFIG_DIR"
        return 0
    fi
    
    # Create ~/.config directory
    mkdir -p "$HOME/.config"
    
    # Copy all contents from custom configs
    if cp -r "$CUSTOM_CONFIG_DIR"/* "$HOME/.config/"; then
        log_success "Custom configs copied to ~/.config"
    else
        log_error "Failed to copy custom configs"
        return 1
    fi
}

# Function to create .vimrc
create_vimrc() {
    log_section "Creating .vimrc"
    
    local vimrc_file="$HOME/.vimrc"
    
    # Start with empty .vimrc
    > "$vimrc_file"
    
    # Append content from core/vim/config if exists
    if [[ -d "$CORE_VIM_DIR/config" ]]; then
        log_info "Appending vim configuration from: $CORE_VIM_DIR/config"
        
        # Find all .vim files in config directory and append them
        local vim_files=("$CORE_VIM_DIR/config"/*.vim)
        for vim_file in "${vim_files[@]}"; do
            if [[ -f "$vim_file" ]]; then
                log_info "Appending: $(basename "$vim_file")"
                cat "$vim_file" >> "$vimrc_file"
                echo "" >> "$vimrc_file"  # Add newline between files
            fi
        done
        
        log_success ".vimrc created with core vim configuration"
    else
        log_warn "Core vim config directory not found: $CORE_VIM_DIR/config"
        log_info "Created empty .vimrc"
    fi
}

# Function to create .bashrc
create_bashrc() {
    log_section "Creating .bashrc"
    
    local bashrc_file="$HOME/.bashrc"
    
    # Start with empty .bashrc
    > "$bashrc_file"
    
    # Add script directory variable first
    echo "# Script directory for theme loading" >> "$bashrc_file"
    echo "SCRIPT_DIR=\"$SCRIPT_DIR\"" >> "$bashrc_file"
    echo "" >> "$bashrc_file"
    
    # Append colors.sh and logger.sh first
    if [[ -f "$SCRIPT_DIR/src/colors.sh" ]]; then
        log_info "Appending: src/colors.sh"
        echo "# Source: src/colors.sh" >> "$bashrc_file"
        cat "$SCRIPT_DIR/src/colors.sh" >> "$bashrc_file"
        echo "" >> "$bashrc_file"
    fi
    
    if [[ -f "$SCRIPT_DIR/src/logger.sh" ]]; then
        log_info "Appending: src/logger.sh"
        echo "# Source: src/logger.sh" >> "$bashrc_file"
        cat "$SCRIPT_DIR/src/logger.sh" >> "$bashrc_file"
        echo "" >> "$bashrc_file"
    fi
    
    # Append all .sh files from src directory (except colors.sh and logger.sh)
    if [[ -d "$SRC_DIR" ]]; then
        log_info "Appending source files from: $SRC_DIR"
        
        find "$SRC_DIR" -name "*.sh" -type f | sort | while read -r sh_file; do
            local basename_file
            basename_file=$(basename "$sh_file")
            # Skip logger.sh and colors.sh as they're already handled
            if [[ "$basename_file" != "logger.sh" && "$basename_file" != "colors.sh" ]]; then
                local relative_path="${sh_file#$SCRIPT_DIR/}"
                log_info "Appending: $relative_path"
                echo "# Source: $relative_path" >> "$bashrc_file"
                cat "$sh_file" >> "$bashrc_file"
                echo "" >> "$bashrc_file"
            fi
        done
        
        log_success "Source files appended to .bashrc"
    else
        log_warn "Source directory not found: $SRC_DIR"
    fi
    
    # Recursive function to append all .sh files in a directory
    recursive_append_bash_files() {
        local dir="$1"
        
        if [[ ! -d "$dir" ]]; then
            return 0
        fi
        
        # Find all .sh files and sort them
        find "$dir" -name "*.sh" -type f | sort | while read -r sh_file; do
            local relative_path="${sh_file#$SCRIPT_DIR/}"
            
            log_info "Appending: $relative_path"
            echo "# Source: $relative_path" >> "$bashrc_file"
            cat "$sh_file" >> "$bashrc_file"
            echo "" >> "$bashrc_file"
        done
    }
    
    # Append all .sh files from core/bash and subdirectories
    if [[ -d "$CORE_BASH_DIR" ]]; then
        log_info "Appending bash configuration from: $CORE_BASH_DIR"
        
        # Append all .sh files recursively, but put config/theme.sh last
        local temp_file=$(mktemp)
        
        # Get all files except config/theme.sh
        find "$CORE_BASH_DIR" -name "*.sh" -type f | grep -v "config/theme.sh" | sort > "$temp_file"
        
        # Append other files first
        while read -r sh_file; do
            local relative_path="${sh_file#$SCRIPT_DIR/}"
            log_info "Appending: $relative_path"
            echo "# Source: $relative_path" >> "$bashrc_file"
            cat "$sh_file" >> "$bashrc_file"
            echo "" >> "$bashrc_file"
        done < "$temp_file"
        
        # Append theme config last
        if [[ -f "$CORE_BASH_DIR/config/theme.sh" ]]; then
            local theme_path="$CORE_BASH_DIR/config/theme.sh"
            local theme_relative="${theme_path#$SCRIPT_DIR/}"
            log_info "Appending: $theme_relative (last)"
            echo "# Source: $theme_relative (theme configuration)" >> "$bashrc_file"
            cat "$theme_path" >> "$bashrc_file"
            echo "" >> "$bashrc_file"
        fi
        
        rm -f "$temp_file"
        log_success "Core bash configuration appended to .bashrc"
    else
        log_warn "Core bash directory not found: $CORE_BASH_DIR"
    fi
}

# Function to display summary
display_summary() {
    log_section "Installation Summary"
    echo -e "${COLOR_GREEN}✓ Backup created: $BACKUP_DIR${NC}"
    echo -e "${COLOR_GREEN}✓ Custom configs copied to ~/.config${NC}"
    echo -e "${COLOR_GREEN}✓ .vimrc created${NC}"
    echo -e "${COLOR_GREEN}✓ .bashrc created${NC}"
    echo ""
    echo -e "${COLOR_CYAN}To apply changes, run: source ~/.bashrc${NC}"
    echo -e "${COLOR_CYAN}Or restart your terminal session${NC}"
}

# Main installation function
main() {
    log_section "Linux Configuration Auto-Installer"
    
    # Check if running as root (warn but allow)
    if [[ $EUID -eq 0 ]]; then
        log_warn "Running as root. This will modify files in /root instead of a user's home directory."
    fi
    
    # Execute installation steps
    create_backup_dir
    backup_files
    remove_existing_configs
    copy_custom_configs
    create_vimrc
    create_bashrc
    display_summary
    
    log_success "Installation completed successfully!"
}

# Handle script interruption
trap 'log_error "Installation interrupted"; exit 1' INT TERM

# Run main function
main "$@"