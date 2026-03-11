-- lua/jeremy/config/build.lua
-- Port of MakeWithoutAsking / compilation-directory helpers.

local M = {}

M.locked    = false
M.last_dir  = ""

local function find_project_dir()
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then dir = vim.fn.getcwd() end
  local script = vim.g.jeremy_makescript

  while true do
    if vim.fn.filereadable(dir .. "/" .. script) == 1 then
      vim.cmd("cd " .. vim.fn.fnameescape(dir))
      return true
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then return false end
    dir = parent
  end
end

function M.lock()
  M.locked = true
  print("Compilation directory is locked.")
end

function M.unlock()
  M.locked = false
  print("Compilation directory is roaming.")
end

function M.make()
  local start_dir = vim.fn.getcwd()

  if M.locked then
    vim.cmd("cd " .. vim.fn.fnameescape(M.last_dir))
  else
    find_project_dir()
    M.last_dir = vim.fn.getcwd()
  end

  local cwd = vim.fn.getcwd()
  local cmd
  if vim.g.jeremy_win32 then
    cmd = "cmd /c " .. cwd .. "\\" .. vim.g.jeremy_makescript
  else
    cmd = "cd " .. vim.fn.shellescape(cwd) .. " && " .. vim.g.jeremy_makescript
  end

  local output = vim.fn.system(cmd)
  print(output)

  vim.cmd("cd " .. vim.fn.fnameescape(start_dir))
  vim.cmd("wincmd p")
end

return M
