# Neovim Configuration Overview

This directory documents the Neovim configuration shipped with lnx-config. The configuration mirrors the existing Vim feature set while migrating settings, keymaps, and custom functions to Lua.

## Purpose

- Provide a Lua-based Neovim configuration equivalent to configs/vim.
- Keep key behaviors (AutoGit, WSL clipboard, Codeium, Coc, plugins, and UI settings) consistent across Vim and Neovim.
- Ensure Neovim can be managed from ~/.config/nvim via symlink to ~/.lnx-config/configs/nvim.

## Files

- **configs/nvim/init.lua**: Main Neovim configuration. Contains options, mappings, autocommands, plugin bootstrapping, and custom helper functions.

## Usage Notes

- The installer creates a symlink: ~/.config/nvim → ~/.lnx-config/configs/nvim.
- Plugin management uses vim-plug with a bootstrap step if plug.vim is missing.
- Optional features like Codeium and Coc require their plugins to be installed.
- WSL clipboard integration uses /mnt/c/Windows/System32/clip.exe when available.
