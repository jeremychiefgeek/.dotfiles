" compline.vim - Be at peace with the darkness
" Original: joshuablais <https://github.com/jblais493>
" Converted from compline-theme.el to Vim colorscheme
" Requires: Vim 8+ with termguicolors
"
" Usage:
"   1. Place in ~/.vim/colors/compline.vim
"   2. Add to your .vimrc:
"        set termguicolors
"        colorscheme compline

highlight clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "compline"
set background=dark

" -- Palette ----------------------------------------------------------------
" Background scale
let s:bg         = "#1a1d21"
let s:bg_alt     = "#22262b"
let s:base0      = "#0f1114"
let s:base1      = "#171a1e"
let s:base2      = "#1f2228"
let s:base3      = "#282c34"
let s:base4      = "#3d424a"
let s:base5      = "#515761"
let s:base6      = "#676d77"
let s:base7      = "#8b919a"
let s:base8      = "#e0dcd4"
let s:fg         = "#f0efeb"
let s:fg_alt     = "#ccc4b4"

" Named colours
let s:red        = "#CDACAC"
let s:orange     = "#ccc4b4"
let s:green      = "#b8c4b8"
let s:blue       = "#b4bcc4"
let s:yellow     = "#d4ccb4"
let s:teal       = "#b4c4bc"
let s:dark_blue  = "#9ca4ac"
let s:cyan       = "#b4c0c8"
let s:dark_cyan  = "#98a4ac"
let s:violet     = "#8b919a"
let s:magenta    = "#8b919a"

" Semantic aliases
let s:highlight  = s:yellow
let s:selection  = s:base4
let s:builtin    = s:cyan
let s:comments   = s:base4
let s:constants  = s:base7
let s:functions  = s:cyan
let s:keywords   = s:base8
let s:methods    = s:dark_cyan
let s:operators  = s:base6
let s:type       = s:blue
let s:strings    = s:green
let s:variables  = s:base8
let s:numbers    = s:red
let s:error      = s:red
let s:warning    = s:yellow
let s:success    = s:green

" Mode-line
let s:modeline_bg          = s:base1
let s:modeline_bg_inactive = s:base2
let s:modeline_fg          = s:fg
let s:modeline_fg_alt      = s:base5

" -- Helper -----------------------------------------------------------------
" s:hi(group, fg, bg, attr)  - pass "" to leave a field unset
function! s:hi(group, fg, bg, attr)
  let l:cmd = "highlight " . a:group
  if a:fg   != "" | let l:cmd .= " guifg=" . a:fg   | endif
  if a:bg   != "" | let l:cmd .= " guibg=" . a:bg   | endif
  if a:attr != "" | let l:cmd .= " gui="   . a:attr | endif
  exec l:cmd
endfunction

" -- Core -------------------------------------------------------------------
call s:hi("Normal",           s:fg,       s:bg,       "")
call s:hi("Cursor",           s:bg,       s:fg,       "")
call s:hi("CursorLine",       "",         s:base3,    "none")
call s:hi("CursorColumn",     "",         s:base3,    "none")
call s:hi("ColorColumn",      "",         s:base2,    "none")
call s:hi("SignColumn",       s:base4,    s:bg,       "none")
call s:hi("Folded",           s:base6,    s:base2,    "")
call s:hi("FoldColumn",       s:base4,    s:bg,       "")
call s:hi("VertSplit",        s:base2,    s:base2,    "none")
call s:hi("LineNr",           s:base4,    "",         "none")
call s:hi("CursorLineNr",     s:fg,       "",         "none")
call s:hi("NonText",          s:base3,    "",         "")
call s:hi("SpecialKey",       s:base3,    "",         "")
call s:hi("Conceal",          s:base5,    "",         "")
call s:hi("Directory",        s:blue,     "",         "bold")
call s:hi("Title",            s:fg,       "",         "bold")
call s:hi("MatchParen",       "",         s:base4,    "bold")

" -- Selection / Search -----------------------------------------------------
call s:hi("Visual",           "",         s:selection,"none")
call s:hi("VisualNOS",        "",         s:selection,"none")
call s:hi("Search",           s:bg,       s:yellow,   "bold")
call s:hi("IncSearch",        s:bg,       s:yellow,   "bold")

" -- Messages / UI ----------------------------------------------------------
call s:hi("ErrorMsg",         s:error,    "",         "bold")
call s:hi("WarningMsg",       s:warning,  "",         "bold")
call s:hi("ModeMsg",          s:fg,       "",         "bold")
call s:hi("MoreMsg",          s:green,    "",         "bold")
call s:hi("Question",         s:yellow,   "",         "bold")
call s:hi("Pmenu",            s:fg,       s:base2,    "")
call s:hi("PmenuSel",         s:bg,       s:cyan,     "")
call s:hi("PmenuSbar",        "",         s:base3,    "")
call s:hi("PmenuThumb",       "",         s:base6,    "")
call s:hi("WildMenu",         s:bg,       s:yellow,   "bold")
call s:hi("StatusLine",       s:modeline_fg,     s:modeline_bg,          "none")
call s:hi("StatusLineNC",     s:modeline_fg_alt, s:modeline_bg_inactive, "none")
call s:hi("TabLine",          s:base6,    s:base1,    "none")
call s:hi("TabLineSel",       s:fg,       s:bg,       "bold")
call s:hi("TabLineFill",      "",         s:base1,    "none")

" -- Syntax -----------------------------------------------------------------
call s:hi("Comment",          s:comments, "",         "italic")
call s:hi("Constant",         s:constants,"",         "")
call s:hi("String",           s:strings,  "",         "")
call s:hi("Character",        s:strings,  "",         "")
call s:hi("Number",           s:numbers,  "",         "")
call s:hi("Boolean",          s:constants,"",         "")
call s:hi("Float",            s:numbers,  "",         "")
call s:hi("Identifier",       s:variables,"",         "none")
call s:hi("Function",         s:functions,"",         "")
call s:hi("Statement",        s:keywords, "",         "bold")
call s:hi("Conditional",      s:keywords, "",         "bold")
call s:hi("Repeat",           s:keywords, "",         "bold")
call s:hi("Label",            s:keywords, "",         "bold")
call s:hi("Operator",         s:operators,"",         "")
call s:hi("Keyword",          s:keywords, "",         "bold")
call s:hi("Exception",        s:keywords, "",         "bold")
call s:hi("PreProc",          s:base7,    "",         "")
call s:hi("Include",          s:base7,    "",         "")
call s:hi("Define",           s:base7,    "",         "")
call s:hi("Macro",            s:base7,    "",         "")
call s:hi("PreCondit",        s:base7,    "",         "")
call s:hi("Type",             s:type,     "",         "")
call s:hi("StorageClass",     s:type,     "",         "")
call s:hi("Structure",        s:type,     "",         "")
call s:hi("Typedef",          s:type,     "",         "")
call s:hi("Special",          s:cyan,     "",         "")
call s:hi("SpecialChar",      s:yellow,   "",         "")
call s:hi("Tag",              s:cyan,     "",         "")
call s:hi("Delimiter",        s:base6,    "",         "")
call s:hi("SpecialComment",   s:comments, "",         "italic")
call s:hi("Debug",            s:red,      "",         "")
call s:hi("Underlined",       s:blue,     "",         "underline")
call s:hi("Ignore",           s:base5,    "",         "")
call s:hi("Error",            s:error,    "",         "bold")
call s:hi("Todo",             s:red,      "",         "bold,italic")

" -- Diff -------------------------------------------------------------------
call s:hi("DiffAdd",          s:green,    "#1a231a",  "")
call s:hi("DiffDelete",       s:red,      "#231a1a",  "")
call s:hi("DiffChange",       s:orange,   "#23211a",  "")
call s:hi("DiffText",         s:bg,       s:green,    "bold")

" -- Spell ------------------------------------------------------------------
call s:hi("SpellBad",         s:red,      "",         "undercurl")
call s:hi("SpellCap",         s:yellow,   "",         "undercurl")
call s:hi("SpellRare",        s:cyan,     "",         "undercurl")
call s:hi("SpellLocal",       s:teal,     "",         "undercurl")

" -- Links ------------------------------------------------------------------
highlight! link EndOfBuffer   NonText
highlight! link NormalFloat   Pmenu
highlight! link FloatBorder   VertSplit
highlight! link QuickFixLine  Search

" -- Netrw (mirrors dired) --------------------------------------------------
call s:hi("netrwDir",         s:blue,     "",         "bold")
call s:hi("netrwSymLink",     s:teal,     "",         "bold")
call s:hi("netrwExe",         s:green,    "",         "bold")
call s:hi("netrwMakefile",    s:yellow,   "",         "bold")

" -- Terminal colours (Vim 8+) ----------------------------------------------
if has("terminal")
  let g:terminal_ansi_colors = [
    \ s:bg,        s:red,       s:green,     s:yellow,
    \ s:blue,      s:magenta,   s:cyan,      s:base7,
    \ s:base4,     s:red,       s:green,     s:yellow,
    \ s:dark_blue, s:violet,    s:dark_cyan, s:fg
    \ ]
endif

" Clean up script-local variables
delfunction s:hi
