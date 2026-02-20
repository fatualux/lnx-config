# Neovim Configuration

This directory documents the Neovim configuration shipped with lnx-config. The configuration mirrors the existing Vim feature set while migrating settings, keymaps, and custom functions to Lua.

## Purpose

- Provide a Lua-based Neovim configuration equivalent to configs/vim
- Keep key behaviors (AutoGit, WSL clipboard, Codeium, Coc, plugins, and UI settings) consistent across Vim and Neovim
- Ensure Neovim can be managed from ~/.config/nvim via symlink to ~/.lnx-config/configs/nvim

## Directory Layout

```
configs/nvim/
├── init.lua                    # Main entry point (sets up package.path and loads main)
├── config/                     # Configuration modules
│   ├── main.lua               # Main loader (requires all modules in order)
│   ├── general.lua            # General settings and behaviors
│   ├── theme.lua              # Color scheme and terminal configuration
│   ├── plugins.lua            # Plugin management with vim-plug
│   ├── statusline.lua         # Status line and ruler configuration
│   ├── wildmenu.lua           # Command-line menu settings
│   ├── keybindings.lua        # All keyboard mappings and shortcuts
│   └── cust_func.lua          # Custom functions and autocommands
└── colors/                     # Color scheme files (for future use)
```

## Module Descriptions

### init.lua (Entry Point)
- **Purpose**: Main Neovim configuration entry point
- **Responsibility**: 
  - Sets up Lua package.path to find config modules
  - Requires the main configuration loader
- **Size**: 12 lines

### config/main.lua (Loader)
- **Purpose**: Orchestrates loading of all configuration modules
- **Load Order**:
  1. `general` - Core settings first
  2. `theme` - Appearance settings
  3. `plugins` - Plugin management
  4. `statusline` - Status display
  5. `wildmenu` - Command-line UI
  6. `cust_func` - Custom functions (defines globals)
  7. `keybindings` - Keybindings (uses globals from cust_func)

### config/general.lua (Settings)
- **Purpose**: Core Neovim options and behaviors
- **Includes**: Indentation, search options, file handling, display options, mouse support, basic autocommands
- **Lines**: ~90

### config/theme.lua (Appearance)
- **Purpose**: Color scheme and terminal configuration
- **Includes**: Terminal color support, Solarized theme settings, syntax highlighting, color column highlighting
- **Lines**: ~40

### config/plugins.lua (Plugin Management)
- **Purpose**: Plugin management setup
- **Note**: As of v2.5.0, this contains only a clean template for user customization
- **Previously included**: vim-plug bootstrap, Codeium, Coc.nvim, Colorizer, Auto-pairs, Vim Markdown Preview, Black
- **Lines**: ~18 (template)

### config/statusline.lua (Display)
- **Purpose**: Status line and ruler configuration
- **Includes**: Git branch detection, ruler format with git branch display, status line settings
- **Lines**: ~30

### config/wildmenu.lua (Command Line)
- **Purpose**: Command-line menu and UI settings
- **Includes**: Wildmenu configuration, `toggle_hidden_all()` function
- **Lines**: ~30

### config/cust_func.lua (Custom Functions)
- **Purpose**: Custom functions and extended functionality
- **Includes**: 
  - `AutoGit()` - Auto-commit on save (with toggle)
  - `find_char()` - Multi-line character search
  - `wsl_yank()` - WSL clipboard integration
  - `toggle_autogit()` - Toggle AutoGit on/off
  - `Fuzzy` command for fuzzy file finding
  - WSL clipboard auto-yank on TextYankPost
- **Lines**: ~120

### config/keybindings.lua (Mappings)
- **Purpose**: All keyboard shortcuts and mappings
- **Includes**: File navigation, AI tool shortcuts, Git controls, search mappings, WSL clipboard shortcuts
- **Note**: As of v2.5.0, plugin-specific mappings (Coc.nvim, Codeium, Black) have been removed
- **Lines**: ~50 (native mappings only)

## Recent Changes (v2.5.0)

The Neovim configuration underwent a significant cleanup to remove external dependencies:

### Removed Plugin Configurations
- **Codeium**: AI code completion mappings and settings
- **Coc.nvim**: Intellisense engine mappings and configuration
- **Colorizer**: Color highlighting plugin
- **Auto-pairs**: Automatic bracket completion
- **Vim Markdown Preview**: Markdown preview functionality
- **Black**: Python code formatter integration

### Current State
- **Clean template**: `plugins.lua` now provides a boilerplate for users to add their own plugin management
- **Native features only**: Configuration now uses only built-in Neovim features
- **User customization**: Users can easily add their preferred plugin manager and plugins

## Usage Notes

- The installer creates a symlink: `~/.config/nvim → ~/.lnx-config/configs/nvim`
- Plugin management uses a clean template - users can add their preferred plugin manager
- Optional features like Codeium and Coc require manual plugin installation if needed
- WSL clipboard integration uses `/mnt/c/Windows/System32/clip.exe` when available

## How to Modify

### Adding a New Plugin
1. Edit `config/plugins.lua`
2. Add your preferred plugin manager setup
3. Add plugin definitions as needed

### Adding a New Keybinding
1. Edit `config/keybindings.lua`
2. Add your mapping with `vim.keymap.set()`
3. If it needs a custom function, add it to `cust_func.lua` first

### Adding a Custom Function
1. Edit `config/cust_func.lua`
2. Define your function in the module
3. Add to `_G` table to make it globally available if needed for keybindings

## Comparison with Vim Structure

| Aspect | Vim | Neovim |
|--------|-----|--------|
| Config dir | `configs/vim/config/` | `configs/nvim/config/` |
| File type | Vimscript (.vim) | Lua (.lua) |
| Entry point | ~/.vimrc | ~/.config/nvim/init.lua |

## Benefits of Modularization

1. **Maintainability**: Each module has a single responsibility
2. **Readability**: Smaller files are easier to understand
3. **Reusability**: Modules can be copied or modified independently
4. **Debugging**: Easier to isolate issues to specific modules
5. **Organization**: Follows standard Lua project structure

## Total Lines of Code

- **Total**: ~400 lines (well-organized and maintainable, excluding plugins)
