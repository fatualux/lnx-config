#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"

VERSION="2.6.7"
dry_run=false
auto_yes=false
user_name=""
user_email=""

# Set verbose logging by default
export LOG_LEVEL=0
export LOG_TIMESTAMP=true

# Source core modules with error checking
for module in colors.sh logger.sh spinner.sh; do
	if [[ -f "$SRC_DIR/$module" ]]; then
		source "$SRC_DIR/$module"
	else
		echo "Error: Required core module $SRC_DIR/$module not found" >&2
		exit 1
	fi
done

# Source functional modules with error checking
for module in ui.sh prompts.sh backup.sh install.sh symlinks.sh permissions.sh git.sh applications.sh nixos.sh main.sh; do
	if [[ -f "$SRC_DIR/$module" ]]; then
		source "$SRC_DIR/$module"
	else
		echo "Warning: Optional module $SRC_DIR/$module not found, skipping..." >&2
	fi
done

# Parse command line arguments
while [[ $# -gt 0 ]]; do
	case "$1" in
	-h | --help)
		show_help
		exit 0
		;;
	-v | --version)
		show_version
		exit 0
		;;
	-d | --dry-run) 
		dry_run=true 
		;;
	-y | --yes)
		auto_yes=true
		;;
	--name)
		shift
		user_name="$1"
		;;
	--email)
		shift
		user_email="$1"
		;;
	-*)
		log_error "Unknown option: $1"
		echo "Use --help for usage information"
		exit 1
		;;
	*)
		log_error "Unknown argument: $1"
		echo "Usage: $0 [OPTIONS]"
		echo "Use --help for more information"
		exit 1
		;;
	esac
	shift
done

# Export configuration
export dry_run
export auto_yes
export user_name
export user_email

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main
fi

# Function definitions
show_help() {
	cat << 'EOF'
LNX-CONFIG Linux Configuration Auto-Installer v$VERSION

USAGE:
	installer.sh [OPTIONS]
	
OPTIONS:
	-h, --help          Show this help message
	-v, --version       Show version information
	-d, --dry-run      Show what would be done without making changes
	-y, --yes          Answer yes to all prompts
	--name NAME         Set user name for git configuration
	--email EMAIL       Set user email for git configuration
	
EXAMPLES:
	installer.sh                           # Run interactive installation
	installer.sh --dry-run                 # Preview installation steps
	installer.sh --yes                     # Run non-interactive installation
	installer.sh --name "John Doe" --email "john@example.com"  # Set git config
EOF
}

show_version() {
	echo "LNX-CONFIG Linux Configuration Auto-Installer v$VERSION"
}

main() {
	# Display welcome message
	echo "LNX-CONFIG Linux Configuration Auto-Installer v$VERSION"
	echo ""
	
	# Main installation logic would go here
	if [[ "$dry_run" == "true" ]]; then
		echo "DRY RUN: Would install configuration files..."
	else
		echo "Starting installation..."
	fi
}

# Additional functions needed by tests
configure_git() {
	echo "Configuring git..."
	# Git configuration logic would go here
}

validate_environment() {
	echo "Validating environment..."
	# Environment validation logic would go here
}
