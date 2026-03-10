local map = vim.keymap.set

-- Disable middle-mouse paste
map({"n","v","i","c"}, "<MiddleMouse>",   "<Nop>", { noremap = true })
map({"n","v","i","c"}, "<2-MiddleMouse>", "<Nop>", { noremap = true })

-- Clear search highlight
map("n", "<C-\\>", "<cmd>noh<CR>", { noremap = true })

-- Word / paragraph motion
map("n", "<C-Right>", "w",   { noremap = true })
map("n", "<C-Left>",  "b",   { noremap = true })
map("n", "<C-Up>",    "{",   { noremap = true })
map("n", "<C-Down>",  "}",   { noremap = true })

-- Home / End (go to first non-blank)
map("n", "<Home>", "^",        { noremap = true })
map("n", "<End>",  "$",        { noremap = true })
map("i", "<Home>", "<C-o>^",   { noremap = true })
map("i", "<End>",  "<C-o>$",   { noremap = true })

-- File explorer
map("n", "<M-e>", function() require("explorer").open() end, { noremap = true })

-- Page up/down
map("n", "<PageUp>",   "<C-f>", { noremap = true })
map("n", "<PageDown>", "<C-b>", { noremap = true })

-- Scroll other window
map("n", "<C-PageDown>", "<C-w>w<C-d><C-w>p", { noremap = true })
map("n", "<C-PageUp>",   "<C-w>w<C-u><C-w>p", { noremap = true })

-- Query replace (Emacs-style Alt+%)
map("n", "<M-%>", function() require("keymaps").query_replace(false) end, { noremap = true })
map("v", "<M-%>", function() require("keymaps").query_replace(true)  end, { noremap = true })

-- Build
map("n", "<M-m>", function() require("build").make() end, { noremap = true })

-- Todo list
map("n", "<M-t>", function() require("todo").show() end, { noremap = true })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { noremap = true })
map("n", "<C-l>", "<C-w>l", { noremap = true })
map("n", "<C-j>", "<C-w>j", { noremap = true })
map("n", "<C-k>", "<C-w>k", { noremap = true })

-- Silence E486 on n/N when there's no active search
map("n", "n", function()
  local ok, err = pcall(function() vim.cmd("normal! n") end)
  if not ok and not err:match("E486") then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { noremap = true })

map("n", "N", function()
  local ok, err = pcall(function() vim.cmd("normal! N") end)
  if not ok and not err:match("E486") then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { noremap = true })

-- Expose helper for query_replace (called above)
local M = {}

function M.query_replace(visual)
  local search = vim.fn.input("Query replace: ")
  if search == "" then return end
  local replace = vim.fn.input("Replace with: ")
  local esc_s = vim.fn.escape(search,  "/")
  local esc_r = vim.fn.escape(replace, "/")
  if visual then
    vim.cmd("'<,'>s/" .. esc_s .. "/" .. esc_r .. "/gc")
  else
    vim.cmd("%s/" .. esc_s .. "/" .. esc_r .. "/gc")
  end
end

return M
