# Development Guide

## Overview

This guide provides comprehensive instructions for developing, testing, and maintaining the lnx-config Linux configuration management system.

## Prerequisites

### System Requirements
- **Operating System**: Debian 10+, Ubuntu 18.04+, Linux Mint 19+, Pop!_OS 18.04+
- **Shell**: Bash 4.0+ (required for modern bash features)
- **Privileges**: Root access (for system-wide installation)
- **Internet**: Required for package downloads

### Development Tools
- **Text Editor**: Vim, Neovim, VS Code, or preferred editor
- **Git**: For version control
- **ShellCheck**: For static analysis (recommended)
- **Bats-Core**: For testing (included in project)

## Environment Setup

### Clone Repository
```bash
git clone <repository-url>
cd lnx-config
```

### Development Environment
```bash
# Make installer executable
chmod +x installer.sh

# Run tests to verify environment
./tests/run_tests.sh

# Test dry-run installation
./installer.sh --dry-run
```

### Development Dependencies
```bash
# Install development tools (if not already installed)
sudo apt update
sudo apt install -y shellcheck bats-core git vim
```

## Local Development

### Project Structure
```
lnx-config/
├── installer.sh          # Main entry point
├── src/                  # Source modules
├── configs/              # Configuration templates
├── tests/                # Test suite
├── applications/         # Package definitions
└── docs/                 # Generated documentation
```

### Working with Source Modules

#### Adding New Modules
1. Create new module in `src/` directory
2. Follow naming convention: `module-name.sh`
3. Include error handling and logging
4. Add corresponding tests in `tests/src-modules.bats`

#### Module Template
```bash
#!/bin/bash
# Module: module-name
# Description: Brief description of module purpose

# Source dependencies
source "${SCRIPT_DIR}/logger.sh"

# Main function
function module_function() {
    log_section "Module Name"
    
    # Implementation here
    
    log_success "Module completed"
}
```

### Configuration Development

#### Adding New Configurations
1. Add configuration file to appropriate `configs/` subdirectory
2. Follow naming conventions and structure
3. Include error handling for missing dependencies
4. Add corresponding tests

#### Configuration Template
```bash
#!/bin/bash
# Configuration: config-name
# Description: Brief description

# Error handling
if [[ -n "${SCRIPT_DIR:-}" ]] && [[ -f "$SCRIPT_DIR/src/colors.sh" ]]; then
    source "$SCRIPT_DIR/src/colors.sh"
fi

# Configuration implementation
```

## Build Process

### No Traditional Build
This project uses shell scripting and doesn't require compilation. The "build" process involves:

1. **Syntax Validation**: Check shell script syntax
2. **Static Analysis**: Run ShellCheck for code quality
3. **Testing**: Execute comprehensive test suite
4. **Documentation**: Generate documentation

### Validation Commands
```bash
# Syntax check all shell scripts
find . -name "*.sh" -exec bash -n {} \;

# Run ShellCheck analysis
find . -name "*.sh" -exec shellcheck {} \;

# Run full test suite
./tests/run_tests.sh

# Check for common issues
./tests/run_tests.sh --lint
```

## Testing

### Test Structure
- **Unit Tests**: Individual module testing
- **Integration Tests**: End-to-end workflow testing
- **Edge Case Tests**: Error handling and boundary conditions
- **Simple Tests**: Basic functionality verification

### Running Tests

#### All Tests
```bash
./tests/run_tests.sh
```

#### Individual Test Suites
```bash
# Installer tests
bats tests/installer.bats

# Source module tests
bats tests/src-modules.bats

# Configuration tests
bats tests/bash-configs.bats

# Integration tests
bats tests/integration.bats

# Edge case tests
bats tests/edge-cases.bats

# Simple tests
bats tests/simple.bats
```

#### Test Coverage
```bash
# Generate coverage report
./tests/run_tests.sh --coverage

# View coverage summary
./tests/run_tests.sh --coverage-summary
```

### Writing Tests

#### Test Structure Template
```bash
#!/usr/bin/env bats

# Test Description

setup() {
    export TEST_MODE=1
    cd /root/Debian/lnx-config
}

teardown() {
    :
}

@test "test description" {
    # Test implementation
    run command_to_test
    [[ $status -eq 0 ]]
}
```

#### Test Helper Functions
```bash
# Use built-in assertions
[[ -f "file.txt" ]]
[[ "$output" == *"expected text"* ]]
[[ $status -eq 0 ]]

# Custom assertions (from test_helper.bash)
assert_file_exists "file.txt"
assert_contains "$output" "pattern"
```

## Common Development Tasks

### Adding New Features

#### 1. Plan the Feature
- Define requirements and scope
- Identify affected modules
- Plan testing approach

#### 2. Implementation
- Create or modify source modules
- Add error handling and logging
- Follow coding conventions

#### 3. Testing
- Write comprehensive tests
- Test edge cases and error conditions
- Ensure 100% test coverage

#### 4. Documentation
- Update relevant documentation
- Add examples and usage instructions
- Update changelog

### Debugging

#### Logging
```bash
# Enable debug logging
export LOG_LEVEL=0

# Run with verbose output
./installer.sh --dry-run 2>&1 | tee debug.log
```

#### Common Issues
- **Permission Errors**: Check file permissions and ownership
- **Module Loading**: Verify module paths and dependencies
- **Configuration**: Check for syntax errors in config files

#### Debug Tools
```bash
# Check script syntax
bash -n script.sh

# Trace execution
bash -x script.sh

# Check for undefined variables
bash -u script.sh
```

### Code Style

#### Shell Scripting Guidelines
- Use `set -euo pipefail` for error handling
- Quote variables: `"$VAR"` instead of `$VAR`
- Use functions for reusable code
- Include error handling and logging

#### Naming Conventions
- **Files**: `kebab-case.sh`
- **Functions**: `snake_case`
- **Variables**: `UPPER_SNAKE_CASE`
- **Constants**: `UPPER_SNAKE_CASE` with `readonly`

#### Documentation Comments
```bash
# Function description
# Usage: function_name arg1 arg2
# Returns: 0 on success, 1 on error
function_name() {
    local arg1="$1"
    local arg2="$2"
    
    # Implementation
}
```

## Release Process

### Version Management
- Use semantic versioning (MAJOR.MINOR.PATCH)
- Update version in `installer.sh`
- Update changelog with new features and fixes

### Pre-release Checklist
- [ ] All tests passing
- [ ] Documentation updated
- [ ] ShellCheck clean
- [ ] Manual testing completed
- [ ] Version updated

### Release Commands
```bash
# Update version
sed -i 's/VERSION=".*"/VERSION="X.Y.Z"/' installer.sh

# Run full test suite
./tests/run_tests.sh

# Create release tag
git tag -a vX.Y.Z -m "Release version X.Y.Z"

# Push changes
git push origin main --tags
```

## Deployment

### Installation Methods

#### Direct Installation
```bash
# Clone and install
git clone <repository-url>
cd lnx-config
./installer.sh
```

#### System Integration
- **Bash Integration**: Automatically added to `.bashrc`
- **Vim Integration**: Automatically configured in `.vimrc`
- **System Packages**: Installed via APT package manager

### Configuration Management
- **Backup**: Existing configurations backed up automatically
- **Rollback**: Easy restoration of previous configurations
- **Customization**: User-specific configurations preserved

## Troubleshooting

### Common Issues

#### Installation Failures
```bash
# Check system compatibility
./installer.sh --dry-run

# Check permissions
sudo ./installer.sh

# Check logs
tail -f ~/lnx-config.log
```

#### Module Loading Errors
```bash
# Check module syntax
bash -n src/module.sh

# Check dependencies
ls -la src/

# Test individual module
source src/module.sh
```

#### Configuration Issues
```bash
# Check bash configuration
bash -n ~/.bashrc

# Check vim configuration
vim -c ":syntax check" ~/.vimrc

# Test individual config
source configs/core/bash/config.sh
```

### Getting Help

#### Built-in Help
```bash
./installer.sh --help
```

#### Debug Information
```bash
# Enable verbose logging
export LOG_LEVEL=0
./installer.sh --dry-run
```

#### Community Support
- **Issues**: Report via GitHub issues
- **Discussions**: Use GitHub discussions
- **Documentation**: Check generated docs in `docs/`

## Contributing

### Contribution Guidelines
1. Fork the repository
2. Create feature branch
3. Make changes with tests
4. Ensure all tests pass
5. Update documentation
6. Submit pull request

### Code Review Process
- **Automated Checks**: ShellCheck, syntax validation
- **Test Coverage**: Must maintain 100% coverage
- **Documentation**: Required for new features
- **Style Guide**: Follow project conventions

### Development Environment
- **IDE**: Use shell scripting plugins
- **Linting**: Configure ShellCheck integration
- **Testing**: Use bats-core integration
- **Documentation**: Markdown preview support
