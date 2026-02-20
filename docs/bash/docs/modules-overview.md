# Bash Module Overviews

This document provides concise overviews of all bash configuration modules.

## Core Modules

### aliases/
**Purpose**: User-defined shell aliases loaded by main.sh.

**Contents**:
- `alias.sh`: General-purpose aliases for day-to-day commands
- `work-alias.sh`: Work-specific aliases (ignored by git)

**Usage Notes**:
- All `.sh` files in this directory are sourced automatically
- Keep `work-alias.sh` private or environment-specific

### core/
**Purpose**: Shared utilities that support logging, spinners, and ANSI color output.

**Contents**:
- `colors.sh`: ANSI color definitions for consistent terminal styling
- `logger.sh`: Logging helpers for success, error, and info messages
- `spinner.sh`: Terminal spinner utilities for long-running operations

**Usage Notes**:
- `logger.sh` and `spinner.sh` are guarded to prevent double sourcing
- Functions here are used across scripts and integrations

### themes/
**Purpose**: Prompt theme definitions for different shell experiences.

**Contents**:
- `compact.sh`: Compact two-line prompt
- `default.sh`: Default multi-line prompt with system info
- `developer.sh`: Developer-focused prompt with git details
- `minimal.sh`: Minimal single-line prompt
- `rainbow.sh`: Colorful prompt variant

**Usage Notes**:
- Select a theme by setting `BASH_THEME` before sourcing main.sh

### integrations/
**Purpose**: External tool integrations and platform-specific enhancements.

**Contents**:
- Platform-specific integrations (WSL, macOS, etc.)
- External tool wrappers and helpers
- Environment detection and setup

### functions/
**Purpose**: Reusable bash functions organized by category.

**Contents**:
- Development tools and utilities
- Filesystem helpers
- Docker helpers
- Music player controls
- Alias management functions

**Usage Notes**:
- Functions are automatically sourced and available globally
- Each category has its own subdirectory for organization
