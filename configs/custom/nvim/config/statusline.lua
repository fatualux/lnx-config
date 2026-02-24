-- Statusline and ruler configuration
-- Location: ~/.lnx-config/configs/nvim/config/statusline.lua

local opt = vim.opt

opt.laststatus = 2
opt.ruler = true

-- Function to safely get git branch
local function get_git_branch()
	local branch = vim.b.git_current_branch
	if branch and branch ~= "" then
		return branch
	else
		return ""
	end
end

-- Set rulerformat with safe git branch display
opt.rulerformat = "%32(%=%{%v:lua.get_git_branch()%}%=%) %8l,%-6(%c%V%)%=%4p%% %P"

-- Make the function globally available for the statusline
_G.get_git_branch = get_git_branch
