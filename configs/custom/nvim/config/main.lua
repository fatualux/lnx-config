-- Main configuration loader for Neovim
-- Location: ~/.lnx-config/configs/nvim/config/main.lua
-- This file is sourced from init.lua to load all configuration modules

-- Add config directory to package path for requires
local config_dir = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ':h')
package.path = config_dir .. '/?.lua;' .. package.path

-- Source all configuration modules in order
require('general')
require('plugin_manager')
require('git')
require('theme')
require('statusline')
require('wildmenu')
require('utils')
require('keybindings')
