# Applications Directory Overview

## Purpose
The `applications/` directory contains the custom application installer system that manages package installation across multiple Linux distributions (Debian, Arch, Fedora) with interactive prompts and comprehensive logging.

## Files

### apps.txt
Package list file containing application names to install. One package name per line. Supports comments with `#`.

**Format:**
```
curl
wget
git
# Comments are supported
vim
```

### install_apps.sh
Main installation script with the following features:

**Key Features:**
- **Multi-OS Support**: Detects and uses appropriate package manager (apt/pacman/dnf)
- **Interactive Modes**:
  - `Y` - Install all packages automatically
  - `y/Enter` - Prompt for each package individually
  - `NO` - Skip all installations
  - `no` - Ask for each package (can skip or install)
- **Spinner Animations**: Visual feedback during package installation
- **Comprehensive Logging**: 
  - `install.log` - Complete timestamped installation log
  - `install_errors.log` - Detailed error information for failed packages
- **Progress Tracking**: Tracks successful, failed, and skipped packages

**Usage:**
```bash
sudo bash --noprofile --norc install_apps.sh
```

**Dependencies:**
- `src/colors.sh` - Color definitions
- `src/spinner.sh` - Spinner animations
- Root/sudo privileges for package installation

## Generated Files

### install.log
Complete installation log with timestamps, debug information, and installation results.

### install_errors.log
Created only when package installations fail. Contains:
- Failed package name
- Exit code
- Complete command output
- Timestamp

## Integration Points

This module integrates with:
- Project core modules (`src/colors.sh`, `src/spinner.sh`)
- System package managers (apt-get, pacman, dnf)
- Main installation workflow (can be called from `main.sh`)

## Notes

- Script must be run with `--noprofile --norc` flags to avoid bash config interference
- Package names should match the target distribution's repository naming
- Some packages may have different names across distributions (e.g., `code` is not in standard Debian repos)
- Failed installations are logged but don't stop the script from continuing
