-- General Neovim settings

local opt = vim.opt
local fn = vim.fn

-- Encoding
opt.encoding = "utf-8"

-- Indentation
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 8
opt.autoindent = true

-- UI
opt.number = true
opt.ruler = true
opt.showcmd = true
opt.list = true
opt.listchars = { tab = "▸ ", trail = "▫" }
opt.scrolloff = 5
opt.laststatus = 2

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Behavior
opt.backspace = { "indent", "eol", "start" }
opt.history = 200
opt.autoread = true
opt.ttimeout = true
opt.ttimeoutlen = 100
opt.foldmethod = "manual"

-- Completion
-- 'popup' is only valid in Neovim 0.11+
if fn.has("nvim-0.11") == 1 then
  opt.completeopt = "menuone,noselect,noinsert,popup"
else
  opt.completeopt = "menuone,noselect,noinsert"
end

-- Wildmenu
opt.wildmenu = true
opt.wildmode = "longest:list,full"
opt.shortmess:append("I")

-- Mouse
if fn.has("mouse") == 1 then
  opt.mouse = "a"
end
