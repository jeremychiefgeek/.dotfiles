return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  config = function()
    local mc = require("multicursor-nvim")

    mc.setup()

    -- Add cursors above/below the main cursor
    vim.keymap.set({ "n", "v" }, "<up>", function()
      mc.lineAddCursor(-1)
    end)
    vim.keymap.set({ "n", "v" }, "<down>", function()
      mc.lineAddCursor(1)
    end)

    -- Add a cursor and jump to the next word under cursor
    vim.keymap.set({ "n", "v" }, "<c-n>", function()
      mc.matchAddCursor(1)
    end)

    -- Jump to the next word under cursor but do not add a cursor
    vim.keymap.set({ "n", "v" }, "<c-s>", function()
      mc.matchSkipCursor(1)
    end)

    -- Delete the main cursor
    vim.keymap.set({ "n", "v" }, "<leader>x", mc.deleteCursor)

    -- Add and remove cursors with control + left/right click
    vim.keymap.set("n", "<c-leftmouse>", mc.handleMouse)

    vim.keymap.set({ "n", "v" }, "<c-q>", function()
      if mc.cursorsEnabled() then
        mc.clearCursors()
      else
        mc.restoreCursors()
      end
    end)

    -- Align cursor columns
    vim.keymap.set("v", "<leader>a", mc.alignCursors)

    -- Escape clears cursors
    vim.keymap.set("n", "<esc>", function()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      elseif mc.hasCursors() then
        mc.clearCursors()
      end
    end)
  end,
}
