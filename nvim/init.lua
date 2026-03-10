require("options")
require("keymaps")
require("autocmds")
require("build")
require("todo")

-- Open explorer at current file's directory
-- vim.keymap.set("n", "<M-E>", function()
--   require("explorer").open(vim.fn.expand("%:p:h"))
-- end, { noremap = true })


-- ── Plugins ───────────────────────────────────────────────────────────────────
require("pack").setup({
  -- Add plugins here as "author/repo", e.g.:
  -- "nvim-lua/plenary.nvim",
  "kdheepak/lazygit.nvim",
})


-- Theme (place compline.lua in ~/.config/nvim/lua/colors/ and load via:)
vim.cmd("colorscheme compline")
