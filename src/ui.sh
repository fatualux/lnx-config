#!/bin/bash

# User interface functions for lnx-config

show_help() {
	cat <<EOF
Dotfiles Configuration Manager v${VERSION}

DESCRIPTION:
  Intelligent dotfiles installation tool that copies the entire project to 
  ~/.lnx-config and sources configuration files from there.

STRATEGY:
  1. Back up existing configs to ~/.config_backup-<timestamp>/
  2. Copy entire project to ~/.lnx-config (including .git)
  3. Create necessary config directories
  4. Install ~/.bashrc and ~/.vimrc with proper sourcing
	5. Create configuration symlinks for bash, vim, and neovim in ~/.config
  6. Set appropriate permissions
  7. Initialize git commit for this installation

USAGE: 
  $0 [OPTIONS]

OPTIONS:
  -h, --help        Show this help message
  -v, --version     Show version information
  -d, --dry-run     Preview changes without applying them
  -y, --yes         Automatic yes to prompts (skip backup confirmation)
  --name NAME        Set git user name for commits
  --email EMAIL       Set git user email for commits

EXAMPLES:
  # Standard installation
  $0

  # Dry run to preview all changes
  $0 --dry-run

  # Installation with git user configuration
  $0 --name "John Doe" --email "john@example.com"

  # Automatic installation with git user
  $0 --yes --name "Jane Smith" --email "jane@example.com"

ENVIRONMENT VARIABLES:
  LOG_TO_FILE       Enable file logging (true/false, default: false)
  LOG_FILE          Log file path (default: ~/.lnx_config.log)

EOF
}

show_version() {
	echo "dotfiles-config v${VERSION}"
	echo "Smart Dotfiles Installation with Git Tracking"
}
