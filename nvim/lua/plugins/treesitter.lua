return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    branch = "master",
    lazy = false,
    config = function()
      local config = require("nvim-treesitter")
      config.setup({
        auto_install = true,
        ensure_installed = {
          "bash",
          "html",
          "css",
          "scss",
          "javascript",
          "typescript",
          "json",
          "lua",
          "c_sharp",
          "c",
          "cpp",
          "zig",
          "python",
          "markdown",
        },
        highlight = { enable = true },
        indent = { enable = false },
        folds = { enable = true },
      })
    end,
  },
}
-- return {
--   {
--     "nvim-treesitter/nvim-treesitter",
--     lazy = false,
--     priority = 1000,
--     build = ":TSUpdate",
--
--     config = function()
--       -- New rewrite entrypoint
--       require("nvim-treesitter").setup({})
--
--       -- Enable Treesitter highlighting per-buffer
--       vim.api.nvim_create_autocmd("FileType", {
--         pattern = "*",
--         callback = function()
--           pcall(vim.treesitter.start)
--         end,
--       })
--
--       -- Optional helper: run this only when YOU want to install/update parsers
--       vim.api.nvim_create_user_command("TSEnsure", function()
--         require("nvim-treesitter").install({
--           "bash",
--           "html",
--           "css",
--           "scss",
--           "javascript",
--           "typescript",
--           "json",
--           "lua",
--           "c_sharp",
--           "c",
--           "cpp",
--           "zig",
--           "python",
--           "markdown",
--           "markdown_inline",
--           "vim",
--           "vimdoc",
--           "sh",
--         })
--       end, { desc = "Install/update configured Treesitter parsers" })
--     end,
--   },
-- }
