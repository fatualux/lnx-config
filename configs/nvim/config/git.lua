local api = vim.api
local fn = vim.fn

local M = {}

function M.update_branch()
  local file = fn.expand("%:p")
  if file == "" then return end

  local dir = fn.fnamemodify(file, ":h")
  local branch = fn.system({ "git", "-C", dir, "branch", "--show-current" })
  vim.b.git_current_branch = vim.trim(branch)
end

api.nvim_create_autocmd("BufEnter", {
  group = api.nvim_create_augroup("GitBranch", { clear = true }),
  callback = M.update_branch,
})

function M.commit_current_file()
  local file = fn.expand("%")
  local msg = fn.input("Commit message: ")
  if msg == "" then
    print("Aborted")
    return
  end

  fn.system({ "git", "add", file })
  fn.system({ "git", "commit", "-m", msg })
end

api.nvim_create_user_command("GitCommitFile", M.commit_current_file, {})

return M
