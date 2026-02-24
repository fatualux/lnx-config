return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	config = function()
		local cmp = require("cmp")
		
		cmp.setup({
			sources = {
				{ name = "codeium" },
				{ name = "buffer" },
				{ name = "path" },
			},
			mapping = {
				-- Accept completion with Tab
				["<Tab>"] = cmp.mapping.confirm({ select = true }),
				-- Navigate through completions
				["<C-n>"] = cmp.mapping.select_next_item(),
				["<C-p>"] = cmp.mapping.select_prev_item(),
				-- Close completion menu
				["<C-e>"] = cmp.mapping.close(),
			},
		})
	end,
}
