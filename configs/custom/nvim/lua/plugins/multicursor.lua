return {
  "mg979/vim-visual-multi",
  branch = "master",
  init = function()
    -- Configure vim-visual-multi BEFORE it loads
    vim.g.VM_default_mappings = 1
    vim.g.VM_use_single_cursor_mode = 1
    vim.g.VM_exit_from_visual_mode = 1
    vim.g.VM_exit_from_insert_mode = 1
    vim.g.VM_reselect_first = 1
    vim.g.VM_mouse_mappings = 1
    
    -- Custom key mappings using vim-visual-multi's own config
    vim.g.VM_maps = {
      ["Find Under"]          = "<C-d>",
      ["Find Subword Under"]  = "<C-d>",
      ["Skip Region"]         = "<C-x>",
      ["Undo"]                = "<C-u>",
      ["Select All"]          = "g<A-n>",
      ["Start Regex Search"]  = "/",
    }
  end,
  config = function()
    -- Plugin loads with configured mappings
  end,
}
