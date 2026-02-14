# Neovim Functions Quick Reference

## Available Functions by Category

### 🔧 Git Operations

```lua
-- Get current git branch for file
git_branch_for(file)
  → Returns branch name or empty string

-- Toggle automatic git commit
toggle_autogit()
  → Ctrl+G | Toggles AutoGit on/off

-- Manually enable/disable
enable_autogit()   -- Starts watching BufWritePost
disable_autogit()  -- Stops git auto-commit
```

**How AutoGit Works**:
1. File saved → Prompts for adding to git
2. User confirms → Offers to add commit message
3. Commit made → Offers to push changes
4. Toggle with `Ctrl+G` to enable/disable

---

### 🔍 Search & Find

```lua
-- Find character in document
find_char()
  → Ctrl+L | Type character to find

-- Fuzzy file finder
fuzzy_find()
  → :Fuzzy | Opens find results for navigation
```

---

### 📋 UI Controls

```lua
-- Toggle UI elements visibility
toggle_hidden_all()
  → Shift+H | Hide/show statusline, ruler, etc.
```

**Toggle Controls**:
- `showmode` - Show current vim mode
- `ruler` - Show line/column position
- `laststatus` - Show statusline
- `showcmd` - Show partial commands as typed

---

### 📋 Clipboard (WSL)

```lua
-- Copy visual selection to Windows clipboard
wsl_yank()
  → Ctrl+C (visual mode) | Requires WSL

-- Auto-copy on yank (if available)
  → Automatically copies when text is yanked
```

**Requirements**:
- Running in WSL
- `clip.exe` available in Windows System32

---

### 🛠️ Plugin Management

```lua
-- Auto-install vim-plug if needed
install_vim_plug_if_needed()
  → Runs automatically on startup
  → Installs from GitHub if missing
```

---

## Complete Keybinding Map

| Key | Function | Notes |
|-----|----------|-------|
| `Ctrl+G` | Toggle AutoGit | git.lua |
| `Ctrl+L` | Find character | utils.lua |
| `Shift+H` | Toggle UI | utils.lua |
| `Ctrl+C` | Copy to clipboard | utils.lua (visual) |
| `:Fuzzy` | File finder | utils.lua (command) |
| `Ctrl+F` | File explorer | native |
| `Ctrl+S` | Split window | native |
| `Ctrl+T` | New tab | native |
| `Ctrl+W` | Close tab | native |
| `Ctrl+A` | Select all | native |
| `Tab` | Next tab | native |
| `Ctrl+Q` | Quit | native |

---

## Module Map

```
cust_func.lua (aggregator)
├── git.lua
│   ├── git_branch_for()
│   ├── enable_autogit()
│   ├── disable_autogit()
│   └── toggle_autogit()
│
└── utils.lua
    ├── toggle_hidden_all()
    ├── find_char()
    ├── fuzzy_find()
    ├── wsl_yank()
    └── install_vim_plug_if_needed()
```

---

## Usage Examples

### Use AutoGit

```vim
" Toggle AutoGit on/off
<C-g>

" When on (and file is modified):
" 1. Editor prompts: "Changes detected in file.txt. Add to repo? (y/n)"
" 2. Enter 'y' to proceed
" 3. Prompted for commit message
" 4. After commit, asked if you want to push
" 5. Done!
```

### Find a Character

```vim
" Find a character quickly
<C-l>
" Type the character you want to find
" (works like / but for single characters)
```

### Hide UI Elements

```vim
" Toggle distraction-free mode
<S-h>
" Hides statusline, ruler, and mode indicator
" Press again to restore
```

### Copy to Windows Clipboard (WSL)

```vim
" In visual mode, copy selection to Windows clipboard
v         " Start visual mode
" select text "
<C-c>     " Copy to Windows clipboard
" Paste in Windows applications!
```

### Fuzzy File Search

```vim
:Fuzzy
" Shows all files in current directory
" Type filename to filter
" Press Enter to open file
```

---

## Global Function Access

All functions are also available globally and can be called from Lua:

```lua
-- In init.lua or custom scripts:
_G.toggle_autogit()
_G.find_char()
_G.toggle_hidden_all()
_G.wsl_yank()
_G.fuzzy_find()
```

---

## Function Modules

### `git.lua` - Git Integration
- **Location**: `~/.lnx-config/configs/nvim/config/git.lua`
- **Auto-initialized**: Yes (branch detection starts on load)
- **Key Feature**: AutoGit workflow for efficient commits

### `utils.lua` - General Utilities
- **Location**: `~/.lnx-config/configs/nvim/config/utils.lua`
- **Auto-initialized**: Partially (plugins/clipboard checks)
- **Key Features**: UI toggle, search, clipboard, plugin management

### `keybindings.lua` - Key Maps
- **Location**: `~/.lnx-config/configs/nvim/config/keybindings.lua`
- **Centralized**: All keybindings in one file
- **Pattern**: Uses global functions from cust_func.lua

---

## Troubleshooting

### AutoGit doesn't appear to work
```bash
# Check if it's enabled (toggle with Ctrl+G)
# Look at vim messages:
:messages
```

### Clipboard copy not working (WSL)
```bash
# Check if clip.exe is available
which clip.exe
# Or in nvim:
:lua print(vim.fn.executable("/mnt/c/Windows/System32/clip.exe"))
```

### Find character (Ctrl+L) not working
```vim
" Make sure you're in normal mode
" Ctrl+L should show a highlighted match
" Might conflict with other mappings
```

---

## Performance Notes

- Functions are loaded once at startup
- No overhead for disabled features (WSL clipboard only active if available)
- AutoGit can be toggled on/demand
- All functions are lightweight Lua closures

---

## See Also

- **Full Documentation**: [docs/nvim/ORGANIZATION.md](ORGANIZATION.md)
- **Function Details**: [docs/nvim/functions.md](functions.md)
- **Main Config**: [~/.lnx-config/configs/nvim/config/](../config/)
