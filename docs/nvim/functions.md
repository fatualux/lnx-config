# Neovim Functions Organization

## Overview

The Neovim configuration functions are organized into specialized modules for better maintainability and clarity. All functions from the Vim configuration have been converted to Lua and properly organized.

## Module Structure

### `git.lua` - Git Integration Functions
Location: `~/.lnx-config/configs/nvim/config/git.lua`

**Purpose**: Handles all git-related functionality including branch detection and automatic git operations.

**Functions**:
- `git_branch_for(file)` - Get the current git branch for a file path
- `enable_autogit()` - Enable automatic git commit on buffer write
- `disable_autogit()` - Disable automatic git commit
- `toggle_autogit()` - Toggle AutoGit on/off

**Autocommands**:
- `GitBranch` group: Updates git branch on `BufEnter`, `ShellCmdPost`, `FileChangedShellPost`
- `AutoGit` group: Commits changes on `BufWritePost` (when enabled)

**Auto-initialization**:
- Git branch detection starts automatically
- AutoGit is disabled by default but can be toggled with `Ctrl+G`

### `utils.lua` - General Utility Functions
Location: `~/.lnx-config/configs/nvim/config/utils.lua`

**Purpose**: Contains general-purpose utility functions for UI, search, clipboard, and plugins.

**Functions**:

#### UI/Display
- `toggle_hidden_all()` - Toggle visibility of UI elements (ruler, mode, command display)

#### Search Functions
- `find_char()` - Search for and find a character (mapped to `Ctrl+L`)
- `fuzzy_find()` - Open fuzzy file finder using `find` command

#### Clipboard Functions (WSL Support)
- `wsl_yank()` - Copy visual selection to WSL Windows clipboard
- Auto-copy on yank (enabled if `clip.exe` is available)

#### Plugin Management
- `install_vim_plug_if_needed()` - Check and install vim-plug if missing

**Autocommands**:
- `WSLClipboard` group: Auto-copy yanked text to Windows clipboard (WSL only)

**User Commands**:
- `:Fuzzy` - Open fuzzy file finder

### `cust_func.lua` - Function Aggregator
Location: `~/.lnx-config/configs/nvim/config/cust_func.lua`

**Purpose**: Central aggregation point that imports functions from specialized modules and exports them globally for keybindings.

**Imports from**:
- `git.lua` - All git-related functions
- `utils.lua` - All utility functions

**Global Exports**:
- Makes all functions available as `_G.function_name` for use in keybindings and other configurations
- Ensures consistent function naming and availability

## Converted Functions from Vim

### From `vim/config/cust_func.vim`

1. **GitBranch** ✓
   - Vim: `fun! GitBranch(file)`
   - Lua: `M.git_branch_for(file)` in `git.lua`
   - Auto-triggered on buffer change

2. **AutoGit** ✓
   - Vim: `function! AutoGit()`
   - Lua: `auto_git_commit()` in `git.lua`
   - Features:
     - Prompts for git add
     - Optional commit message
     - Optional push confirmation
   - Toggleable with `Ctrl+G`

3. **ToggleAutoGit** ✓
   - Vim: `function! ToggleAutoGit()`
   - Lua: `M.toggle_autogit()` in `git.lua`
   - Mapped to `Ctrl+G`

4. **FindChar** ✓
   - Vim: `function FindChar()`
   - Lua: `M.find_char()` in `utils.lua`
   - Mapped to `Ctrl+L`

5. **WSLYank** ✓
   - Vim: `function! WSLYank()`
   - Lua: `M.wsl_yank()` in `utils.lua`
   - Mapped to `Ctrl+C` in visual mode
   - Auto-copy feature on text yank

### From `vim/config/wildmenu.vim`

6. **ToggleHiddenAll** ✓
   - Vim: `function! ToggleHiddenAll()`
   - Lua: `M.toggle_hidden_all()` in `utils.lua`
   - Mapped to `Shift+H`
   - Toggles: showmode, ruler, laststatus, showcmd

### From `vim/config/general.vim`

7. **InstallVimPlugIfNeeded** ✓
   - Vim: `function! InstallVimPlugIfNeeded()`
   - Lua: `M.install_vim_plug_if_needed()` in `utils.lua`
   - Auto-runs on configuration load
   - Supports Unix/Linux (uses curl)

### From `vim/config/statusline.vim` (Integrated)

8. **GitBranch (Status)** ✓
   - Vim: `fun! GitBranch(file)` in statusline.vim
   - Lua: Same as main GitBranch in `git.lua`
   - Used for statusline display as `git_current_branch`

## Keybindings Reference

All keybindings are defined in `keybindings.lua`:

| Keybind | Function | Origin |
|---------|----------|--------|
| `Ctrl+G` | Toggle AutoGit | git.lua |
| `Ctrl+L` | Find character | utils.lua |
| `Shift+H` | Toggle UI visibility | utils.lua |
| `Ctrl+C` (visual) | Copy to WSL clipboard | utils.lua |
| `Ctrl+F` | File explorer | native |
| `Ctrl+S` | Split window | native |
| `Ctrl+T` | New tab | native |
| `Ctrl+W` | Close tab | native |
| `Ctrl+A` | Select all | native |
| `Tab` | Next tab | native |
| `Ctrl+Q` | Quit | native |
| `:Fuzzy` | Fuzzy file finder | utils.lua |

## Loading Order

Functions are loaded in this order (from `main.lua`):
1. `general` - Base configuration
2. `theme` - Color scheme
3. `plugins` - Plugin management
4. `statusline` - Status line configuration
5. `wildmenu` - Command completion
6. **`git`** - Git functions (new)
7. **`utils`** - Utility functions (new)
8. `cust_func` - Function aggregator
9. `keybindings` - All keybindings

## Development Notes

- All functions are properly modularized by concern
- Global exports in `cust_func.lua` ensure keybindings always have access
- Autocommands are properly grouped for management
- Error handling includes checks for availability (e.g., WSL clipboard tool)
- Each module is self-contained and can be tested independently

## Usage Examples

### Toggle AutoGit
```vim
" In normal mode
<C-g>
```

### Find a character
```vim
" In normal mode, then type the character to find
<C-l>
```

### Toggle UI elements
```vim
" Hide/show statusline, ruler, etc.
<S-h>
```

### Copy to clipboard (WSL)
```vim
" In visual mode
<C-c>
```

### Fuzzy file finder
```vim
:Fuzzy
```
