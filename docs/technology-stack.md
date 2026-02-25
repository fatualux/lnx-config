# Technology Stack

## Overview

The lnx-config project is built entirely using Bash/Shell scripting with a modular architecture designed for Linux system configuration management.

## Core Technologies

### Language & Runtime
- **Bash/Shell** (POSIX compliant)
  - Primary implementation language
  - System-native compatibility
  - No external runtime dependencies

### Testing Framework
- **Bats-Core** (Bash Automated Testing System)
  - Comprehensive test suite (73 tests)
  - 100% test coverage achieved
  - CI/CD ready testing infrastructure

### Package Management
- **APT** (Advanced Package Tool)
  - Primary package manager for Debian/Ubuntu systems
  - 47 pre-configured applications
  - Dependency resolution

## Development Toolchain

### Build Tools
- **GCC** (GNU Compiler Collection)
- **CMake** (Cross-platform build system)
- **Make** (Build automation)

### Version Control
- **Git** (Distributed version control)
- **git-filter-repo** (Repository filtering)

### Containerization
- **Docker** (Container platform)
- **Docker Buildx** (Multi-platform builds)
- **Docker Compose** (Multi-container orchestration)

## Supported Languages

### Runtime Languages
- **Python 3.11** (with pip, venv, dev packages)
- **Node.js** (with npm)
- **Go** (Golang toolchain)

### Development Tools
- **Rust** (Systems programming)
- **TypeScript** (Type-safe JavaScript)

## Terminal & Productivity

### Shell Enhancements
- **bash-completion** (Command completion)
- **fzf** (Fuzzy finder)
- **tmux** (Terminal multiplexer)

### Editors & Tools
- **Vim** (Vi IMproved)
- **Neovim** (Modern Vim)
- **Ranger** (File manager)

### System Monitoring
- **btop** (Resource monitor)
- **htop** (Process monitor)

## Development Utilities

### Code Quality
- **ShellCheck** (Shell script analysis)
- **black** (Python formatter)
- **mypy** (Python type checking)

### Data Processing
- **jq** (JSON processor)
- **grep** (Text search)

### Networking & Cloud
- **curl** (HTTP client)
- **kubectl** (Kubernetes client)
- **wget** (File downloader)

## Architecture Pattern

### Modular Shell Script Architecture

```
lnx-config/
├── installer.sh           # CLI entry point with argument parsing
├── src/                   # Core modules (13 shell scripts)
│   ├── main.sh           # Main installation logic
│   ├── install.sh        # Installation procedures
│   ├── backup.sh         # Backup management
│   ├── logger.sh         # Logging system
│   ├── colors.sh         # Color definitions
│   └── ...               # Additional modules
├── configs/               # Configuration templates
│   ├── core/bash/        # Bash configurations
│   ├── core/vim/         # Vim configurations
│   └── custom/            # Custom configurations
└── tests/                 # Bats-core test suite
```

### Key Architectural Features

1. **Modular Design**: Each functionality separated into dedicated modules
2. **Error Handling**: Comprehensive error checking with `set -euo pipefail`
3. **Logging**: Centralized logging system with color output
4. **Testing**: 100% test coverage with bats-core
5. **Configuration**: Template-based configuration system
6. **Package Management**: Automated package installation and management

## Dependencies

### System Requirements
- **Linux** (Debian/Ubuntu based)
- **Bash** 4.0+
- **Root privileges** (for system-wide installation)

### External Dependencies
- **Internet connection** (for package downloads)
- **APT package manager** (for software installation)

## Compatibility

### Supported Distributions
- **Debian** 10+
- **Ubuntu** 18.04+
- **Linux Mint** 19+
- **Pop!_OS** 18.04+

### Shell Compatibility
- **Bash** 4.0+ (primary)
- **Zsh** (limited compatibility)
- **Fish** (limited compatibility)

## Security Considerations

### Installation Safety
- **Dry-run mode** for testing
- **Backup creation** before changes
- **Rollback capabilities**
- **Permission validation**

### Code Quality
- **ShellCheck** compliance
- **Static analysis** for security
- **Input validation**
- **Error handling**
