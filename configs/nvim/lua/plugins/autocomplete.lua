return {
    "deathbeam/myplugins.nvim",
    config = function()
        -- LSP signature help on cursor hover
        require('myplugins').setup {
            lspsignature = {
                -- Add any lspsignature configuration here if needed
            },
            lspecho = {
                -- Add any lspecho configuration here if needed
            }
        }
    end
}
