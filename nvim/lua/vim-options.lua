vim.opt.number = true
vim.opt.relativenumber = true
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "
vim.opt.clipboard = "unnamedplus"

vim.keymap.set("n", "<C-/>", ":noh<CR>")

vim.opt.swapfile = false

-- Navigate vim panes better
vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")
vim.keymap.set("i", "jk", "<ESC>", {})

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

-- How I think behavior should work naturally
vim.api.nvim_set_keymap("v", ">", ">gv", { noremap = true })
vim.api.nvim_set_keymap("v", "<", "<gv", { noremap = true })

-- Window pane management
vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>wh", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>we", "<C-w>=", { desc = "Make splits equal size" })
vim.keymap.set("n", "<leader>wc", "<cmd>close<CR>", { desc = "Close current split" })
vim.keymap.set("n", "<leader>wo", "<C-w>o", { desc = "Close all other splits" })

-- Resize with arrows
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Tab management
vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close current tab" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- This centers code: Rember your posture
vim.keymap.set("n", "zz", function()
  local offset = math.floor(vim.fn.winheight(0) / 4)
  return "zt" .. offset .. "<C-y>"
end, { expr = true })

-- ZEN
vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<CR>", { desc = "Toggle Zen Mode" })

local opts = { noremap = true, silent = false }

-- Open notes (uses Telescope, opens to the right)
vim.keymap.set("n", "<leader>nn", function()
  local title = vim.fn.input("Title: ")
  vim.cmd("ZkNew { title = '" .. title .. "' }")
end, opts)

-- Open notes associated with the selected tags (uses Telescope, opens to the right)
vim.keymap.set("n", "<leader>tn", function()
  vim.cmd("ZkTags")
end, opts)

-- Search for notes matching a given query (uses Telescope, opens to the right)
vim.keymap.set("n", "<leader>fn", function()
  vim.cmd("ZkNotes { sort = { 'modified' } }")
end, opts)

vim.keymap.set("n", "<leader>fmn", function()
  vim.cmd("ZkNotes { sort = { 'modified' } }")
end, opts)

vim.keymap.set("n", "<leader>nmn", function()
  local title = vim.fn.input("Title: ")
  vim.cmd("ZkNew { title = '" .. title .. "' }")
end, opts)

-- Search for notes matching the current visual selection (uses Telescope, opens to the right)
vim.keymap.set("v", "<leader>fn", function()
  vim.cmd("'<,'>ZkMatch")
  -- FIXME: These need to do it only if selected
end, opts)
vim.keymap.set("v", "<leader>fmn", function()
  vim.cmd("'<,'>ZkMatch", { match = { "type: meeting" }, sort = { "modified" } })
  -- FIXME: These need to do it only if selected
end, opts)

-- NOICE
vim.keymap.set("n", "<leader>le", function()
  require("noice").cmd("last")
end)

vim.keymap.set("n", "<leader>eh", function()
  require("noice").cmd("history")
end)

-- Mini.files
vim.keymap.set("n", "-", function()
  require("mini.files").open(vim.uv.cwd(), true)
end, { desc = "Open mini.files (current working directory)" })
