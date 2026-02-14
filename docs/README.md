# Documentation

Complete documentation for the lnx-config project is organized in this directory.

## Quick Navigation

### Project Documentation
- [**CHANGELOG.md**](CHANGELOG.md) - Version history and release notes
- [**STRUCTURE.md**](STRUCTURE.md) - Directory structure and file organization
- [**copilot-instructions.md**](copilot-instructions.md) - Development guidelines and contribution instructions
- [**tests.md**](tests.md) - Project test suite overview
- [**nvim.md**](nvim.md) - Neovim configuration overview
- [**nvim-structure.md**](nvim-structure.md) - Neovim module structure and organization

### Bash Configuration Library
- [**Bash Documentation Overview**](bash/docs/README.md) - Bash module documentation index
  - [Installation & Configuration](bash/docs/config.md)
  - [Aliases System](bash/docs/aliases.md)
  - [Shell Completion](bash/docs/completion.md)
  - [Core Modules](bash/docs/core.md)
  - [Functions Library](bash/docs/functions.md)
  - [Integrations](bash/docs/integrations.md)
  - [Themes](bash/docs/themes.md)
  - [Testing Guide](bash/docs/tests.md)

### Bash Function Overviews
- [Aliases Module](bash/functions/aliases.md) - List and manage aliases
- [Development Functions](bash/functions/development.md) - Git, code utilities
- [Docker Functions](bash/functions/docker.md) - Container management
- [Filesystem Functions](bash/functions/filesystem.md) - Directory navigation
- [Music Functions](bash/functions/music.md) - Music player control

## File Organization

```
docs/
├── README.md                       # This file
├── CHANGELOG.md                    # Project history
├── STRUCTURE.md                    # Directory tree
├── copilot-instructions.md         # Development guidelines
├── tests.md                        # Tests overview
├── nvim.md                          # Neovim configuration overview
├── nvim-structure.md                # Neovim module structure details
└── bash/                          # Bash configuration documentation
    ├── docs/                      # Bash module documentation
    │   ├── README.md
    │   ├── aliases.md
    │   ├── completion.md
    │   ├── config.md
    │   ├── core.md
    │   ├── docs.md
    │   ├── functions.md
    │   ├── integrations.md
    │   ├── tests.md
    │   ├── themes.md
    │   ├── functions/
    │   │   └── *.md               # Detailed function docs
    │   └── tests/
    │       └── logs.md            # Test logging guide
    └── functions/                 # Function OVERVIEW files
        ├── aliases.md
        ├── development.md
        ├── docker.md
        ├── filesystem.md
        └── music.md
```

## How to Use This Documentation

1. **Getting Started**: Begin with [STRUCTURE.md](STRUCTURE.md) to understand the project layout
2. **Configuration Details**: See [Bash Documentation Overview](bash/docs/README.md) for configuration help
3. **Custom Functions**: Check [Functions Library](bash/docs/functions.md) and individual OVERVIEW files
4. **Development**: Read [copilot-instructions.md](copilot-instructions.md) for development guidelines
5. **Changes**: Review [CHANGELOG.md](CHANGELOG.md) for version information

## Key Documentation Links from Main README

For the complete project overview and usage instructions, see the main [README.md](../README.md)

### Summary of Main Topics
- Installation and quick start guide
- Command-line options and configuration
- Daily workflow patterns
- Troubleshooting guide
- Building and testing procedures
