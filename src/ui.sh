#!/bin/bash

# User interface module

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

# Function to show help
show_help() {
    cat << EOF
Linux Configuration Auto-Installer v$VERSION

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    -v, --version       Show version information
    -d, --dry-run      Show what would be done without making changes
    -y, --yes          Answer yes to all prompts
    --name NAME         Set user name for git configuration
    --email EMAIL       Set user email for git configuration

EXAMPLES:
    $0                           # Run interactive installation
    $0 --dry-run                 # Preview installation steps
    $0 --yes                     # Run non-interactive installation
    $0 --name "John Doe" --email "john@example.com"  # Set git config

EOF
}

# Function to show version
show_version() {
    echo "Linux Configuration Auto-Installer v$VERSION"
}
