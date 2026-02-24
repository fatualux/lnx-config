return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    local autopairs = require("nvim-autopairs")
    
    autopairs.setup({
      check_ts = true,  -- Use treesitter to check matching pairs
      ts_config = {
        lua = { "string", "source" },
        javascript = { "string", "template_string" },
      },
    })

    -- Integrate with nvim-cmp for autocomplete (if available)
    local ok, cmp = pcall(require, "cmp")
    if ok then
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
  end,
}
