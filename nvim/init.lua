-- bootstrap lazy.nvim, LazyVim and your plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("vim-options")
require("config")
require("lazy").setup("plugins")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Debug: print the current file path
    local current_file = vim.fn.expand("%:p")
    local notebook = require("zk.util").notebook_root(current_file)
    if notebook ~= nil then
      local function map(...)
        vim.api.nvim_buf_set_keymap(0, ...)
      end
      local opts = { noremap = true, silent = false }
      map("n", "<CR>", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
    end
  end,
})

if vim.g.neovide then
  -- Put anything you want to happen only in Neovide here
  vim.g.neovide_cursor_animation_length = 0
end
