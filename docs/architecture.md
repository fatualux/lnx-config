# Architecture Documentation

## Executive Summary

The lnx-config project is a Linux configuration management system built entirely in Bash, featuring a modular architecture that provides automated installation, configuration management, and environment setup for Linux development environments.

## Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Language** | Bash/Shell (POSIX) | Core implementation language |
| **Testing** | Bats-Core | Comprehensive test suite (73 tests) |
| **Package Manager** | APT | Debian/Ubuntu package management |
| **Version Control** | Git | Configuration management |
| **Containerization** | Docker | Container support integration |

## Architecture Pattern

### Modular Shell Script Architecture

The project follows a **component-based modular architecture** with clear separation of concerns:

```
┌─────────────────┐
│   installer.sh   │  ← CLI Entry Point
└─────────┬───────┘
          │
    ┌─────▼─────┐
    │  src/      │  ← Core Modules
    └─────┬─────┘
          │
    ┌─────▼─────┐
    │  configs/  │  ← Configuration Templates
    └─────┬─────┘
          │
    ┌─────▼─────┐
    │  User Env  │  ← Target System
    └─────────────┘
```

### Key Architectural Principles

1. **Modularity**: Each functionality separated into dedicated modules
2. **Error Handling**: Comprehensive error checking with `set -euo pipefail`
3. **Logging**: Centralized logging system with multiple levels
4. **Testing**: 100% test coverage with bats-core
5. **Configuration**: Template-based configuration system
6. **Safety**: Backup and rollback capabilities

## Component Overview

### Core Modules (`src/`)

#### Essential Modules
- **`colors.sh`**: Unified color system with fallback handling
- **`logger.sh`**: Centralized logging with multiple levels (DEBUG, INFO, SUCCESS, WARN, ERROR)
- **`spinner.sh`**: Progress indicators and user feedback

#### Functional Modules
- **`main.sh`**: Core installation logic and workflow orchestration
- **`install.sh`**: Installation procedures and system setup
- **`backup.sh`**: Configuration backup and restore with timestamped directories
- **`permissions.sh`**: File permission management and executable fixing
- **`ui.sh`**: User interface and interaction utilities
- **`prompts.sh`**: Interactive user prompts and input handling
- **`git.sh`**: Git configuration and utilities
- **`applications.sh`**: Package management and application installation
- **`nixos.sh`**: NixOS-specific configurations
- **`symlinks.sh`**: Symbolic link management
- **`spinner.sh`**: Progress indicators and user feedback

### Configuration System (`configs/`)

#### Bash Configurations (`core/bash/`)
- **Theme System**: Dynamic prompts with user, host, git information
- **Environment Management**: Automatic virtual environment activation
- **Productivity Tools**: Auto-pairing, fuzzy search, git utilities
- **Integration**: Docker, git completion, command completion

#### Vim Configurations (`core/vim`)
- **Modular Setup**: Individual configuration files for different features
- **Plugin Support**: Separate configurations for various plugins
- **Syntax Highlighting**: Language-specific configurations

#### Custom Configurations (`custom/`)
- **Application Settings**: Custom application configurations
- **User Preferences**: Personalized settings and tweaks
- **System Integration**: System-specific customizations

## Data Architecture

### Configuration Data Flow

```
User Input → installer.sh → main.sh → install.sh → configs/ → System Files
     ↓              ↓         ↓         ↓          ↓
   CLI Args    Module Load   Logic    Template   Installation
```

### Backup Data Structure
```
src/backups/YY-MM-DD_HH-MM-SS/
├── .bashrc
├── .vimrc
├── .config/
│   ├── bash/
│   └── vim/
└── home/
    └── user/
```

### Logging Data
- **Console Output**: Real-time feedback with colors
- **File Logging**: Optional file logging support
- **Levels**: DEBUG, INFO, SUCCESS, WARN, ERROR
- **Timestamps**: Configurable timestamp formatting

## API Design

### CLI Interface

#### Main Commands
```bash
./installer.sh [OPTIONS]

Options:
  -h, --help      Show help message
  -v, --version   Show version information
  -d, --dry-run   Perform dry run (no changes)
```

#### Module Functions
Each module exposes specific functions:

**Core Functions:**
- `log_info()`, `log_success()`, `log_error()`, `log_warn()`
- `spinner_start()`, `spinner_stop()`
- Color variables: `COLOR_RED`, `COLOR_GREEN`, etc.

**Functional Functions:**
- `show_welcome()`, `validate_config()`
- `create_directories()`, `create_bashrc()`, `create_vimrc()`
- `backup_files()`, `restore_files()`
- `fix_script_permissions()`

### Configuration Loading API

#### Bash Configuration Loading
```bash
# Priority order for loading configurations
1. $SCRIPT_DIR/src/colors.sh (project-specific)
2. $BASH_CONFIG_DIR/colors.sh (user-specific)
3. $HOME/.config/bash/colors.sh (home directory)
4. Fallback definitions (hardcoded)
```

#### Environment Activation API
```bash
# Automatic activation on directory change
cd-activate() {
    builtin cd "$@"
    activate_on_prompt  # Check for virtual environments
}

activate_on_prompt() {
    # Check for .venv, .virtualenv, venv, env, .conda
    # Activate appropriate environment
}
```

## Source Tree

### Directory Structure
```
lnx-config/
├── installer.sh              # Main CLI entry point
├── src/                      # Core modules (13 files)
├── configs/                  # Configuration templates
│   ├── core/bash/           # Bash configs (15 files)
│   ├── core/vim/            # Vim configs (13 files)
│   └── custom/              # Custom configs (29 files)
├── tests/                    # Test suite (73 tests)
├── applications/             # Package definitions
└── docs/                     # Generated documentation
```

### Critical Files
- **`installer.sh`**: CLI interface with argument parsing
- **`src/main.sh`**: Installation workflow orchestration
- **`src/logger.sh`**: Centralized logging system
- **`src/colors.sh`**: Unified color definitions
- **`configs/core/bash/theme.sh`**: Bash prompt and theming

## Development Workflow

### Installation Workflow
```
1. Parse CLI arguments
2. Load core modules (colors, logger, spinner)
3. Load functional modules
4. Validate environment
5. Create backups
6. Install packages
7. Configure bash environment
8. Configure vim environment
9. Set up git configuration
10. Fix permissions
```

### Module Loading Order
```
1. Core Modules (required)
   - colors.sh
   - logger.sh  
   - spinner.sh

2. Functional Modules (optional)
   - main.sh
   - install.sh
   - backup.sh
   - permissions.sh
   - ui.sh
   - prompts.sh
   - git.sh
   - applications.sh
   - nixos.sh
   - symlinks.sh
```

## Testing Strategy

### Test Coverage (100% - 73 tests)

#### Test Suites
| Suite | Tests | Coverage |
|-------|-------|----------|
| installer.bats | 12 | Core installation workflow |
| src-modules.bats | 13 | Utility functions and helpers |
| bash-configs.bats | 15 | Shell configuration and completion |
| integration.bats | 12 | End-to-end workflows |
| edge-cases.bats | 15 | Error handling and boundary conditions |
| simple.bats | 3 | Basic functionality verification |

#### Testing Framework
- **Bats-Core**: Bash Automated Testing System
- **Test Helper**: Custom assertion functions and utilities
- **CI/CD Ready**: Exit codes and output formatting for automation

### Quality Assurance
- **ShellCheck**: Static analysis for shell scripts
- **Syntax Validation**: All shell scripts validated
- **Error Handling**: Comprehensive error checking
- **Logging**: Centralized logging with multiple levels

## Deployment Architecture

### Installation Targets
- **System Packages**: 47 pre-configured applications via APT
- **Configuration Files**: Bash, vim, and custom configurations
- **Environment Setup**: PATH, aliases, functions, completions
- **User Environment**: Home directory configuration

### Deployment Process
```
1. Environment Validation
2. Backup Creation
3. Package Installation
4. Configuration Deployment
5. Permission Setup
6. Environment Integration
```

### Safety Mechanisms
- **Dry Run Mode**: Test installation without making changes
- **Backup System**: Automatic backup before changes
- **Rollback Capability**: Easy restoration of previous configurations
- **Error Handling**: Graceful failure with clear error messages

## Performance Considerations

### Resource Requirements
- **Memory**: ~50MB base footprint
- **Disk**: ~100MB for full installation
- **CPU**: Low overhead, background operations only

### Optimizations
- **IP Caching**: 5-minute cache for external IP lookups
- **Lazy Loading**: Modules loaded on-demand
- **Parallel Operations**: Concurrent package installation where possible

### Startup Performance
- **Cold Start**: ~2-3 seconds for full environment setup
- **Warm Start**: ~1 second with cached configurations
- **Incremental**: ~0.5 seconds for additional modules

## Security Architecture

### Permission Management
- **Root Privileges**: Required for system-wide installation
- **Permission Validation**: Check file permissions before operations
- **Safe Operations**: Use `set -euo pipefail` for error prevention

### Data Protection
- **Backup Creation**: Automatic backup before modifications
- **Rollback Support**: Easy restoration of previous configurations
- **Input Validation**: Validate user inputs and parameters

### Code Security
- **Static Analysis**: ShellCheck compliance
- **Error Handling**: Comprehensive error checking
- **Input Sanitization**: Safe parameter expansion

## Integration Architecture

### System Integration
- **Shell Integration**: Automatic bashrc configuration
- **Editor Integration**: Vim configuration and plugins
- **Package Manager**: APT integration for package installation
- **Version Control**: Git configuration and utilities

### External Tool Integration
- **Docker**: Container management and integration
- **Virtual Environments**: Python venv, conda activation
- **Development Tools**: IDE and editor configurations
- **Productivity Tools**: Terminal utilities and enhancements

## Extensibility

### Module System
- **Modular Architecture**: Easy addition of new modules
- **Plugin Support**: Extensible configuration system
- **Template System**: Reusable configuration templates
- **Dependency Management**: Clear module dependencies

### Configuration Extensibility
- **Custom Configurations**: User-specific configurations in `custom/`
- **Template System**: Reusable configuration patterns
- **Environment Adaptation**: Support for different environments
- **Multi-platform**: Cross-distribution compatibility

## Maintenance Architecture

### Backup Strategy
- **Automatic Backups**: Pre-installation backup creation
- **Timestamped Directories**: Unique backup identification
- **Retention Policy**: Configurable backup retention
- **Recovery Procedures**: Clear restoration instructions

### Update Management
- **Version Control**: Git-based version tracking
- **Configuration Updates**: Update management for configurations
- **Package Updates**: Automated package update management
- **Dependency Management**: Track and update dependencies

### Monitoring
- **Logging System**: Comprehensive logging with multiple levels
- **Error Reporting**: Detailed error messages and stack traces
- **Performance Monitoring**: Resource usage tracking
- **Health Checks**: System health validation
