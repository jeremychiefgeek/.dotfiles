return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      options = {
        -- "buffers" is the default; "tabs" shows tabpages instead :contentReference[oaicite:1]{index=1}
        mode = "buffers",

        -- show LSP diagnostic indicators in the tabline :contentReference[oaicite:2]{index=2}
        diagnostics = "nvim_lsp",

        -- make neo-tree/sidebars not overlap the bufferline
        offsets = {
          {
            filetype = "neo-tree",
            text = "Explorer",
            highlight = "Directory",
            separator = true,
          },
        },

        -- nice QoL defaults
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = false,
        separator_style = "slant",
      },
    },
    config = function(_, opts)
      vim.opt.termguicolors = true -- required for bufferline colors :contentReference[oaicite:3]{index=3}
      require("bufferline").setup(opts)

      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
      end

      -- “easy tab navigation”
      map("L", "<cmd>BufferLineCycleNext<cr>", "Next buffer")
      map("H", "<cmd>BufferLineCyclePrev<cr>", "Prev buffer")

      -- Jump to buffer by ordinal position (1..9)
      for i = 1, 9 do
        map("<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", "Go to buffer " .. i)
      end

      -- Pick mode (shows letters on buffers)
      map("<leader>bp", "<cmd>BufferLinePick<cr>", "Pick buffer")
      map("<leader>bd", "<cmd>BufferLinePickClose<cr>", "Pick close buffer")

      -- Common buffer management
      map("<leader>bo", "<cmd>BufferLineCloseOthers<cr>", "Close other buffers")
      map("<leader>br", "<cmd>BufferLineCloseRight<cr>", "Close buffers to the right")
      map("<leader>bl", "<cmd>BufferLineCloseLeft<cr>", "Close buffers to the left")
    end,
  },
}
