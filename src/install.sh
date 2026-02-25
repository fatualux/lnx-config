#!/bin/bash

# Installation module

# Configuration
CONFIG_SOURCE_DIR="$SCRIPT_DIR/configs"
CUSTOM_CONFIG_DIR="$CONFIG_SOURCE_DIR/custom"
CORE_BASH_DIR="$CONFIG_SOURCE_DIR/core/bash"
CORE_VIM_DIR="$CONFIG_SOURCE_DIR/core/vim"
SRC_DIR="$SCRIPT_DIR/src"

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

# Function to create .bash_profile
create_bash_profile() {
    log_section "Creating .bash_profile"
    
    local bash_profile_file="$HOME/.bash_profile"
    
    # Create .bash_profile that sources .bashrc
    log_info "Creating .bash_profile to source .bashrc"
    echo "source $HOME/.bashrc" > "$bash_profile_file"
    
    log_success ".bash_profile created to source .bashrc"
}
