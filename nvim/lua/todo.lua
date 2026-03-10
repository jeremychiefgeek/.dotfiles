local M = {}

function M.show()
  local keywords = { "TODO", "STUDY", "IMPORTANT", "NOTE" }
  local pattern  = table.concat(keywords, "\\|")
  local matches  = {}
  local lines    = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local filepath  = vim.api.nvim_buf_get_name(0)

  for i, line in ipairs(lines) do
    if line:find(table.concat(keywords, "|"):gsub("|", "%%|")) or
       line:match("TODO") or line:match("STUDY") or
       line:match("IMPORTANT") or line:match("NOTE") then
      table.insert(matches, { filename = filepath, lnum = i, text = vim.trim(line) })
    end
  end

  if #matches == 0 then
    print("No TODOs found.")
    return
  end

  vim.fn.setqflist(matches)
  vim.cmd("copen")

  -- Close on Enter or q
  local buf = vim.api.nvim_get_current_buf()
  vim.keymap.set("n", "<CR>", "<CR><cmd>cclose<CR>", { buffer = buf, noremap = true })
  vim.keymap.set("n", "q",    "<cmd>cclose<CR>",      { buffer = buf, noremap = true })
end

return M
