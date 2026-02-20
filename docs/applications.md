# Applications Directory Overview

## Purpose
The `applications/` directory contains a custom application installer system that manages package installation across multiple Linux distributions (Debian, Arch, Fedora, Alpine, openSUSE) with interactive prompts, comprehensive logging, and graceful fallback mechanisms.

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
- **Multi-OS Support**: Detects and uses appropriate package manager (apt/pacman/dnf/apk/zypper)
- **Graceful Fallback**: When OS detection fails, tries all available package managers automatically
- **Package Manager Detection**: Automatically discovers available package managers (apt, dnf, yum, pacman, apk, zypper)
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
- **Package Name Resolution**: Maps generic package names to distribution-specific variants

**Usage:**
```bash
sudo bash --noprofile --norc install_apps.sh
```

**Dependencies:**
- `src/colors.sh` - Color definitions
- `src/spinner.sh` - Spinner animations
- Root/sudo privileges for package installation

## Core Modules

### core/os.sh
Enhanced OS and package manager detection:
- `detect_os()` - Standard OS detection
- `detect_package_managers()` - Discovers available package managers
- `map_pm_to_os()` - Maps package managers to OS names for compatibility

### core/pkg.sh
Package management with fallback support:
- `resolve_package_name()` - Maps generic names to distribution-specific packages
- `update_package_cache()` - Updates cache for all supported package managers
- `install_package()` - Installs packages using specific package manager
- `try_install_with_fallback()` - Tries all available package managers gracefully

## Supported Package Managers

| Package Manager | OS Distribution | Install Command | Update Command |
|----------------|----------------|-----------------|----------------|
| apt | Debian/Ubuntu | `apt-get install -y` | `apt-get update` |
| dnf | Fedora/RHEL/CentOS | `dnf install -y` | `dnf check-update` |
| yum | Legacy RHEL/CentOS | `yum install -y` | `yum check-update` |
| pacman | Arch/Manjaro | `pacman -S --noconfirm` | `pacman -Sy` |
| apk | Alpine Linux | `apk add` | `apk update` |
| zypper | openSUSE | `zypper install -y` | `zypper refresh` |

## Fallback Behavior

When OS detection fails (`unknown`), the installer:
1. Detects all available package managers on the system
2. Updates package cache for each detected manager
3. Attempts package installation with each manager in order
4. Logs success/failure for each attempt
5. Continues with next package regardless of individual failures

## Package Name Mapping

The installer automatically maps common package names:

| Generic Name | Debian/Ubuntu | Arch/Manjaro | Fedora/RHEL | Alpine | openSUSE |
|-------------|---------------|--------------|-------------|---------|----------|
| python | python3 | python | python3 | python3 | python3 |
| openssh | openssh-client | openssh | openssh-clients | openssh | openssh |

## Generated Files

### install.log
Complete installation log with timestamps, debug information, and installation results.

### install_errors.log
Created only when package installations fail. Contains:
- Failed package name
- Exit code
- Complete command output
- Timestamp
- Package manager attempted

## Integration Points

This module integrates with:
- Project core modules (`src/colors.sh`, `src/spinner.sh`)
- System package managers (apt-get, pacman, dnf, apk, zypper)
- Main installation workflow (can be called from `main.sh`)

## Notes

- Script must be run with `--noprofile --norc` flags to avoid bash config interference
- Package names should match the target distribution's repository naming
- Fallback mechanism ensures maximum compatibility across distributions
- Some packages may have different names across distributions (e.g., `code` is not in standard Debian repos)
- Failed installations are logged but don't stop the script from continuing
- When OS is unknown, all available package managers are tried in order
