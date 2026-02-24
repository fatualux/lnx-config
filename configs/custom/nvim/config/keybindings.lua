local git = require("git")
local finder = require("finder")
local utils = require("utils")

vim.keymap.set("n", "T", ":terminal<CR>")
vim.keymap.set("n", "<C-f>", finder.fuzzy)
vim.keymap.set("n", "<C-q>", ":wq<CR>")
vim.keymap.set("n", "<C-a>", "ggVG")

vim.keymap.set("n", "<C-g>", git.commit_current_file, { desc = "Git commit file" })
vim.keymap.set("n", "<S-h>", utils.toggle_hidden_all)
vim.keymap.set("n", "zz", ":q!<CR>", { desc = "Quit without saving" })

-- Codeium keybindings
vim.keymap.set("n", "<C-x>", ":Codeium Enable<CR>", { desc = "Enable Codeium" })
vim.keymap.set("n", "<C-z>", ":Codeium Disable<CR>", { desc = "Disable Codeium" })
vim.keymap.set("n", "<C-u>", ":Codeium Chat<CR>", { desc = "Open Codeium Chat" })

-- Codeium completion keybindings in insert mode
vim.keymap.set("i", "<CR>", function()
	-- Try to accept Codeium suggestion, fallback to normal Enter
	local ok, virtual_text = pcall(require, "codeium.virtual_text")
	if ok and virtual_text.get_current_completion_item() then
		return virtual_text.accept()
	else
		return "<CR>"
	end
end, { expr = true, desc = "Accept Codeium suggestion or newline" })

vim.keymap.set("i", "<Tab>", function()
	-- Try to accept Codeium suggestion, fallback to normal Tab
	local ok, virtual_text = pcall(require, "codeium.virtual_text")
	if ok and virtual_text.get_current_completion_item() then
		return virtual_text.accept()
	else
		return "<Tab>"
	end
end, { expr = true, desc = "Accept Codeium suggestion or tab" })
