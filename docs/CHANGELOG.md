# Changelog - lnx-config

All notable changes to the lnx-config project are documented here.

## v2.6.9 - 2026-02-20
### Optimized
- **Theme system optimization** for faster startup performance
  - Removed unused theme files (default.sh, minimal.sh, compact.sh, developer.sh) - reduced from 5 themes to 2
  - Kept only rainbow.sh (default) and template.sh for creating new themes
  - Optimized theme.sh to only load the specific theme in use instead of scanning all themes
  - Reduced theme loading overhead by ~80% (from 5 file checks to 1 file check)

- **Simplified theme management**
  - Updated theme.sh with streamlined loading logic
  - Added clear documentation for creating new themes from template
  - Maintained backward compatibility with existing BASH_THEME variable
  - Preserved history synchronization and PROMPT_COMMAND chaining

### Performance Impact
- **Startup time improvement**: Reduced theme loading overhead by ~80%
- **Memory usage**: Lower memory footprint due to fewer loaded theme files
- **Disk usage**: Reduced theme directory size from ~11KB to ~7KB

## v2.6.8 - 2026-02-19
### Fixed
- **Critical history clearing issue** that was unexpectedly clearing bash history
  - Removed conflicting `__bash_history_cleanup` function from `fzf_search.sh` that was overwriting the main history management
  - Fixed theme system to preserve history synchronization by chaining PROMPT_COMMANDs properly
  - Updated installed version in `~/.lnx-config/configs/bash/config/history.sh` to remove problematic `history -c` command
  - Modified `theme.sh` to create wrapper function that preserves existing PROMPT_COMMAND (history sync) while setting theme
  - Removed `PROMPT_COMMAND=set_prompt` from all theme files to prevent overwriting history synchronization

- **Enhanced history synchronization reliability**
  - History sync function now properly preserves in-memory history instead of clearing it
  - Multi-terminal history sharing works correctly without session loss
  - Theme system no longer interferes with history management

### Technical Details
- **Root cause**: Multiple conflicting history management systems were overwriting each other
- **Solution**: Centralized history management in `history.sh` with proper PROMPT_COMMAND chaining
- **Impact**: Users will no longer experience unexpected history clearing during shell sessions

## v2.6.7 - 2026-02-12
### Fixed
- **Critical completion system bugs** identified during code review
  - Fixed Docker completion global variable dependencies in `__docker_map_key_of_current_option()`
  - Added proper error handling for cache directory creation with fallback to temp directory
  - Verified git.sh completion file exists and is properly structured
  - Fixed variable scope issues in backup.sh and prompts.sh (local variable redeclaration)

- **Enhanced Docker completion robustness**
  - `__docker_map_key_of_current_option()` now properly receives completion context parameters
  - Cache directory creation now includes error handling with TMPDIR fallback
  - All completion functions now properly initialize required variables

### Added
- **NixOS support** for application installer
  - Added NixOS detection to OS detection system
  - Added NixOS package management via `nix-env` and `nix-channel --update`
  - Updated package name resolution for NixOS-specific package names
  - Added spp (Simple Password Manager) installation support with NixOS integration

- **spp (Simple Password Manager) installation**
  - Added dedicated installation script for spp with multi-platform support
  - NixOS installation via `nix-env -iA nixpkgs.spp`
  - Fallback installation methods for other distributions
  - Integrated with main application installer workflow

- **NixOS configuration management**
  - Added comprehensive NixOS configuration installation support
  - Automatic backup of existing `/etc/nixos/configuration.nix` before changes
  - Flake-based configuration deployment with `nixos-rebuild switch --flake`
  - User prompts for configuration installation with dry-run support
  - Automatic NixOS detection via `/nix/store` and `/etc/nixos-version`
  - Integration with existing dotfiles management workflow

### Changed
- **Completion system validation**
  - All completion scripts pass syntax validation
  - Comprehensive test suite validates completion functionality
  - Improved error resilience in completion system

## v2.6.6 - 2026-02-04
### Changed
- **Application installer improvements** in `applications/`
  - `install_apps.sh` refactored into a thin entrypoint sourcing modular scripts from `applications/core/`
  - Added spinner feedback for package installs and long-running operations, with improved cleanup to avoid stuck spinners
  - Added app installation modes:
    - `N` skips all custom applications
    - `Y` installs all apps automatically
    - `y` prompts per app (supports `Y/n/q`)
  - Prompt input now reads from `/dev/tty` to ensure per-app selection works even when stdin is redirected
  - Added Debian/Ubuntu package name mapping for portability:
    - `python` → `python3`
    - `openssh` → `openssh-client`
    - `code` skipped when not available in configured apt sources
  - Neovim install updated on Debian/Ubuntu to build from source and install via `make install` (avoids `.deb` packaging failures)
  - Added Rust toolchain validation/upgrading to satisfy `rustc`/`cargo` minimum version requirements (via `rustup` when needed)
  - Added `joshuto` installer with distro-specific strategy (Fedora COPR, Arch packages, Debian/Ubuntu via cargo)

### Added
- **Bash readline autopairs** module
  - Auto-closes `()[]{}` and quotes while typing commands
  - Works in both `emacs-standard` and `vi-insert` readline keymaps

## v2.6.5 - 2026-02-03
### Fixed
- **Empty directory creation issue** in `main.sh`
  - Fixed `create_required_directories()` function creating empty `bash`, `vim`, and `nvim` directories at `.lnx-config/` root level
  - Removed creation of conflicting root-level directories that should only exist under `configs/`
  - Added proper configuration file copying using `rsync --ignore-existing` with `cp` fallback
  - Ensured all configuration files are properly populated from the repository
  - Verified symlinks in `~/.config/` correctly point to populated configuration directories

- **Bash history clearing issue** in `configs/bash/config/history.sh`
  - Removed problematic `history -c` command that was clearing in-memory history
  - Implemented smart history synchronization that preserves current session history
  - Added performance optimizations with reduced HISTFILESIZE (100000→50000) and increased HISTSIZE (5000→10000)
  - Enhanced PROMPT_COMMAND handling to prevent conflicts with existing commands
  - Added conditional cleanup that only runs when history file exceeds size limits
  - Implemented `ignorespace` support and `HISTIGNORE` for cleaner history
  - Added `cmdhist` and `lithist` options for better multi-line command handling

### Changed
- **Installer refactor**: moved `main.sh` functions into modular files under `src/`
  - `main.sh` now focuses on orchestration and sources modules from `src/`
- **Completion system refactor** for Git and Docker
  - Introduced modular completion entrypoints:
    - `configs/bash/completion/git-completion/main.sh`
    - `configs/bash/completion/docker-completion/main.sh`
  - Git completion now provides more context-aware branch/tag/remote/stash/worktree completion
  - Docker completion now completes containers/images (including IDs) for commands like `rm`, `rmi`, and prune-related operations
  - Removed legacy monolithic completion scripts:
    - `configs/bash/completion/git-completion.sh`
    - `configs/bash/completion/docker-completion.sh`

### Testing
- Verified fix with test installation showing:
  - No empty directories at `.lnx-config/` root level
  - Properly populated `configs/bash/`, `configs/nvim/`, etc. with all configuration files
  - Correct symlinks in `~/.config/` pointing to configuration directories
  - Dry-run mode working correctly
- History preservation tests confirm bash history no longer gets cleared unexpectedly

## v2.6.4 - 2026-02-03
### Added
- **WSL interop configuration helper** in `main.sh`
  - New `recreate_wsl_interop_config` function to restore `/usr/lib/binfmt.d/WSLInterop.conf`
  - Executes the recommended WSL interop fix command with full logging of actions and output
  - Respects `--dry-run` mode (no changes applied, logs intended command)
  - Safe to source: `main.sh` now only runs `main` when executed as the entry script

### Testing
- Added `tests/test_wsl_interop.sh` to validate:
  - `main.sh` can be sourced without side effects
  - `recreate_wsl_interop_config` is defined and available to callers
  - `recreate_wsl_interop_config` succeeds in dry-run mode without requiring sudo modifications
- Integrated the new test into both `run_all_tests.sh` and `tests/run_tests_with_spinners.sh`

## v2.6.3 - 2026-02-02
### Added
- **Codeium AI completion integration** in Neovim configuration
  - Added `codeium.nvim` plugin with proper dependencies (`plenary.nvim`, `nvim-cmp`)
  - Configured virtual text completion with custom keybindings:
    - `<C-g>` to accept suggestions
    - `<M-]>` and `<M-[>` for navigation
    - `<C-]>` to dismiss
  - Added custom keybindings in `keybindings.lua`:
    - `<C-x>` to enable Codeium
    - `<C-z>` to disable Codeium
    - `<C-u>` to open Codeium Chat
  - Created `nvim-cmp` configuration for completion integration
  - Fixed statusline git branch variable error for seamless integration

## v2.6.2 - 2026-01-31
### Fixed
- **Git completion function re-sourcing and logic flow**
  - Fixed command alias normalization to only apply at command position, not during argument completion
  - Git command aliases (co, br, ci, st, etc.) now properly complete to matching commands first
  - After command is selected, completion properly shows argument suggestions (branches, tags, etc.)
  - Ensures compgen correctly filters suggestions by prefix match
  - Test: `git co[TAB]` shows matching commands; `git checkout [TAB]` shows branches

## v2.6.1 - 2026-01-31
### Added
- **Git completion alias normalization**
  - Command aliases supported: co→checkout, br→branch, ci→commit, st→status, p→push, pl→pull, f→fetch, m→merge, a→add, r→reset, rb→rebase, t→tag, d→diff, l→log, s→show, c→clone, cfg→config

## v2.6.0 - 2026-01-31
### Added
- **Comprehensive git autocompletion module** in `configs/bash/completion/git-completion.sh`
  - Local and remote branch completion for `git checkout`, `merge`, `reset`, `rebase`
  - Command option completion (--force, --no-verify, --dry-run, etc.)
  - Smart context-aware completions based on previous arguments
  - Stash reference completion (`git stash pop [TAB]`)
  - Tag completion for `git show`, `git checkout`, `git tag`
  - Remote completion for `git push`, `git pull`, `git fetch`
  - 20+ git commands fully supported
  - Efficient helper functions using `git for-each-ref`
  - Full test suite with 19+ tests in `tests/test_git_completion.sh`
  - Comprehensive documentation in `docs/bash/git-completion.md`

## v2.5.0 - 2026-01-31
### Changed
- **Neovim plugin cleanup and refactoring**
  - Stripped `plugins.lua` to minimal template (removed vim-plug bootstrap, 6 vendored plugins)
  - Cleaned `keybindings.lua` (removed Coc.nvim Tab/CR/@ mappings, Codeium E/X/Z/U commands, Black formatter)
  - Cleaned `theme.lua` (removed colorizer and indentLine plugin settings)
  - Preserved all custom functions (AutoGit, find_char, wsl_yank, toggle_autogit)
  - Configuration now contains only native Neovim features + user custom functions
  - Ready for user's own plugin management and extensibility

## v2.4.0 - 2026-01-31
### Added
- **Neovim Lua configuration** in configs/nvim
  - Migrated Vimscript settings, keymaps, and custom functions to Lua
  - Includes vim-plug bootstrap and plugin list parity with Vim
  - WSL clipboard integration, Codeium, Coc, and AutoGit features
- **Neovim symlink support** in installation workflow
  - Backup, directory creation, and ~/.config/nvim symlink handling

### Changed
- Updated documentation to include Neovim configuration and symlink details

## v2.3.0 - 2026-01-30
### Added
- **Integrated Application Installation Prompt** in main.sh
  - Prompts user after successful configuration installation
  - Optional Step 8: Installing Custom Applications
  - Automatically detects and runs `~/.lnx-config/applications/install_apps.sh`
  - User-friendly prompt with clear Y/n options
  - Graceful handling if installer script is missing
  - Displays helpful error messages and log file location

### Changed
- Main installation workflow now includes application installation as final step
- Enhanced user experience with seamless transition from config to apps
- Added post-installation application setup integration

### Benefits
- One-stop installation process for both configs and applications
- Users can choose to skip application installation if desired
- Maintains separation of concerns while improving workflow

## v2.2.0 - 2026-01-30
### Added
- **Custom Application Installer System** (`applications/` directory)
  - Multi-distribution package installation (Debian/Arch/Fedora)
  - Interactive installation modes:
    - `Y` - Install all packages automatically
    - `y/Enter` - Prompt for each package individually
    - `NO` - Skip all installations
    - `no` - Ask for each package with skip option
  - Per-package prompts with quit option (q)
  - Spinner animations during package installation
  - Comprehensive logging system:
    - `install.log` - Complete timestamped installation log
    - `install_errors.log` - Detailed error information for failed packages
  - Progress tracking for successful, failed, and skipped packages
  - Integration with project spinner and color modules

### Files Added
- `applications/apps.txt` - Package list file
- `applications/install_apps.sh` - Main installation script
- `docs/applications.md` - Directory overview and documentation

### Benefits
- Streamlined package installation across different distributions
- User control over what gets installed
- Visual feedback with spinners
- Complete installation audit trail
- Can be integrated into main installation workflow

## v2.1.9 - 2026-01-31
### Changed
- Simplified `initialize_git_commit()` function: removed unused git init branch since .git is already copied from project
- Now only handles adding files and committing to existing repository (significantly cleaner logic)

### Benefits
- Cleaner code with no redundant initialization logic
- Faster installation (one less conditional branch)
- Ensures all configuration changes are tracked from start

## v2.1.5 - 2026-01-30
### Removed
- Removed unused legacy src modules from deprecated multi-repo sync workflow:
  - src/clone_functions.sh, src/sync_functions.sh, src/diff_functions.sh
  - src/rm_functions.sh, src/command_outputs.sh, src/set_rc_functions.sh, src/consts.sh

## v2.1.8 - 2026-01-30
### Added
- **Bash and Vim symlinks in ~/.config**: Can now edit bash and vim configs directly in ~/.config/ with automatic git tracking
- Automatic backup and removal of existing ~/.config/bash and ~/.config/vim directories during installation
- User prompts for bash/vim directory removal if they already exist (with backup option)

### Changed
- Installation step 5 now creates symlinks for bash and vim (in addition to ranger, joshuto, mpv)
- Updated installation documentation to reflect new symlink strategy
- Dry-run mode shows all symlink operations that would be performed

### Benefits
- Direct editing of configs in ~/.config/bash/ and ~/.config/vim/
- All changes automatically tracked by git in ~/.lnx-config/
- ~/.bashrc and ~/.vimrc remain minimal sourcing files
- Centralized, version-controlled configuration management

## v2.1.7 - 2026-01-30
### Changed
- Moved bash test suite to project root tests directory.
- Relocated full test runner to run_all_tests.sh in the project root.

## v2.1.6 - 2026-01-30
### Fixed
- Directory completions now append only a trailing `/` without adding a space.

## v2.1.7 - 2026-01-30
### Changed
- Moved bash test suite to project root tests directory.
- Relocated full test runner to run_all_tests.sh in the project root.

## v2.1.4 - 2026-01-30
### Added
- **Individual backup prompts**: Prompts for each file/folder separately during backup
- User can selectively skip individual items during backup
- New `--yes` / `-y` flag to auto-confirm all prompts for automation
- `prompt_user()` helper function for interactive confirmations
- Backup directory only created if at least one item is backed up

### Fixed
- Fixed bash configuration loading order: functions now load before aliases
- Fixed `list_my_aliases` to use `$BASH_CONFIG_DIR` instead of hardcoded path
- Added automatic `cd` override via `alias cd='cd-activate'` in integrations
- Removed duplicate `cd` alias definitions from alias.sh
- Installation no longer fails if user skips all backup prompts

### Changed
- Installation now prompts for each configuration item separately:
  - bash, vim, ranger, joshuto, mpv directories
  - .bashrc and .vimrc files
- Empty backup directories are not created if no items are backed up
- Use `--yes` flag for unattended installations or CI/CD pipelines
- Dry-run mode automatically skips all prompts

## v2.1.3 - 2026-01-30
### Added
- Automatic symlink creation for external app configs:
  - `~/.config/ranger` → `~/.lnx-config/configs/ranger`
  - `~/.config/joshuto` → `~/.lnx-config/configs/joshuto`
  - `~/.config/mpv` → `~/.lnx-config/configs/mpv`
- New `create_config_symlinks()` function in 7-phase installation workflow
- Smart symlink management: removes old links, skips if directory already exists

### Fixed
- Prevented embedded git repository warnings during installation
- Added `.config_backup-*` and `*.backup.*` to .gitignore
- Added cleanup step to remove backup directories from installation
- Git commit now ensures .gitignore contains backup patterns before adding files
- Fixed syntax error in vimrc installation (duplicate closing braces)

### Changed
- Installation workflow expanded from 6 to 7 phases with new Step 5: Configuration Symlinks
- Installation now explicitly excludes backup directories from git tracking
- Added debug message when cleaning up backup directories

## v2.1.2 - 2026-01-30
### Fixed
- Removed redundant RC file backups in install_rc_files() function
- All backups now consolidated in single ~/.config_backup-<timestamp>/ directory
- RC files (.bashrc, .vimrc) are backed up once in Step 1 instead of twice

### Changed
- Backup counter now includes RC files in total count
- Cleaner installation output without duplicate "backing up" messages

## v2.1.1 - 2026-01-30
### Fixed
- Fixed printf error in `src/logger.sh` log_separator function
- Fixed backup_dir variable contamination from log output
- Backup now excludes .git directories to avoid embedded repository warnings
- All log output from create_backup_dir redirected to stderr

### Changed
- log_separator now uses printf with tr instead of seq for better compatibility

## v2.1.0 - 2026-01-30
### Complete Architectural Redesign: Local Installation with Git Tracking

**BREAKING CHANGES**: Complete shift from repository cloning to local installation model.

### Added
- Installation-based approach: Entire project copied to `~/.lnx-config/`
- Git tracking of all configuration changes in `~/.lnx-config/.git`
- Automatic backup to `~/.config_backup-<timestamp>/` before installation
- Six-phase installation workflow:
  1. Backup existing configs
  2. Install project to ~/.lnx-config
  3. Create required directories
  4. Install RC files with proper sourcing paths
  5. Set permissions
  6. Initialize git commit
- configs/.bashrc sources from ~/.lnx-config/configs/bash/main.sh
- configs/.vimrc sources from ~/.lnx-config/configs/vim/
- Timestamped backups matching version number
- Git workflow documentation in README.md

### Changed
- main.sh: Completely rewritten for installation workflow
- No longer requires username parameter
- RC files now source from ~/.lnx-config/configs/ instead of ~/.config/
- configs/bash/main.sh: Uses BASH_CONFIG_DIR from script location (transparent after copy)
- README.md: Updated with new installation strategy and git workflow
- quick-reference.sh: Updated with new commands and file locations
- copilot-instructions.md: Updated with new architecture and workflows

### Removed
- Repository cloning from GitLab/GitHub
- Username parameter requirement
- Remote repository synchronization
- Diff comparison (no longer needed)
- Clone-based modules:
  - src/clone_functions.sh (replaced with copy logic)
  - src/sync_functions.sh (no longer needed)
  - src/diff_functions.sh (no longer needed)
  - src/consts.sh (git config no longer needed)
  - src/set_rc_functions.sh (integrated into main.sh)
  - src/rm_functions.sh (no longer needed)
  - src/command_outputs.sh (replaced with logger.sh)

### Fixed
- Simplified installation process
- Direct git tracking of user changes
- No remote dependencies
- Easier customization workflow

## v2.0.0 - 2026-01-29
### Major Rewrite: Smart Sync with User File Preservation

- Clone-based synchronization strategy
- User file preservation logic
- Git directory merging
- Detailed diff analysis
- Visual progress indicators

## v1.0.0 - 2026-01-28
### Initial Release

- Support for bash, vim, ranger, joshuto, and mpv configurations
- Dry-run functionality
- Colored output and error handling
