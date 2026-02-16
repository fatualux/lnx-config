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

### Added
- Comprehensive vim performance test suite (`tests/test_vim_performance.sh`)
- Tests for startup time, plugin loading, git branch caching, syntax highlighting, autocommand optimization, and memory usage
- Performance thresholds for vim startup (< 2s) and plugin loading (< 5s)

### Fixed
- Fixed installer hanging at "Starting NixOS configuration rebuild..." by correcting non-existent spinner function calls
- Changed `safe_spinner_start` to `spinner_start` in nixos.sh
- Changed `safe_spinner_stop` to `spinner_stop` in nixos.sh
