-- colors/compline.lua
-- "Be at peace with the darkness"
-- Original Emacs theme: joshuablais <https://github.com/jblais493>
-- Ported from compline-theme.el → compline.vim → compline.lua (Neovim)

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.g.colors_name = "compline"
vim.o.background  = "dark"

-- ── Palette ──────────────────────────────────────────────────────────────────
local p = {
  -- Background scale
  bg         = "#1a1d21",
  bg_alt     = "#22262b",
  base0      = "#0f1114",
  base1      = "#171a1e",
  base2      = "#1f2228",
  base3      = "#282c34",
  base4      = "#3d424a",
  base5      = "#515761",
  base6      = "#676d77",
  base7      = "#8b919a",
  base8      = "#e0dcd4",
  fg         = "#f0efeb",
  fg_alt     = "#ccc4b4",
  -- Named colours
  red        = "#CDACAC",
  orange     = "#ccc4b4",
  green      = "#b8c4b8",
  blue       = "#b4bcc4",
  yellow     = "#d4ccb4",
  teal       = "#b4c4bc",
  dark_blue  = "#9ca4ac",
  cyan       = "#b4c0c8",
  dark_cyan  = "#98a4ac",
  violet     = "#8b919a",
  magenta    = "#8b919a",
}

-- Semantic aliases
local c = {
  highlight  = p.yellow,
  selection  = p.base4,
  builtin    = p.cyan,
  comments   = p.base4,
  constants  = p.base7,
  functions  = p.cyan,
  keywords   = p.base8,
  methods    = p.dark_cyan,
  operators  = p.base6,
  type       = p.blue,
  strings    = p.green,
  variables  = p.base8,
  numbers    = p.red,
  error      = p.red,
  warning    = p.yellow,
  success    = p.green,

  modeline_bg          = p.base1,
  modeline_bg_inactive = p.base2,
  modeline_fg          = p.fg,
  modeline_fg_alt      = p.base5,
}

-- ── Helper ───────────────────────────────────────────────────────────────────
local function hi(group, opts)
  -- opts: fg, bg, bold, italic, underline, undercurl, link
  if opts.link then
    vim.api.nvim_set_hl(0, group, { link = opts.link })
    return
  end
  local def = {}
  if opts.fg         then def.fg        = opts.fg         end
  if opts.bg         then def.bg        = opts.bg         end
  if opts.bold       then def.bold      = true            end
  if opts.italic     then def.italic    = true            end
  if opts.underline  then def.underline = true            end
  if opts.undercurl  then def.undercurl = true            end
  if opts.nocombine  then def.nocombine = true            end
  vim.api.nvim_set_hl(0, group, def)
end

-- ── Core ─────────────────────────────────────────────────────────────────────
hi("Normal",         { fg = p.fg,     bg = p.bg })
hi("Cursor",         { fg = p.bg,     bg = p.fg })
hi("CursorLine",     { bg = p.base3 })
hi("CursorColumn",   { bg = p.base3 })
hi("ColorColumn",    { bg = p.base2 })
hi("SignColumn",     { fg = p.base4,  bg = p.bg })
hi("Folded",         { fg = p.base6,  bg = p.base2 })
hi("FoldColumn",     { fg = p.base4,  bg = p.bg })
hi("VertSplit",      { fg = p.base2,  bg = p.base2 })
hi("WinSeparator",   { fg = p.base2,  bg = p.base2 })  -- Neovim alias
hi("LineNr",         { fg = p.base4 })
hi("CursorLineNr",   { fg = p.fg })
hi("NonText",        { fg = p.base3 })
hi("SpecialKey",     { fg = p.base3 })
hi("Conceal",        { fg = p.base5 })
hi("Directory",      { fg = p.blue,   bold = true })
hi("Title",          { fg = p.fg,     bold = true })
hi("MatchParen",     { bg = p.base4,  bold = true })

-- ── Selection / Search ───────────────────────────────────────────────────────
hi("Visual",         { bg = c.selection })
hi("VisualNOS",      { bg = c.selection })
hi("Search",         { fg = p.bg,     bg = p.yellow, bold = true })
hi("IncSearch",      { fg = p.bg,     bg = p.yellow, bold = true })
hi("CurSearch",      { fg = p.bg,     bg = p.yellow, bold = true })

-- ── Messages / UI ────────────────────────────────────────────────────────────
hi("ErrorMsg",       { fg = c.error,   bold = true })
hi("WarningMsg",     { fg = c.warning, bold = true })
hi("ModeMsg",        { fg = p.fg,      bold = true })
hi("MoreMsg",        { fg = p.green,   bold = true })
hi("Question",       { fg = p.yellow,  bold = true })
hi("Pmenu",          { fg = p.fg,      bg = p.base2 })
hi("PmenuSel",       { fg = p.bg,      bg = p.cyan })
hi("PmenuSbar",      { bg = p.base3 })
hi("PmenuThumb",     { bg = p.base6 })
hi("WildMenu",       { fg = p.bg,      bg = p.yellow, bold = true })
hi("StatusLine",     { fg = c.modeline_fg,     bg = c.modeline_bg })
hi("StatusLineNC",   { fg = c.modeline_fg_alt, bg = c.modeline_bg_inactive })
hi("TabLine",        { fg = p.base6,   bg = p.base1 })
hi("TabLineSel",     { fg = p.fg,      bg = p.bg,   bold = true })
hi("TabLineFill",    { bg = p.base1 })

-- ── Syntax ───────────────────────────────────────────────────────────────────
hi("Comment",        { fg = c.comments,  italic = true })
hi("Constant",       { fg = c.constants })
hi("String",         { fg = c.strings })
hi("Character",      { fg = c.strings })
hi("Number",         { fg = c.numbers })
hi("Boolean",        { fg = c.constants })
hi("Float",          { fg = c.numbers })
hi("Identifier",     { fg = c.variables })
hi("Function",       { fg = c.functions })
hi("Statement",      { fg = c.keywords,  bold = true })
hi("Conditional",    { fg = c.keywords,  bold = true })
hi("Repeat",         { fg = c.keywords,  bold = true })
hi("Label",          { fg = c.keywords,  bold = true })
hi("Operator",       { fg = c.operators })
hi("Keyword",        { fg = c.keywords,  bold = true })
hi("Exception",      { fg = c.keywords,  bold = true })
hi("PreProc",        { fg = p.base7 })
hi("Include",        { fg = p.base7 })
hi("Define",         { fg = p.base7 })
hi("Macro",          { fg = p.base7 })
hi("PreCondit",      { fg = p.base7 })
hi("Type",           { fg = c.type })
hi("StorageClass",   { fg = c.type })
hi("Structure",      { fg = c.type })
hi("Typedef",        { fg = c.type })
hi("Special",        { fg = p.cyan })
hi("SpecialChar",    { fg = p.yellow })
hi("Tag",            { fg = p.cyan })
hi("Delimiter",      { fg = p.base6 })
hi("SpecialComment", { fg = c.comments, italic = true })
hi("Debug",          { fg = p.red })
hi("Underlined",     { fg = p.blue,  underline = true })
hi("Ignore",         { fg = p.base5 })
hi("Error",          { fg = c.error, bold = true })
hi("Todo",           { fg = p.red,   bold = true, italic = true })

-- ── Diff ─────────────────────────────────────────────────────────────────────
hi("DiffAdd",        { fg = p.green,  bg = "#1a231a" })
hi("DiffDelete",     { fg = p.red,    bg = "#231a1a" })
hi("DiffChange",     { fg = p.orange, bg = "#23211a" })
hi("DiffText",       { fg = p.bg,     bg = p.green,  bold = true })

-- ── Spell ────────────────────────────────────────────────────────────────────
hi("SpellBad",       { fg = p.red,    undercurl = true })
hi("SpellCap",       { fg = p.yellow, undercurl = true })
hi("SpellRare",      { fg = p.cyan,   undercurl = true })
hi("SpellLocal",     { fg = p.teal,   undercurl = true })

-- ── Links ────────────────────────────────────────────────────────────────────
hi("EndOfBuffer",    { link = "NonText" })
hi("NormalFloat",    { link = "Pmenu" })
hi("FloatBorder",    { link = "WinSeparator" })
hi("QuickFixLine",   { link = "Search" })

-- ── Netrw (mirrors dired) ─────────────────────────────────────────────────────
hi("netrwDir",       { fg = p.blue,   bold = true })
hi("netrwSymLink",   { fg = p.teal,   bold = true })
hi("netrwExe",       { fg = p.green,  bold = true })
hi("netrwMakefile",  { fg = p.yellow, bold = true })

-- ── Terminal colours ─────────────────────────────────────────────────────────
vim.g.terminal_color_0  = p.bg
vim.g.terminal_color_1  = p.red
vim.g.terminal_color_2  = p.green
vim.g.terminal_color_3  = p.yellow
vim.g.terminal_color_4  = p.blue
vim.g.terminal_color_5  = p.magenta
vim.g.terminal_color_6  = p.cyan
vim.g.terminal_color_7  = p.base7
vim.g.terminal_color_8  = p.base4
vim.g.terminal_color_9  = p.red
vim.g.terminal_color_10 = p.green
vim.g.terminal_color_11 = p.yellow
vim.g.terminal_color_12 = p.dark_blue
vim.g.terminal_color_13 = p.violet
vim.g.terminal_color_14 = p.dark_cyan
vim.g.terminal_color_15 = p.fg
