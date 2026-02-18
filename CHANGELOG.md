# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Performance
- Optimized vim configuration for significant performance improvements
- Added caching to git branch detection with 30-second cache duration
- Reduced autocmd triggers from every buffer change to directory changes only
- Optimized syntax highlighting to only run on files < 100KB with valid filetypes
- Removed duplicate vim-plug installation between general.vim and plugins.vim
- Added silent vim-plug installation to reduce startup noise
- Optimized working directory changes to only occur when directory actually changes
- **Major bash startup performance optimizations:**
  - Batched file sourcing operations to reduce filesystem calls
  - Added 5-second caching to all git operations in prompt
  - Optimized rainbow theme with IP address caching (5-minute TTL)
  - Reduced external command calls in prompt generation
  - Fixed logger sourcing overhead in integration files
  - Removed sleep/clear commands from startup sequence
  - Optimized completion system to prevent redundant loading
  - Fixed rainbow theme color escape sequences for proper display

### Added
- Comprehensive vim performance test suite (`tests/test_vim_performance.sh`)
- Tests for startup time, plugin loading, git branch caching, syntax highlighting, autocommand optimization, and memory usage
- Performance thresholds for vim startup (< 2s) and plugin loading (< 5s)

### Fixed
- Fixed installer hanging at "Starting NixOS configuration rebuild..." by correcting non-existent spinner function calls
- Changed `safe_spinner_start` to `spinner_start` in nixos.sh
- **Critical**: Fixed missing CheckBackspace function in vim general.vim that broke TAB key behavior in Coc.nvim
- **Fixed spinner file duplication**: Eliminated duplicate spinner.sh by making `/src/` the single source of truth
- Updated installer to copy core bash files from `/src/` to `configs/bash/core/` during installation
- Removed duplicate `/configs/bash/core/spinner.sh` - now properly sourced from `/src/spinner.sh`
- **Fixed colors.sh and logger.sh duplication**: Made `/src/` the single source of truth for all core bash files
- Copied improved bash-specific versions from configs to src, then removed duplicates from configs
- Now all core files (spinner.sh, colors.sh, logger.sh) are maintained only in `/src/` and propagated by installer
- **Fixed spinner line clearing**: Spinner characters now properly clear after task completion
- Added proper line clearing and cursor restoration to spinner_task function
- Eliminated leftover spinner characters in output after process completion
- Made vim performance test paths configurable via environment variables
- Added cache cleanup mechanism to git branch cache to prevent memory leaks
- Added cache size limits (50 entries max) to prevent memory growth
- Improved error handling and dependency checking in performance tests
- Documented magic numbers with explanatory comments for better maintainability
- Changed `safe_spinner_stop` to `spinner_stop` in nixos.sh
- **Critical**: Fixed Docker startup hanging forever on NixOS WSL by enabling Docker service in NixOS configuration
- Added virtualisation.docker.enable = true to NixOS flake configuration
- Added user to docker group for proper permissions
- Fixed Docker integration script to use sudo for daemon startup
- Simplified Docker socket configuration for WSL compatibility
