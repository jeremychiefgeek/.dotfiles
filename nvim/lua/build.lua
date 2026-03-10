local M = {}

vim.g.compilation_directory_locked = false
vim.g.last_compilation_directory   = ""

local function find_project_dir()
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then dir = vim.fn.getcwd() end
  while true do
    if vim.loop.fs_stat(dir .. "/" .. vim.g.jeremy_makescript) then
      vim.cmd("cd " .. vim.fn.fnameescape(dir))
      return true
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then return false end
    dir = parent
  end
end

function M.lock()
  vim.g.compilation_directory_locked = true
  print("Compilation directory is locked.")
end

function M.unlock()
  vim.g.compilation_directory_locked = false
  print("Compilation directory is roaming.")
end

function M.make()
  local start_dir = vim.fn.getcwd()
  if vim.g.compilation_directory_locked then
    vim.cmd("cd " .. vim.fn.fnameescape(vim.g.last_compilation_directory))
  else
    find_project_dir()
    vim.g.last_compilation_directory = vim.fn.getcwd()
  end
  local script = vim.fn.getcwd() .. (vim.g.jeremy_win32 and "\\" or "/") .. vim.g.jeremy_makescript
  local cmd    = vim.g.jeremy_win32 and ("cmd /c " .. script) or script
  local output = vim.fn.system(cmd)
  print(output)
  vim.cmd("cd " .. vim.fn.fnameescape(start_dir))
  vim.cmd("wincmd p")
end

return M
