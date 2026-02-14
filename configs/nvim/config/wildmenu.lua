-- Wildmenu and command line configuration
-- Location: ~/.lnx-config/configs/nvim/config/wildmenu.lua

local opt = vim.opt
-- Wildmenu settings
opt.wildmenu = true
opt.wildmode = "longest:list,full"
opt.shortmess:append("I")
