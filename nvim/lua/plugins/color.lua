return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      vim.cmd("colorscheme rose-pine")
    end,
  },
  -- {
  --   "https://github.com/jeremychiefgeek/compline.nvim",
  --   priority = 1000,
  --   config = function()
  --     vim.cmd([[colorscheme compline]])
  --   end,
  -- },
  -- { "ellisonleao/gruvbox.nvim", priority = 1000, config = true, opts = ... },
  -- {
  --   "bjarneo/ash.nvim",
  --   priority = 1000,
  --   config = function()
  --     vim.cmd([[colorscheme ash]])
  --   end,
  -- },
  -- {
  --   "blazkowolf/gruber-darker.nvim",
  --   priority = 1000,
  --   config = function()
  --     vim.cmd([[colorscheme gruber-darker]])
  --   end,
  -- },
}
