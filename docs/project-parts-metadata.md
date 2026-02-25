# Project Parts Metadata

## Repository Information

**Repository Type:** Monolith  
**Total Parts:** 1  
**Analysis Date:** 2026-02-25T02:02:00Z

## Part Details

### Part 1: Main Project

**Part ID:** main  
**Root Path:** /root/Debian/lnx-config  
**Project Type ID:** cli  
**Display Name:** Linux Configuration Auto-Installer

**Technology Stack:**
- **Primary Language:** Shell/Bash
- **Testing Framework:** BATS
- **Configuration Management:** NixOS flakes
- **Version Control:** Git

**Key Files:**
- `installer.sh` - Main installer script
- `src/colors.sh` - Color utilities
- `src/logger.sh` - Logging framework  
- `src/spinner.sh` - Progress utilities
- `configs/core/` - Core system configurations
- `configs/custom/` - Custom application configurations
- `tests/` - BATS test suite

**Architecture Pattern:** Configuration Management & Deployment Automation

**Critical Directories:**
- `configs/` - Configuration repository
- `src/` - Utility libraries
- `tests/` - Test suite
- `applications/` - Application package lists

## Integration Points

**Internal Integrations:** None (monolith structure)  
**External Dependencies:** Git, BATS, NixOS (optional)  
**System Integration:** Bash environment, Vim/Neovim, system configuration files

## Documentation Requirements Applied

**Based on CLI Project Type:**
- `requires_api_scan`: false
- `requires_data_models`: false
- `requires_state_management`: false
- `requires_ui_components`: false
- `requires_deployment_config`: false

**Scan Strategy:** Pattern-based analysis (Quick Scan mode)
