-- lua/jeremy/plugins/init.lua
-- Minimal plugin list.  No LSP, no autocomplete — just quality-of-life picks
-- that replace nothing from the vimrc but add what Vim builtins can't do.

return {

  -- ── Treesitter: better syntax highlighting (no LSP) ──────────────────────
  -- The main branch removed nvim-treesitter.configs; highlighting is now
  -- wired up via a FileType autocmd calling vim.treesitter.start().
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy   = false,
    build  = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup({
        ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc" },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern  = { "c", "cpp", "lua", "vim" },
        callback = function() pcall(vim.treesitter.start) end,
      })
    end,
  },

}
