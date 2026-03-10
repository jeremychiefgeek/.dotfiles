return {
  { "nvim-mini/mini.files", version = false },
  { "nvim-mini/mini.comment", version = false },
  { "nvim-mini/mini.move", version = false },
  {
    "nvim-mini/mini.hipatterns",
    version = false,
    event = "BufReadPre",
    config = function()
      local hipatterns = require("mini.hipatterns")

      hipatterns.setup({
        highlighters = {
          fixme = {
            pattern = "%f[%w]FIXME%f[%W]",
            group = "MiniHipatternsFixme",
          },
          hack = {
            pattern = "%f[%w]HACK%f[%W]",
            group = "MiniHipatternsHack",
          },
          todo = {
            pattern = "%f[%w]TODO%f[%W]",
            group = "MiniHipatternsTodo",
          },
          note = {
            pattern = "%f[%w]NOTE%f[%W]",
            group = "MiniHipatternsNote",
          },

          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      })

      vim.api.nvim_set_hl(0, "MiniHipatternsFixme", { fg = "#ffffff", bg = "#ef4444", bold = true })
      vim.api.nvim_set_hl(0, "MiniHipatternsHack", { fg = "#000000", bg = "#f59e0b", bold = true })
      vim.api.nvim_set_hl(0, "MiniHipatternsTodo", { fg = "#ffffff", bg = "#0ea5e9", bold = true })
      vim.api.nvim_set_hl(0, "MiniHipatternsNote", { fg = "#000000", bg = "#22c55e", bold = true })
    end,
  },
}
