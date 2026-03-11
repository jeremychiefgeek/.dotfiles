-- lua/jeremy/config/todo.lua
-- Port of ShowTodoList: collects TODO/STUDY/IMPORTANT/NOTE into the quickfix
-- window.  <M-t> opens it; <CR> jumps, q closes.

local M = {}

local KEYWORDS = { "TODO", "STUDY", "IMPORTANT", "NOTE" }
local PATTERN  = table.concat(KEYWORDS, "\\|")

function M.show()
  local matches = {}
  local filepath = vim.fn.expand("%:p")
  local lines    = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for i, line in ipairs(lines) do
    if vim.fn.match(line, PATTERN) ~= -1 then
      table.insert(matches, {
        filename = filepath,
        lnum     = i,
        text     = vim.fn.trim(line),
      })
    end
  end

  if vim.tbl_isempty(matches) then
    print("No TODOs found.")
    return
  end

  vim.fn.setqflist(matches)
  vim.cmd("copen")

  -- Buffer-local mappings inside the quickfix window
  local qf_buf = vim.api.nvim_get_current_buf()
  vim.keymap.set("n", "<CR>", "<CR><Cmd>cclose<CR>", { buffer = qf_buf, nowait = true })
  vim.keymap.set("n", "q",    "<Cmd>cclose<CR>",     { buffer = qf_buf, nowait = true })
end

return M
