return {
  "shortcuts/no-neck-pain.nvim",
  config = function()
    local neck = require("no-neck-pain")
    vim.keymap.set('n', '<leader>np', neck.toggle, { desc = 'No Neck Pain Toggle' })
  end
}
