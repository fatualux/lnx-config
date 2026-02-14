-- Neovim configuration for lnx-config
-- Main entry point - loads all configuration modules
-- Location: ~/.lnx-config/configs/nvim/init.lua

-- Set up the package path to find local config modules
local init_file = debug.getinfo(1).source:sub(2)
local config_dir = init_file:match("(.*/)(.*)")
if config_dir then
	config_dir = config_dir .. "config"
	package.path = config_dir .. "/?.lua;" .. package.path
end

require("main")
