return {
  { 
    'nvim-mini/mini.files', 
    version = false,
    config = function()
      require("mini.files").setup()
      vim.keymap.set("n", "-", function() require("mini.files").open(vim.fn.expand("%:p:h")) end)
    end,
  },
}
