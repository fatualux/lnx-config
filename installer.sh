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
MAX_BACKUPS=5  # Keep only 5 most recent backups

# Validate configuration
if [[ "$MAX_BACKUPS" -lt 1 ]] || [[ "$MAX_BACKUPS" -gt 50 ]]; then
    echo "Error: MAX_BACKUPS must be between 1 and 50. Current value: $MAX_BACKUPS"
    exit 1
fi

# Files to backup
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

# Function to install packages via apt
install_packages() {
    log_section "Installing packages via apt"
    
    # Check if apt is available
    if ! command -v apt &> /dev/null; then
        log_warn "apt is not available, skipping package installation"
        return 0
    fi
    
    local apps_file="$SCRIPT_DIR/applications/apps.txt"
    
    if [[ ! -f "$apps_file" ]]; then
        log_warn "Apps file not found: $apps_file"
        return 0
    fi
    
    log_info "Updating package lists..."
    if apt update; then
        log_success "Package lists updated"
    else
        log_error "Failed to update package lists"
        return 1
    fi
    
    log_info "Upgrading existing packages..."
    if apt upgrade -y; then
        log_success "Packages upgraded"
    else
        log_error "Failed to upgrade packages"
        return 1
    fi
    
    log_info "Installing packages from: $apps_file"
    
    # Read packages from file and separate apt packages from special cases
    local apt_packages=()
    local special_packages=()
    
    while read -r package; do
        # Skip empty lines and comments
        if [[ -n "$package" && ! "$package" =~ ^[[:space:]]*# ]]; then
            case "$package" in
                "joshuto")
                    special_packages+=("$package")
                    ;;
                *)
                    apt_packages+=("$package")
                    ;;
            esac
        fi
    done < "$apps_file"
    
    # Install apt packages (check if already installed)
    if [[ ${#apt_packages[@]} -gt 0 ]]; then
        local packages_to_install=()
        
        for package in "${apt_packages[@]}"; do
            if dpkg -l | grep -q "^ii  $package "; then
                log_info "Package $package is already installed, skipping"
            else
                packages_to_install+=("$package")
            fi
        done
        
        if [[ ${#packages_to_install[@]} -gt 0 ]]; then
            log_info "Installing ${#packages_to_install[@]} apt packages: ${packages_to_install[*]}"
            
            if apt install -y "${packages_to_install[@]}"; then
                log_success "Installation completed successfully!"
            else
                log_error "Failed to install some apt packages"
                return 1
            fi
        else
            log_info "All apt packages are already installed"
        fi
    else
        log_info "No apt packages to install"
    fi
    
    # Install special packages (check if already installed)
    if [[ ${#special_packages[@]} -gt 0 ]]; then
        log_info "Installing ${#special_packages[@]} special packages: ${special_packages[*]}"
        
        for package in "${special_packages[@]}"; do
            case "$package" in
                "joshuto")
                    if command -v joshuto &> /dev/null; then
                        log_info "joshuto is already installed, skipping"
                    else
                        install_joshuto
                    fi
                    ;;
                *)
                    log_warn "Unknown special package: $package"
                    ;;
            esac
        done
    else
        log_info "No special packages to install"
    fi
}

# Function to install joshuto via cargo
install_joshuto() {
    log_info "Installing joshuto via cargo..."
    
    # Check if cargo is available
    if ! command -v cargo &> /dev/null; then
        log_warn "cargo is not available, skipping joshuto installation"
        return 0
    fi
    
    # Create temporary directory for joshuto source
    local temp_dir=$(mktemp -d)
    local joshuto_dir="$temp_dir/joshuto"
    
    # Clone joshuto repository
    if git clone https://github.com/kamiyaa/joshuto.git "$joshuto_dir"; then
        log_info "Installing joshuto from source..."
        if (cd "$joshuto_dir" && cargo install --path=. --force --root=/usr/local); then
            log_success "joshuto installed successfully"
        else
            log_error "Failed to install joshuto"
        fi
    else
        log_error "Failed to clone joshuto repository"
    fi
    
    # Clean up temporary directory
    rm -rf "$temp_dir"
}

# Function to create .bash_profile
create_bash_profile() {
    log_section "Creating .bash_profile"
    
    local bash_profile_file="$HOME/.bash_profile"
    
    # Create .bash_profile that sources .bashrc
    log_info "Creating .bash_profile to source .bashrc"
    echo "source $HOME/.bashrc" > "$bash_profile_file"
    
    log_success ".bash_profile created to source .bashrc"
}

# Function to display summary
display_summary() {
    log_section "Installation Summary"
    echo -e "${COLOR_GREEN}✓ Backup created: $BACKUP_DIR${NC}"
    echo -e "${COLOR_GREEN}✓ Packages installed via apt${NC}"
    echo -e "${COLOR_GREEN}✓ Custom configs copied to ~/.config${NC}"
    echo -e "${COLOR_GREEN}✓ .vimrc created${NC}"
    echo -e "${COLOR_GREEN}✓ .bashrc created${NC}"
    echo -e "${COLOR_GREEN}✓ .bash_profile created${NC}"
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
    clean_old_backups
    create_backup_dir
    backup_files
    remove_existing_configs
    install_packages
    copy_custom_configs
    create_vimrc
    create_bashrc
    create_bash_profile
    display_summary
    
    log_success "Installation completed successfully!"
}

# Handle script interruption
trap 'log_error "Installation interrupted"; exit 1' INT TERM

# Run main function
main "$@"