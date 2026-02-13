return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      open_mapping = [[<c-\>]],
      direction = "float",
      start_in_insert = true,
      close_on_exit = true,
      shade_terminals = false,

      float_opts = {
        border = "rounded",
        winblend = 0,
        width = function()
          return math.floor(vim.o.columns * 0.9)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.85)
        end,
      },
    })
  end,
}
