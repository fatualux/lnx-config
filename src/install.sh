#!/bin/bash

# Installation module

# Set SCRIPT_DIR if not already set
: "${SCRIPT_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Set VERSION if not already set
: "${VERSION:=2.6.7}"

# Source logger for logging functions
if [[ -f "$SCRIPT_DIR/logger.sh" ]]; then
    source "$SCRIPT_DIR/logger.sh"
fi

# Function to create required directories
create_directories() {
    log_section "Creating required directories"
    
    local dirs=(
        "$HOME/.config"
        "$HOME/.local/bin"
        "$HOME/.local/share"
        "$HOME/.cache"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_info "Created directory: $dir"
        fi
    done
    
    log_success "Required directories created"
}

# Function to load package list
load_package_list() {
    log_section "Loading package list"
    
    # For now, just return success
    # In a real implementation, this would load from a config file
    log_success "Package list loaded"
}

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

create_metadata_header() {
    local config_type="$1"  # "bashrc" or "vimrc"
    local module_count="$2"
    local timestamp
    timestamp=$(date -Iseconds)

    local comment_prefix="#"
    if [[ "$config_type" == "vimrc" ]]; then
        comment_prefix='"'
    fi
    
    cat << EOF
$comment_prefix ========================================
$comment_prefix Auto-generated $config_type configuration
$comment_prefix Generated: $timestamp
$comment_prefix Total modules: $module_count
$comment_prefix Generator: LNX-CONFIG v$VERSION
$comment_prefix ========================================
EOF
}

validate_bash_syntax() {
    local bash_file="$1"
    log_debug "Validating bash syntax: $bash_file"
    
    if bash -n "$bash_file" 2>/dev/null; then
        log_success "Bash syntax validation passed: $bash_file"
        return 0
    else
        log_error "Bash syntax validation failed: $bash_file"
        bash -n "$bash_file" 2>&1 | head -20 | while read -r line; do
            log_error "Syntax error: $line"
        done
        return 1
    fi
}

# Function to validate vim syntax
validate_vim_syntax() {
    local vim_file="$1"
    log_debug "Validating vim syntax: $vim_file"
    
    # Check if vim command is available
    if ! command -v vim &> /dev/null; then
        log_info "Vim not available, skipping syntax validation: $vim_file"
        log_info "Vimrc file will still be created for manual use"
        return 0  # Success - .vimrc can still be created
    fi
    
    # Vim is available, proceed with validation
    if vim -c "syntax check" "$vim_file" -c "quitall" 2>/dev/null; then
        log_success "Vim syntax validation passed: $vim_file"
        return 0
    else
        log_error "Vim syntax validation failed: $vim_file"
        vim -c "syntax check" "$vim_file" -c "quitall" 2>&1 | head -10 | while read -r line; do
            log_error "Syntax error: $line"
        done
        return 1
    fi
}

# Function to rollback configuration file
rollback_config() {
    local config_file="$1"
    local backup_file="${config_file}.backup"
    
    if [[ -f "$backup_file" ]]; then
        log_warn "Rolling back to backup: $backup_file"
        cp "$backup_file" "$config_file"
        log_success "Rollback completed: $config_file"
        return 0
    else
        log_error "No backup file found for rollback: $backup_file"
        return 1
    fi
}

# Function to get latest source file modification time
get_latest_source_time() {
    local latest_time=0
    
    # Check source directories
    for dir in "$SRC_DIR" "$CORE_BASH_DIR" "$CORE_VIM_DIR"; do
        if [[ -d "$dir" ]]; then
            local dir_time=$(find "$dir" -name "*.sh" -o -name "*.vim" -type f -printf "%T@\n" 2>/dev/null | sort -r | head -1)
            if [[ -n "$dir_time" && "$dir_time" > "$latest_time" ]]; then
                latest_time="$dir_time"
            fi
        fi
    done
    
    echo "$latest_time"
}

# Function to get generated file modification time
get_generated_time() {
    local config_file="$1"
    
    if [[ -f "$config_file" ]]; then
        stat -c %Y "$config_file" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Function to determine if regeneration is needed
should_regenerate() {
    local config_file="$1"
    local force_flag="$2"
    
    # Always regenerate if force flag is set
    if [[ "$force_flag" == "true" ]]; then
        log_info "Force regeneration requested"
        return 0  # true = should regenerate
    fi
    
    # Check if generated file exists
    if [[ ! -f "$config_file" ]]; then
        log_info "Generated file does not exist, regenerating"
        return 0  # true = should regenerate
    fi
    
    # Compare modification times
    local source_time
    local generated_time
    source_time=$(get_latest_source_time)
    generated_time=$(get_generated_time "$config_file")
    
    if [[ "$source_time" -gt "$generated_time" ]]; then
        log_info "Source files are newer, regenerating"
        return 0  # true = should regenerate
    else
        log_info "Generated file is up-to-date, skipping regeneration"
        return 1  # false = should not regenerate
    fi
}

# Function to create .vimrc
create_vimrc() {
    log_section "Creating .vimrc"
    
    local vimrc_file="$HOME/.vimrc"
    local module_count=0
    
    # Check if regeneration is needed
    if ! should_regenerate "$vimrc_file" "$force_regeneration"; then
        log_info "Skipping .vimrc regeneration (up-to-date)"
        return 0
    fi
    
    # Count modules before processing
    if [[ -d "$CORE_VIM_DIR/config" ]]; then
        module_count=$(find "$CORE_VIM_DIR/config" -name "*.vim" -type f | wc -l)
    fi
    
    # Start with metadata header
    {
        create_metadata_header "vimrc" "$module_count"
        echo '" Vim Configuration Modules'
        echo ""
    } > "$vimrc_file"
    
    # Append content from core/vim/config if exists
    if [[ -d "$CORE_VIM_DIR/config" ]]; then
        log_info "Appending vim configuration from: $CORE_VIM_DIR/config"
        
        # Find all .vim files in config directory and append them
        local vim_files=("$CORE_VIM_DIR/config"/*.vim)
        for vim_file in "${vim_files[@]}"; do
            if [[ -f "$vim_file" ]]; then
                local file_origin="${vim_file#$SCRIPT_DIR/}"
                log_info "Appending: $(basename "$vim_file")"
                echo '" Source: '"$file_origin" >> "$vimrc_file"
                cat "$vim_file" >> "$vimrc_file"
                echo "" >> "$vimrc_file"  # Add newline between files
            fi
        done
        
        log_success ".vimrc created with core vim configuration"
    else
        log_warn "Core vim config directory not found: $CORE_VIM_DIR/config"
        log_info "Created empty .vimrc"
    fi
    
    # Validate the generated vimrc (only if vim is available)
    if command -v vim &> /dev/null; then
        if ! validate_vim_syntax "$vimrc_file"; then
            log_error "Generated .vimrc failed validation, rolling back..."
            rollback_config "$vimrc_file"
            return 1
        fi
    else
        log_info "Vim not available - skipping .vimrc validation (file still created for manual use)"
    fi
    
    # Create backup of generated file
    cp "$vimrc_file" "${vimrc_file}.backup"
    log_success "Backup created: ${vimrc_file}.backup"
}

# Function to create .bashrc
create_bashrc() {
    log_section "Creating .bashrc"
    
    local bashrc_file="$HOME/.bashrc"
    local module_count=0
    
    # Check if regeneration is needed
    if ! should_regenerate "$bashrc_file" "$force_regeneration"; then
        log_info "Skipping .bashrc regeneration (up-to-date)"
        return 0
    fi
    
    # Count modules before processing
    local src_modules=0
    local core_modules=0
    if [[ -d "$SRC_DIR" ]]; then
        src_modules=$(find "$SRC_DIR" -name "*.sh" -type f | wc -l)
    fi
    if [[ -d "$CORE_BASH_DIR" ]]; then
        core_modules=$(find "$CORE_BASH_DIR" -name "*.sh" -type f | wc -l)
    fi
    module_count=$((src_modules + core_modules))
    
    # Start with metadata header
    {
        create_metadata_header "bashrc" "$module_count"
        echo "# Bash Configuration Modules"
        echo ""
        echo "# Script directory for theme loading"
        echo "SCRIPT_DIR=\"$SCRIPT_DIR\""
        echo ""
    } > "$bashrc_file"
    
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
    
    # Validate the generated bashrc
    if ! validate_bash_syntax "$bashrc_file"; then
        log_error "Generated .bashrc failed validation, rolling back..."
        rollback_config "$bashrc_file"
        return 1
    fi
    
    # Create backup of generated file
    cp "$bashrc_file" "${bashrc_file}.backup"
    log_success "Backup created: ${bashrc_file}.backup"
}

# Function to create development mode .bashrc.dev
create_dev_bashrc() {
    log_section "Creating .bashrc.dev (development mode)"
    
    local bashrc_dev_file="$HOME/.bashrc.dev"
    
    # Start with development mode header
    {
        echo "# ========================================"
        echo "# Development Mode .bashrc.dev"
        echo "# Generated: $(date -Iseconds)"
        echo "# Mode: DEVELOPMENT (sourcing-based)"
        echo "# Generator: LNX-CONFIG v$VERSION"
        echo "# ========================================"
        echo ""
        echo "# Development mode sources modules directly for easier development"
        echo "# Use 'source ~/.bashrc.dev' to activate development mode"
        echo ""
        echo "# Script directory for theme loading"
        echo "SCRIPT_DIR=\"$SCRIPT_DIR\""
        echo ""
        echo "# Source colors and logger first"
        echo "if [[ -f \"$SCRIPT_DIR/src/colors.sh\" ]]; then"
        echo "    source \"$SCRIPT_DIR/src/colors.sh\""
        echo "fi"
        echo ""
        echo "if [[ -f \"$SCRIPT_DIR/src/logger.sh\" ]]; then"
        echo "    source \"$SCRIPT_DIR/src/logger.sh\""
        echo "fi"
        echo ""
        echo "# Source all bash modules from directories"
        echo "for config_file in \"$SRC_DIR\"/*.sh \"$CORE_BASH_DIR\"/**/*.sh; do"
        echo "    if [[ -f \"\$config_file\" ]]; then"
        echo "        source \"\$config_file\""
        echo "    fi"
        echo "done"
    } > "$bashrc_dev_file"
    
    log_success ".bashrc.dev created for development mode"
    log_info "To activate: source ~/.bashrc.dev"
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
