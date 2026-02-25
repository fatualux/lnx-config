-- General utility functions

local fn = vim.fn
local api = vim.api

local M = {}

-- ============================================================================
-- UI/Display Toggle
-- ============================================================================

local hidden_all = false

-- Toggle hidden mode (hide UI elements like ruler, mode, etc.)
function M.toggle_hidden_all()
  hidden_all = not hidden_all
  
  if hidden_all then
    vim.cmd("set noshowmode")
    vim.cmd("set noruler")
    vim.cmd("set laststatus=0")
    vim.cmd("set noshowcmd")
    print("UI hidden")
  else
    vim.cmd("set showmode")
    vim.cmd("set ruler")
    vim.cmd("set laststatus=2")
    vim.cmd("set showcmd")
    print("UI visible")
  end
end

-- ============================================================================
-- Search Functions
-- ============================================================================

-- Find and search for a character
function M.find_char()
  local c = fn.getchar()
  if type(c) == "number" then
    c = fn.nr2char(c)
  end
  if c then
    fn.search("\\V" .. c)
  end
end

-- Fuzzy finder using find command
function M.fuzzy_find()
  vim.cmd("enew")
  vim.cmd("read !find -type f")
  vim.keymap.set("c", "/", "\\/", { buffer = true, noremap = true })
  vim.keymap.set("n", "<CR>", "gf:bd! #<CR>", { buffer = true, noremap = true, silent = true })
end

-- ============================================================================
-- Clipboard Functions
-- ============================================================================

local wsl_clip = "/mnt/c/Windows/System32/clip.exe"

-- Yank selection to WSL clipboard (Windows)
function M.wsl_yank()
  if fn.executable(wsl_clip) ~= 1 then
    print("WSL clipboard tool (clip.exe) not found")
    return
  end

  -- Get visual selection
  vim.cmd('normal! gv"zy')
  local contents = fn.getreg("z")
  
  if contents == "" then
    print("Register is empty, nothing to yank")
    return
  end

  -- Convert LF to CRLF for Windows clipboard
  local escaped = contents:gsub("\n", "\r\n")
  local cmd = "echo " .. fn.shellescape(escaped) .. " | " .. wsl_clip
  fn.system(cmd)
  
  if vim.v.shell_error ~= 0 then
    print("Error copying to clipboard")
  else
    print("Copied to WSL clipboard")
  end
end

-- Auto-copy to WSL clipboard on yank (if available)
if fn.executable(wsl_clip) == 1 then
  local yank_group = api.nvim_create_augroup("WSLClipboard", { clear = true })
  
  api.nvim_create_autocmd("TextYankPost", {
    group = yank_group,
    callback = function()
      if vim.v.event.operator == "y" then
        fn.system(wsl_clip, fn.getreg("0"))
      end
    end,
  })
end

-- ============================================================================
-- Plugin Installation
-- ============================================================================

-- Install vim-plug if it doesn't exist
function M.install_vim_plug_if_needed()
  local autoload_dir = fn.expand("~/.vim/autoload")
  local plug_vim_path = fn.expand("~/.vim/autoload/plug.vim")
  
  if fn.filereadable(plug_vim_path) == 0 then
    local os_type = fn.has("unix")
    if os_type == 1 then
      local url = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
      fn.system("curl -fLo " .. plug_vim_path .. " --create-dirs " .. url)
      print("vim-plug installed successfully!")
    else
      print("vim-plug installation not supported on this platform")
      return false
    end
  end
  return true
end

-- ============================================================================
-- User Commands
-- ============================================================================

-- Create Fuzzy user command
api.nvim_create_user_command("Fuzzy", M.fuzzy_find, {})

M.install_vim_plug_if_needed()

return M
