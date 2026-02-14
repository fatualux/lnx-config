#!/bin/bash

# Application installation functions

prompt_install_applications() {
	echo ""
	echo "========================================"
	echo "  Custom Applications Installation"
	echo "========================================"
	echo ""
	echo -e "${BLUE}Would you like to install custom applications?${NC}"
	echo ""
	echo "This will run the application installer which supports:"
	echo "  • Debian/Ubuntu (apt)"
	echo "  • Arch/Manjaro (pacman)"
	echo "  • Fedora/RHEL (dnf)"
	echo ""
	echo -ne "${BLUE}Install custom applications? [Y/n]: ${NC}"
	
	local response
	read -r response
	
	case "${response,,}" in
		n|no|skip)
			log_info "Skipping custom applications installation"
			return 1
			;;
		*)
			log_info "Starting custom applications installation..."
			return 0
			;;
	esac
}

install_custom_applications() {
	local install_script="$HOME/.lnx-config/applications/install_apps.sh"
	
	if [[ ! -f "$install_script" ]]; then
		log_warn "Application installer not found at: $install_script"
		return 1
	fi
	
	log_section "Step 8: Installing Custom Applications"
	
	# Run the installer with proper flags
	if bash --noprofile --norc "$install_script"; then
		log_success "Custom applications installation completed"
	else
		log_warn "Custom applications installation finished with errors"
		log_info "Check ~/.lnx-config/applications/install.log for details"
	fi
}
