# Neovim Configuration Module Structure

This document describes the modularized Neovim configuration structure and how each module works together.

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
- **Key Code**:
  ```lua
  local init_file = debug.getinfo(1).source:sub(2)
  local config_dir = init_file:match("(.*/)(.*)")
  if config_dir then
    config_dir = config_dir .. "config"
    package.path = config_dir .. "/?.lua;" .. package.path
  end
  require("main")
  ```

### config/main.lua (Loader)
- **Purpose**: Orchestrates loading of all configuration modules
- **Responsibility**: 
  - Establishes correct package.path
  - Requires all modules in proper order
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
- **Includes**:
  - Indentation settings (tabs, spaces)
  - Search options (case sensitivity, incremental search)
  - File handling (autoread, swapfile location)
  - Display options (ruler, number, list, folds)
  - Mouse support and language mappings
  - Basic autocommands (window resizing, directory changes, buffer jumps)
- **Lines**: ~90

### config/theme.lua (Appearance)
- **Purpose**: Color scheme and terminal configuration
- **Includes**:
  - Terminal color support (256-color detection)
  - Solarized theme settings (contrast, visibility)
  - Syntax highlighting
  - Color column highlighting for line length
  - Indent line styling
- **Lines**: ~40

### config/plugins.lua (Plugin Management)
- **Purpose**: vim-plug initialization and plugin definitions
- **Includes**:
  - vim-plug bootstrap (auto-installation if missing)
  - Plugin definitions (6 plugins):
    - vim-multiple-cursors
    - colorizer
    - auto-pairs
    - vim-closetag
    - coc.nvim
    - codeium.vim
  - Plugin-specific settings (Codeium, Coc, Black formatter)
- **Lines**: ~45

### config/statusline.lua (Display)
- **Purpose**: Status line and ruler configuration
- **Includes**:
  - Git branch detection
  - Ruler format with git branch display
  - Autocommands for updating git branch on buffer events
  - Status line settings
- **Lines**: ~30

### config/wildmenu.lua (Command Line)
- **Purpose**: Command-line menu and UI settings
- **Includes**:
  - Wildmenu configuration (command-line completion menu)
  - Wildmode settings
  - `toggle_hidden_all()` function to hide/show UI elements
  - Makes function globally available
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
  - Exports all functions to `_G` for global access
- **Lines**: ~120

### config/keybindings.lua (Mappings)
- **Purpose**: All keyboard shortcuts and mappings
- **Includes**:
  - File and buffer navigation keys
  - AI and coding tool shortcuts
  - Git and AutoGit controls
  - Search and UI toggle mappings
  - WSL clipboard shortcuts
  - Coc.nvim completion mappings
  - Black formatter (Python)
- **Lines**: ~80

### colors/ (Color Schemes)
- **Purpose**: Store color scheme definitions for future use
- **Currently**: Empty (reserved for custom schemes)
- **Usage**: Can add `.lua` or `.vim` color schemes here

## Loading Order and Dependencies

```
init.lua
  └─> config/main.lua
        ├─> config/general.lua (independent)
        ├─> config/theme.lua (independent)
        ├─> config/plugins.lua (independent)
        ├─> config/statusline.lua (independent)
        ├─> config/wildmenu.lua (independent)
        ├─> config/cust_func.lua (defines globals)
        │     └─> Sets _G.toggle_autogit, find_char, wsl_yank
        └─> config/keybindings.lua (uses globals from cust_func)
              └─> Calls _G.toggle_autogit, find_char, wsl_yank, toggle_hidden_all
```

## How to Modify

### Adding a New Setting
1. Identify which module it belongs to (or create new one)
2. Edit the appropriate `.lua` file
3. The change is loaded automatically on Neovim restart

### Adding a New Plugin
1. Edit `config/plugins.lua`
2. Add `Plug 'plugin/name'` to the plug#begin/end block
3. Restart Neovim or run `:PlugInstall`

### Adding a New Keybinding
1. Edit `config/keybindings.lua`
2. Add your mapping with `vim.keymap.set()`
3. If it needs a custom function, add it to `cust_func.lua` first

### Adding a Custom Function
1. Edit `config/cust_func.lua`
2. Define your function in the module
3. Add to `_G` table to make it globally available if needed for keybindings

## Comparison with Vim Structure

The Neovim config mirrors the Vim structure:

| Aspect | Vim | Neovim |
|--------|-----|--------|
| Config dir | `configs/vim/config/` | `configs/nvim/config/` |
| File type | Vimscript (.vim) | Lua (.lua) |
| General settings | general.vim | general.lua |
| Theme settings | theme.vim | theme.lua |
| Plugins | plugins.vim | plugins.lua |
| Statusline | statusline.vim | statusline.lua |
| Wildmenu | wildmenu.vim | wildmenu.lua |
| Custom functions | cust_func.vim | cust_func.lua |
| Keybindings | keybindings.vim | keybindings.lua |
| Entry point | ~/.vimrc | ~/.config/nvim/init.lua |

## Benefits of Modularization

1. **Maintainability**: Each module has a single responsibility
2. **Readability**: Smaller files are easier to understand
3. **Reusability**: Modules can be copied or modified independently
4. **Debugging**: Easier to isolate issues to specific modules
5. **Organization**: Follows standard Lua project structure
6. **Scalability**: Easy to add new modules as needed

## Total Lines of Code

- `init.lua`: 12 lines
- `config/main.lua`: 16 lines
- `config/general.lua`: 87 lines
- `config/theme.lua`: 41 lines
- `config/plugins.lua`: 47 lines
- `config/statusline.lua`: 32 lines
- `config/wildmenu.lua`: 27 lines
- `config/keybindings.lua`: 83 lines
- `config/cust_func.lua`: 128 lines
- **Total**: ~473 lines (well-organized and maintainable)
