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

# Source core modules
source "$SRC_DIR/colors.sh"
source "$SRC_DIR/logger.sh"
source "$SRC_DIR/spinner.sh"

# Source functional modules
source "$SRC_DIR/ui.sh"
source "$SRC_DIR/prompts.sh"
source "$SRC_DIR/backup.sh"
source "$SRC_DIR/install.sh"
source "$SRC_DIR/symlinks.sh"
source "$SRC_DIR/permissions.sh"
source "$SRC_DIR/git.sh"
source "$SRC_DIR/applications.sh"
source "$SRC_DIR/wsl.sh"
source "$SRC_DIR/nixos.sh"
source "$SRC_DIR/main.sh"

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
