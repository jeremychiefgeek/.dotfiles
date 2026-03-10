local o = vim.opt

-- Editor
o.number         = true
o.relativenumber = true
o.expandtab      = true
o.tabstop        = 2
o.shiftwidth     = 4
o.softtabstop    = 2
o.clipboard      = "unnamed"
o.swapfile       = false
o.backup         = false
o.writebackup    = false
o.errorbells     = false
o.wrap           = false
o.scrolloff      = 3
o.display:append("lastline")
o.splitright = true
o.splitbelow = true

-- Undo
o.undolevels  = 10000
o.undoreload  = 100000

-- Search
o.hlsearch  = true
o.incsearch = true

-- GUI
o.guioptions:remove({ "T", "m", "r", "L" })
o.termguicolors = true

-- Cursor shape: block in normal, bar in insert, underline in replace
o.guicursor = "n-v-c:block-Cursor,i:ver25-Cursor,r:hor20-Cursor"

-- Font (GUI only)
if vim.fn.has("gui_running") == 1 then
  if vim.fn.has("win32") == 1 then
    o.guifont = "LiterationMono Nerd Font Mono:h12"
  else
    o.guifont = "LiterationMono Nerd Font Mono 12"
  end
end

-- Mouse wheel — scroll 15 lines at a time
-- (Neovim uses mousescroll, available since 0.8)
o.mousescroll = "ver:15,hor:0"

-- Matchparen (disable the built-in plugin)
vim.g.loaded_matchparen = 1

-- Leader
vim.g.mapleader = " "

-- OS detection
vim.g.jeremy_win32 = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
vim.g.jeremy_linux = vim.fn.has("unix") == 1 and vim.fn.has("mac") == 0
vim.g.jeremy_mac   = vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1

vim.g.jeremy_makescript = vim.g.jeremy_win32 and "build.bat" or "make"
