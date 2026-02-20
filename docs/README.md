# Dotfiles Configuration Manager

A bash-based configuration manager to install and manage dotfiles across multiple applications with git tracking.

**Project structure**: `STRUCTURE.md`

## Overview

This tool manages configuration files by:
- Installing the project to `~/.lnx-config`
- Backing up existing configs to `~/.config_backup-<timestamp>/`
- Installing `~/.bashrc` and `~/.vimrc` to source from `~/.lnx-config/configs/`
- Creating symlinks in `~/.config` pointing to `~/.lnx-config/configs/<app>`
- Tracking changes in `~/.lnx-config/.git`
- Supporting dry-run mode and structured logging

## Key Features

### Smart Installation Strategy
1. **Backup First**: Existing configurations are backed up to `~/.config_backup-<timestamp>/`
2. **Install Globally**: Entire project copies to `~/.lnx-config/` with `.git` directory
3. **Update RC Files**: `.bashrc` and `.vimrc` are installed with proper sourcing paths
4. **Git Tracking**: All changes to `~/.lnx-config/` are tracked in git
5. **Clean Sourcing**: RC files automatically source from `~/.lnx-config/configs/`

### Advanced Features

- **Centralized Management**: All configurations in one git-tracked location
- **Multi-Application Support**: Manages configs for bash, vim, neovim, ranger, joshuto, and mpv
- **Configuration Backup**: Automatic backup before installation
- **Safe Operations**: Dry-run mode and automatic RC file backups
- **Detailed Logging**: Structured logging for operations and errors
- **Error Handling**: Fail-fast defaults with readable diagnostics
- **Version Control Integration**: Git tracking for easy collaboration and rollback
- **Custom applications installer**: Optional post-install app installation with distro-specific handlers (e.g. Neovim source install, Joshuto)
- **Bash readline autopairs**: Auto-closes `()[]{}` and quotes while typing commands

## Prerequisites

- Bash 4.0+
- Git
- Standard Unix utilities (find, diff, cmp, stat)
- Optional: fzf for enhanced completion

## Installation

1. Clone this repository:
```bash
git clone https://gitlab.com/your-username/dotfiles-config.git
cd dotfiles-config
```

2. Make the main script executable:
```bash
chmod +x main.sh
```

## Usage

### Basic Usage

```bash
./main.sh
```

### Options

- `-h, --help`: Show comprehensive help message
- `-v, --version`: Show version information
- `-d, --dry-run`: Preview changes without applying them
- `-y, --yes`: Skip interactive prompts (defaults to “yes”)

### Custom Applications

At the end of `./main.sh`, you can optionally run the custom application installer at `~/.lnx-config/applications/install_apps.sh`.

Install modes:
- `N`: Skip all custom applications
- `Y` (or Enter): Install all applications automatically
- `y`: Prompt one-by-one (`Y` to install, `n` to skip, `q` to quit early)

Notes:
- Joshuto may be installed via distro packages (Arch/Fedora) or via `cargo` (Debian/Ubuntu)
- The installer may use `rustup` to ensure `rustc`/`cargo` meet minimum version requirements

### Examples

```bash
# Standard installation
./main.sh

# Dry run to preview all changes
./main.sh --dry-run

# Check version
./main.sh --version
```

### Environment Variables

Control logging behavior with these environment variables:

```bash
# Set log level (0=DEBUG, 1=INFO, 2=SUCCESS, 3=WARNING, 4=ERROR)
export LOG_LEVEL=1

# Enable file logging
export LOG_TO_FILE=true
export LOG_FILE=~/.bash_config.log

# Add timestamps to log messages
export LOG_TIMESTAMP=true

# Run with custom settings
./main.sh
```

## How It Works

### Installation Strategy

The installer performs:

1. Backup existing config directories (optional prompts)
2. Copy the project to `~/.lnx-config` (including `.git`)
3. Ensure `~/.lnx-config/configs/<app>` directories are present and populated
4. Install `~/.bashrc` and `~/.vimrc`
5. Create `~/.config/<app>` symlinks pointing to `~/.lnx-config/configs/<app>`
6. Set file permissions
7. Commit changes in `~/.lnx-config` (local git repo)

### File Structure After Installation

```
~/.lnx-config/
├── .git/                          # Git repository for version tracking
├── .gitignore
├── configs/
│   ├── .bashrc                    # Sources ~/.lnx-config/configs/bash/main.sh
│   ├── .vimrc                     # Sources ~/.lnx-config/configs/vim/
│   ├── bash/
│   │   ├── main.sh                # Main bash configuration loader
│   │   ├── config/                # Configuration modules
│   │   ├── aliases/               # Bash aliases
│   │   ├── functions/             # Bash functions
│   │   ├── completion/            # Shell completion
│   │   └── ...
│   ├── vim/
│   ├── nvim/
│   │   ├── config/
│   │   │   └── *.vim              # Vim configuration files
│   │   ├── colors/
│   │   └── autoload/
│   ├── ranger/
│   ├── joshuto/
│   └── mpv/
├── src/
│   ├── logger.sh                  # Logging system
│   ├── colors.sh                  # Color definitions
│   ├── spinner.sh                 # Progress spinners
│   └── ...
├── main.sh                        # Installation script
└── README.md

~/.config/
├── bash/            → ~/.lnx-config/configs/bash       # Symlink (direct editing)
├── vim/             → ~/.lnx-config/configs/vim        # Symlink (direct editing)
├── nvim/            → ~/.lnx-config/configs/nvim       # Symlink (direct editing)
├── ranger/          → ~/.lnx-config/configs/ranger    # Symlink
├── joshuto/         → ~/.lnx-config/configs/joshuto   # Symlink
└── mpv/             → ~/.lnx-config/configs/mpv       # Symlink
```

### Automatic Symlink Management

During installation, the script automatically creates symlinks for all configurations:

```bash
~/.config/bash      → ~/.lnx-config/configs/bash       # Edit directly, changes tracked by git
~/.config/vim       → ~/.lnx-config/configs/vim        # Edit directly, changes tracked by git
~/.config/nvim      → ~/.lnx-config/configs/nvim       # Edit directly, changes tracked by git
~/.config/ranger    → ~/.lnx-config/configs/ranger
~/.config/joshuto   → ~/.lnx-config/configs/joshuto
~/.config/mpv       → ~/.lnx-config/configs/mpv
```

This layout allows you to edit files under `~/.config/<app>` while keeping a tracked copy under `~/.lnx-config`.

If a directory already exists and is not a symlink, the installer will not overwrite it.

---

**Note**: This script modifies system configuration files. Always use `--dry-run` first and backup existing configurations before running.

## Documentation

Complete project documentation is available in this directory:

- **[📚 Documentation Index](README.md)** - Navigate all project documentation
- **[📋 CHANGELOG](CHANGELOG.md)** - Version history and release notes
- **[🗂️ STRUCTURE](STRUCTURE.md)** - Complete directory structure
- **[💻 Developer Guide](copilot-instructions.md)** - Development guidelines and contribution rules

### Bash Configuration Documentation

- **[Bash Docs Overview](bash/docs/README.md)** - Complete bash module documentation
- **[Module Overviews](bash/docs/modules-overview.md)** - Consolidated overview of all bash modules
- **[Configuration Guide](bash/docs/config.md)** - Installation and configuration
- **[Shell Completion](bash/docs/completion.md)** - Autocomplete setup
- **[Functions Library](bash/docs/functions.md)** - Available functions
- **[Testing Guide](bash/docs/tests.md)** - Running tests

### Function Reference

- [Aliases Functions](bash/functions/aliases.md)
- [Development Functions](bash/functions/development.md)
- [Docker Functions](bash/functions/docker.md)
- [Filesystem Functions](bash/functions/filesystem.md)
- [Music Functions](bash/functions/music.md)
