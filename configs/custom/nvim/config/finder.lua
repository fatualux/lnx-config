local api = vim.api
local fn = vim.fn

local M = {}

function M.fuzzy()
  local root = fn.systemlist("git rev-parse --show-toplevel")[1]
  if root == nil or root == "" then
    root = fn.getcwd()
  end

  api.nvim_command("enew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false

  vim.cmd.read({ args = { "!find", root, "-type", "f" } })
  vim.cmd("1delete")

  vim.keymap.set("n", "<CR>", function()
    local file = vim.fn.getline(".")
    vim.cmd("edit " .. vim.fn.fnameescape(file))
  end, { buffer = true })
end

api.nvim_create_user_command("Fuzzy", M.fuzzy, {})

return M
