-- Theme and color scheme configuration

local fn = vim.fn
local opt = vim.opt
local api = vim.api

-- Terminal color support
-- Check if terminal supports colors before enabling features
if fn.has("termtruecolor") == 1 or fn.has("gui_running") == 1 then
  vim.cmd("syntax on")
  opt.number = true
  vim.g.c_comment_strings = 1
  opt.termguicolors = true
end

-- 256 color terminal settings with background erase handling
vim.g.solarized_termcolors = 256
pcall(function()
  -- Handle background erase for terminal compatibility
  vim.cmd("set t_ut=")
end)
vim.g.solarized_contrast = "high"
vim.g.solarized_visibility = "high"
opt.background = "dark"

-- Column color highlighting for line length
api.nvim_create_user_command("ColorColumnHighlight", function()
  api.nvim_create_user_command("ColorColumn", "ctermbg=magenta", {})
  fn.matchadd("ColorColumn", "\\%81v", 78)
end, {})

-- Apply color column on startup
pcall(function()
  vim.cmd("highlight ColorColumn ctermbg=magenta")
  fn.matchadd("ColorColumn", "\\%81v", 78)
end)

-- Enable syntax highlighting
vim.cmd("syntax on")
opt.number = true
