-- lua/jeremy/config/options.lua
-- Direct port of the generic editor options from vimrc.

local opt = vim.opt

-- ── Generic editor ───────────────────────────────────────────────────────────
opt.number         = true
opt.relativenumber = true
opt.expandtab      = true
opt.tabstop        = 2
opt.shiftwidth     = 2
opt.softtabstop    = 2
opt.clipboard      = "unnamed"
opt.swapfile       = false
opt.belloff        = "all"
opt.undolevels     = 10000
opt.undoreload     = 100000
opt.splitright     = true
opt.splitbelow     = true

-- Disable matchparen highlight (let loaded_matchparen = 1)
vim.g.loaded_matchparen = 1

-- ── Wildmenu / completion ────────────────────────────────────────────────────
opt.wildmenu  = true
opt.wildmode  = "longest:full,full"

-- ── UI chrome ────────────────────────────────────────────────────────────────
opt.laststatus = 2
opt.backspace  = "indent,eol,start"
opt.hlsearch   = true
opt.incsearch  = true
opt.wrap       = false
opt.display:append("lastline")
opt.backup         = false
opt.writebackup    = false
opt.errorbells     = false
opt.scrolloff      = 3

-- ── GUI chrome (gvim / neovide / etc.) ───────────────────────────────────────
-- Mirrors guioptions-=T/m/r/L
opt.guioptions:remove({ "T", "m", "r", "L" })

-- ── GUI font ─────────────────────────────────────────────────────────────────
-- Windows uses colon syntax for Neovim's guifont.
if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
  opt.guifont = "LiterationMono Nerd Font Mono:h12"
else
  opt.guifont = "LiterationMono Nerd Font Mono:h12"
end

-- ── Cursor shapes ────────────────────────────────────────────────────────────
opt.guicursor = "n-v-c:block,i:ver25,r:hor20"

-- ── Mouse wheel — scroll 15 lines at a time ──────────────────────────────────
-- Neovim 0.10+ supports mousescroll directly.
-- For older builds the keymaps in keymaps.lua handle it.
if vim.fn.has("nvim-0.10") == 1 then
  opt.mousescroll = "ver:15,hor:0"
end

-- ── OS detection flags (used by build.lua) ───────────────────────────────────
vim.g.jeremy_win32  = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
vim.g.jeremy_linux  = vim.fn.has("unix") == 1 and vim.fn.has("mac") == 0
vim.g.jeremy_mac    = vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1
vim.g.jeremy_makescript = vim.g.jeremy_win32 and "build.bat" or "make"
