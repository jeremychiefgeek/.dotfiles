-- lua/jeremy/config/keymaps.lua
-- Faithful port of all key bindings from vimrc.

local map = vim.keymap.set

-- ── Middle-mouse paste disabled ──────────────────────────────────────────────
map({ "n", "v", "i" }, "<MiddleMouse>",   "<Nop>")
map({ "n", "v", "i" }, "<2-MiddleMouse>", "<Nop>")

-- ── Clear search highlight ───────────────────────────────────────────────────
map("n", "<C-\\>", "<Cmd>noh<CR>")

-- ── Window navigation ────────────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")

-- ── Keep visual selection after indent ───────────────────────────────────────
map("v", ">", ">gv")
map("v", "<", "<gv")

-- ── Basic Window Commands ───────────────────────────────────────
map("n", "<C-q>", "<Cmd>q<CR>")
map("n", "<C-s>", "<Cmd>w<CR>")

-- ── Word / paragraph motion ──────────────────────────────────────────────────
map("n", "<C-Right>", "w")
map("n", "<C-Left>",  "b")
map("n", "<C-Up>",    "{")
map("n", "<C-Down>",  "}")

-- ── Home / End go to first non-blank ─────────────────────────────────────────
map("n", "<Home>", "^")
map("n", "<End>",  "$")
map("i", "<Home>", "<C-o>^")
map("i", "<End>",  "<C-o>$")

-- ── Page up/down ─────────────────────────────────────────────────────────────
map("n", "<PageDown>",   "<C-f>")
map("n", "<PageUp>",     "<C-b>")

-- Scroll other window half-page
map("n", "<C-PageDown>", "<C-w>w<C-d><C-w>p")
map("n", "<C-PageUp>",   "<C-w>w<C-u><C-w>p")

-- ── Build ────────────────────────────────────────────────────────────────────
map("n", "<M-m>", function() require("jeremy.config.build").make() end)

-- ── Todo list ────────────────────────────────────────────────────────────────
map("n", "<M-t>", function() require("jeremy.config.todo").show() end)

-- ── Query replace (Emacs-style) ───────────────────────────────────────────────
local function query_replace(visual)
  local search  = vim.fn.input("Query replace: ")
  if search == "" then return end
  local replace = vim.fn.input("Replace with: ")
  local range   = visual and "'<,'>" or "%"
  vim.cmd(range .. "s/" .. vim.fn.escape(search, "/") .. "/" .. vim.fn.escape(replace, "/") .. "/gc")
end

map("n", "<M-%>", function() query_replace(false) end)
map("v", "<M-%>", function() query_replace(true)  end)

-- ── Mouse wheel fallback (Neovim < 0.10) ─────────────────────────────────────
if vim.fn.has("nvim-0.10") == 0 then
  map({ "n", "v" }, "<ScrollWheelUp>",   "15<C-y>")
  map({ "n", "v" }, "<ScrollWheelDown>", "15<C-e>")
  map("i", "<ScrollWheelUp>",   "<C-o>15<C-y>")
  map("i", "<ScrollWheelDown>", "<C-o>15<C-e>")
end
