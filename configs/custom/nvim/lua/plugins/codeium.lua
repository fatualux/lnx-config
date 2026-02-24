return {
	"Exafunction/codeium.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
	},
	event = "InsertEnter",
	cmd = { "Codeium" },
	config = function()
		require("codeium").setup({
			virtual_text = {
				enabled = true,
				virtual_text_priority = 1000,
				key_bindings = {
					accept = "<C-g>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
		})

		-- Set Codeium virtual text color to light gray
		vim.api.nvim_set_hl(0, "CodeiumSuggestion", { fg = "#9e9e9e", italic = true })
	end,
}
