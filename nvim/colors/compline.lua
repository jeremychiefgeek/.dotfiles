-- ~/.config/nvim/colors/compline.lua
-- Drop the .vim file and use this instead.

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
vim.g.colors_name = "compline"
vim.o.background  = "dark"

local p = {
  bg         = "#1a1d21", bg_alt = "#22262b",
  base0      = "#0f1114", base1  = "#171a1e", base2  = "#1f2228",
  base3      = "#282c34", base4  = "#3d424a", base5  = "#515761",
  base6      = "#676d77", base7  = "#8b919a", base8  = "#e0dcd4",
  fg         = "#f0efeb", fg_alt = "#ccc4b4",
  red        = "#CDACAC", orange = "#ccc4b4", green  = "#b8c4b8",
  blue       = "#b4bcc4", yellow = "#d4ccb4", teal   = "#b4c4bc",
  dark_blue  = "#9ca4ac", cyan   = "#b4c0c8", dark_cyan = "#98a4ac",
  violet     = "#8b919a", magenta = "#8b919a",
}

local function hi(group, fg, bg, attr)
  local def = {}
  if fg   and fg   ~= "" then def.fg    = fg   end
  if bg   and bg   ~= "" then def.bg    = bg   end
  if attr and attr ~= "" then
    for _, a in ipairs(vim.split(attr, ",")) do
      def[a] = true
    end
  end
  vim.api.nvim_set_hl(0, group, def)
end

-- Core
hi("Normal",       p.fg,      p.bg,     "")
hi("Cursor",       p.bg,      p.fg,     "")
hi("CursorLine",   "",        p.base3,  "")
hi("CursorColumn", "",        p.base3,  "")
hi("ColorColumn",  "",        p.base2,  "")
hi("SignColumn",   p.base4,   p.bg,     "")
hi("Folded",       p.base6,   p.base2,  "")
hi("FoldColumn",   p.base4,   p.bg,     "")
hi("VertSplit",    p.base2,   p.base2,  "")
hi("LineNr",       p.base4,   "",       "")
hi("CursorLineNr", p.fg,      "",       "")
hi("NonText",      p.base3,   "",       "")
hi("SpecialKey",   p.base3,   "",       "")
hi("Conceal",      p.base5,   "",       "")
hi("Directory",    p.blue,    "",       "bold")
hi("Title",        p.fg,      "",       "bold")
hi("MatchParen",   "",        p.base4,  "bold")

-- Selection / Search
hi("Visual",       "",        p.base4,  "")
hi("VisualNOS",    "",        p.base4,  "")
hi("Search",       p.bg,      p.yellow, "bold")
hi("IncSearch",    p.bg,      p.yellow, "bold")

-- Messages / UI
hi("ErrorMsg",     p.red,     "",       "bold")
hi("WarningMsg",   p.yellow,  "",       "bold")
hi("ModeMsg",      p.fg,      "",       "bold")
hi("MoreMsg",      p.green,   "",       "bold")
hi("Question",     p.yellow,  "",       "bold")
hi("Pmenu",        p.fg,      p.base2,  "")
hi("PmenuSel",     p.bg,      p.cyan,   "")
hi("PmenuSbar",    "",        p.base3,  "")
hi("PmenuThumb",   "",        p.base6,  "")
hi("WildMenu",     p.bg,      p.yellow, "bold")
hi("StatusLine",   p.fg,      p.base1,  "")
hi("StatusLineNC", p.base5,   p.base2,  "")
hi("TabLine",      p.base6,   p.base1,  "")
hi("TabLineSel",   p.fg,      p.bg,     "bold")
hi("TabLineFill",  "",        p.base1,  "")

-- Syntax
hi("Comment",      p.base4,   "",       "italic")
hi("Constant",     p.base7,   "",       "")
hi("String",       p.green,   "",       "")
hi("Character",    p.green,   "",       "")
hi("Number",       p.red,     "",       "")
hi("Boolean",      p.base7,   "",       "")
hi("Float",        p.red,     "",       "")
hi("Identifier",   p.base8,   "",       "")
hi("Function",     p.cyan,    "",       "")
hi("Statement",    p.base8,   "",       "bold")
hi("Conditional",  p.base8,   "",       "bold")
hi("Repeat",       p.base8,   "",       "bold")
hi("Label",        p.base8,   "",       "bold")
hi("Operator",     p.base6,   "",       "")
hi("Keyword",      p.base8,   "",       "bold")
hi("Exception",    p.base8,   "",       "bold")
hi("PreProc",      p.base7,   "",       "")
hi("Include",      p.base7,   "",       "")
hi("Define",       p.base7,   "",       "")
hi("Macro",        p.base7,   "",       "")
hi("PreCondit",    p.base7,   "",       "")
hi("Type",         p.blue,    "",       "")
hi("StorageClass", p.blue,    "",       "")
hi("Structure",    p.blue,    "",       "")
hi("Typedef",      p.blue,    "",       "")
hi("Special",      p.cyan,    "",       "")
hi("SpecialChar",  p.yellow,  "",       "")
hi("Tag",          p.cyan,    "",       "")
hi("Delimiter",    p.base6,   "",       "")
hi("SpecialComment",p.base4,  "",       "italic")
hi("Debug",        p.red,     "",       "")
hi("Underlined",   p.blue,    "",       "underline")
hi("Ignore",       p.base5,   "",       "")
hi("Error",        p.red,     "",       "bold")
hi("Todo",         p.red,     "",       "bold,italic")

-- Diff
hi("DiffAdd",      p.green,   "#1a231a","")
hi("DiffDelete",   p.red,     "#231a1a","")
hi("DiffChange",   p.orange,  "#23211a","")
hi("DiffText",     p.bg,      p.green,  "bold")

-- Spell
hi("SpellBad",     p.red,     "",       "undercurl")
hi("SpellCap",     p.yellow,  "",       "undercurl")
hi("SpellRare",    p.cyan,    "",       "undercurl")
hi("SpellLocal",   p.teal,    "",       "undercurl")

-- Links
vim.api.nvim_set_hl(0, "EndOfBuffer",  { link = "NonText"   })
vim.api.nvim_set_hl(0, "NormalFloat",  { link = "Pmenu"     })
vim.api.nvim_set_hl(0, "FloatBorder",  { link = "VertSplit" })
vim.api.nvim_set_hl(0, "QuickFixLine", { link = "Search"    })

-- Netrw
hi("netrwDir",      p.blue,   "", "bold")
hi("netrwSymLink",  p.teal,   "", "bold")
hi("netrwExe",      p.green,  "", "bold")
hi("netrwMakefile", p.yellow, "", "bold")

-- Terminal colours
vim.g.terminal_color_0  = p.bg;       vim.g.terminal_color_1  = p.red
vim.g.terminal_color_2  = p.green;    vim.g.terminal_color_3  = p.yellow
vim.g.terminal_color_4  = p.blue;     vim.g.terminal_color_5  = p.magenta
vim.g.terminal_color_6  = p.cyan;     vim.g.terminal_color_7  = p.base7
vim.g.terminal_color_8  = p.base4;    vim.g.terminal_color_9  = p.red
vim.g.terminal_color_10 = p.green;    vim.g.terminal_color_11 = p.yellow
vim.g.terminal_color_12 = p.dark_blue;vim.g.terminal_color_13 = p.violet
vim.g.terminal_color_14 = p.dark_cyan;vim.g.terminal_color_15 = p.fg
