-- init.lua
-- Bootstrap lazy.nvim, then load Jeremy's config modules.

-- ── Bootstrap lazy.nvim ──────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader must be set before plugins load so lazy mappings pick it up.
vim.g.mapleader = " "

-- ── Config modules ───────────────────────────────────────────────────────────
require("jeremy.config.options")
require("jeremy.config.keymaps")
require("jeremy.config.autocmds")
require("jeremy.config.build")
require("jeremy.config.todo")

-- ── Plugins (minimal — no LSP/intellisense) ──────────────────────────────────
require("lazy").setup("jeremy.plugins", {
  change_detection = { notify = false },
  ui = { border = "rounded" },
})

-- Start the Plugins that need to be started
require('lualine').setup({
  options = {
    globalstatus = true, -- Ensures each window has its own statusline
    -- Other options...
  },
})

-- ── Colorscheme ──────────────────────────────────────────────────────────────
-- colors/compline.lua is on the rtp via the nvim config root.
vim.cmd.colorscheme("compline")
