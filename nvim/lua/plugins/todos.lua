return {
  -- {
  --   "leon-richardt/comment-highlights.nvim",
  --   dependencies = { "nvim-treesitter/nvim-treesitter" },
  --   opts = {},
  --   cmd = "CHToggle",
  --   keys = {
  --     {
  --       "<leader>cc",
  --       function()
  --         require("comment-highlights").toggle()
  --       end,
  --       desc = "Toggle comment highlighting",
  --     },
  --   },
  -- },
  -- NOTE(jeremy): Wtf
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    highlight = {
      pattern = [[.*\<(KEYWORDS)\%(([^)]\+)\)\?:]],
    },
    search = {
      pattern = [[\b(KEYWORDS)\%(([^)]\+)\)\?:]],
    },
  },
}
