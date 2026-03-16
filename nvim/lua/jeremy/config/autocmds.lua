-- lua/jeremy/config/autocmds.lua
-- Autocommands: startup split, filetypes, keyword highlights, C/C++ style.

local au  = vim.api.nvim_create_autocmd
local aug = vim.api.nvim_create_augroup

-- ── Startup: vertical split when no files given ──────────────────────────────
aug("jeremy_startup_split", { clear = true })
au("VimEnter", {
  group   = "jeremy_startup_split",
  once    = true,
  callback = function()
    if vim.fn.argc() == 0 then
      vim.cmd("vsplit")
    end
    -- Maximise on Windows GUI
    if (vim.g.jeremy_win32) and vim.fn.has("gui_running") == 1 then
      vim.cmd("simalt ~x")
    end
  end,
})

-- ── New C/C++ file templates (BufNewFile fires before FileType) ─────────────
aug("jeremy_new_file_templates", { clear = true })
au("BufNewFile", {
  group    = "jeremy_new_file_templates",
  pattern  = { "*.h", "*.H", "*.hin" },
  callback = function()
    -- Defer so the buffer is fully set up before we write lines
    vim.schedule(function()
      local ac = require("jeremy.config.autocmds")
      ac._header_format()
    end)
  end,
})
au("BufNewFile", {
  group    = "jeremy_new_file_templates",
  pattern  = { "*.c", "*.C", "*.cpp", "*.cin" },
  callback = function()
    vim.schedule(function()
      local ac = require("jeremy.config.autocmds")
      ac._source_format()
    end)
  end,
})

-- ── File-type associations ───────────────────────────────────────────────────
aug("jeremy_filetypes", { clear = true })
au({ "BufNewFile", "BufRead" }, {
  group   = "jeremy_filetypes",
  pattern = { "*.cpp","*.hin","*.cin","*.inl","*.rdc","*.h","*.c","*.cc","*.c8" },
  command = "setfiletype cpp",
})
au({ "BufNewFile", "BufRead" }, {
  group   = "jeremy_filetypes",
  pattern = "*.txt",
  command = "setfiletype text",
})
au({ "BufNewFile", "BufRead" }, {
  group   = "jeremy_filetypes",
  pattern = "*.ms",
  command = "setfiletype fundamental",
})
au({ "BufNewFile", "BufRead" }, {
  group   = "jeremy_filetypes",
  pattern = { "*.m", "*.mm" },
  command = "setfiletype objc",
})

-- ── Keyword highlights: TODO / STUDY / IMPORTANT / NOTE ──────────────────────
-- These are defined per-syntax via the Syntax autocommand, mirroring the
-- vimrc font-lock approach.
aug("jeremy_keywords", { clear = true })
au("Syntax", {
  group   = "jeremy_keywords",
  pattern = { "c", "cpp", "vim", "python", "lua" },
  callback = function()
    vim.cmd([[
      syn keyword jeremyTodo      contained TODO
      syn keyword jeremyStudy     contained STUDY
      syn keyword jeremyImportant contained IMPORTANT
      syn keyword jeremyNote      contained NOTE
      syn cluster cCommentGroup add=jeremyTodo,jeremyStudy,jeremyImportant,jeremyNote
      hi jeremyTodo      guifg=#e8a0a0 gui=bold,underline
      hi jeremyStudy     guifg=#e8d9a0 gui=bold,underline
      hi jeremyImportant guifg=#e8d9a0 gui=bold,underline
      hi jeremyNote      guifg=#a0c8a0 gui=bold,underline
    ]])
  end,
})

-- ── C / C++ style ────────────────────────────────────────────────────────────
aug("jeremy_c_style", { clear = true })
au("FileType", {
  group    = "jeremy_c_style",
  pattern  = { "c", "cpp" },
  callback = function(ev)
    local buf = ev.buf
    local opt = vim.bo[buf]
    opt.tabstop     = 4
    opt.shiftwidth  = 4
    opt.expandtab   = true
    opt.cindent     = true
    opt.cinoptions  = "l1,g0,h-4,t0,+4,(4,u0,w1,W4,m1,j1"

    local bmap = function(lhs, rhs, mode)
      vim.keymap.set(mode or "n", lhs, rhs, { buffer = buf })
    end

    -- Tab = omni/next completion in insert (Ctrl-n), Shift-Tab = literal tab
    vim.keymap.set("i", "<Tab>",   "<C-n>",  { buffer = buf })
    vim.keymap.set("i", "<S-Tab>", "<Tab>",  { buffer = buf })
    -- CR auto-indents (cindent handles most of it; C-f re-indents current line)
    vim.keymap.set("i", "<CR>",    "<CR><C-f>", { buffer = buf })

    -- Buffer-local normal maps
    bmap("<M-f>",  function() require("jeremy.config.autocmds")._find_corresponding() end)
    bmap("<M-ff>", function() require("jeremy.config.autocmds")._find_corresponding_other_window() end)
    bmap("<M-s>",  function() require("jeremy.config.autocmds")._save_buffer() end)
    bmap("<M-j>",  "g<C-]>")     -- jump to tag
    bmap("<M-.>",  "gqip")       -- reformat paragraph
    bmap("<M-/>",  "vaf")        -- select a function
    bmap("<M-a>",  "p=']")       -- paste and re-indent
    bmap("<M-z>",  "d")          -- delete (Emacs kill)

    -- Error format additions for MSVC
    vim.opt_local.errorformat:append("%*[0-9]>%f(%l) : %t%*[a-z ]C%n: %m")
    vim.opt_local.errorformat:append("%f(%l) : %t%*[a-z ]C%n: %m")

    -- Templates are applied via the BufNewFile autocmd in autocmds.lua
  end,
})

-- ── Exported helpers (called from the FileType callback above) ────────────────

local M = {}

-- Returns the header template lines for a given file path.
-- Used both for writing to buffers and directly to disk (mini.files).
function M._header_lines(path)
  local fname = path
    and vim.fn.fnamemodify(path, ":t:r")
    or  vim.fn.fnamemodify(vim.fn.expand("%"), ":t:r")
  local guard = fname:upper() .. "_H"
  return {
    "#ifndef " .. guard,
    "/* ========================================================================",
    "   $File: $",
    "   $Date: $",
    "   $Revision: $",
    "   $Creator: Jeremy Evans $",
    "   $Notice: (C) Copyright " .. os.date("%Y") .. " by Chief Geek, LLC. All Rights Reserved. $",
    "   ======================================================================== */",
    "",
    "#define " .. guard,
    "#endif",
  }
end

function M._source_lines()
  return {
    "/* ========================================================================",
    "   $File: $",
    "   $Date: $",
    "   $Revision: $",
    "   $Creator: Jeremy Evans $",
    "   $Notice: (C) Copyright " .. os.date("%Y") .. " by Chief Geek, LLC. All Rights Reserved. $",
    "   ======================================================================== */",
  }
end

-- Write template into the current buffer (used by BufNewFile autocmd)
function M._header_format(path)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, M._header_lines(path))
end

function M._source_format()
  vim.api.nvim_buf_set_lines(0, 0, -1, false, M._source_lines())
end

function M._find_corresponding()
  local file = vim.fn.expand("%")
  local base = vim.fn.fnamemodify(file, ":r")
  local target = ""

  if     file:match("%.c$")   then target = base .. ".h"
  elseif file:match("%.h$")   then
    target = vim.fn.filereadable(base .. ".c") == 1 and base .. ".c" or base .. ".cpp"
  elseif file:match("%.hin$") then target = base .. ".cin"
  elseif file:match("%.cin$") then target = base .. ".hin"
  elseif file:match("%.cpp$") then target = base .. ".h"
  end

  if target == "" then
    vim.api.nvim_err_writeln("Unable to find a corresponding file")
    return
  end

  local abs    = vim.fn.fnamemodify(target, ":p")
  local bufnr  = vim.fn.bufnr(abs)
  local winnr  = bufnr ~= -1 and vim.fn.bufwinnr(bufnr) or -1

  if winnr ~= -1 then
    vim.cmd(winnr .. "wincmd w")
  elseif bufnr ~= -1 then
    vim.cmd("vsplit | buffer " .. bufnr)
  else
    vim.cmd("vsplit " .. vim.fn.fnameescape(target))
  end
end

function M._find_corresponding_other_window()
  local cur = vim.fn.expand("%:p")
  vim.cmd("wincmd w")
  vim.cmd("edit " .. vim.fn.fnameescape(cur))
  M._find_corresponding()
  vim.cmd("wincmd p")
end

function M._save_buffer()
  local pos = vim.fn.getcurpos()
  vim.cmd("retab!")
  vim.cmd("write")
  vim.fn.setpos(".", pos)
end

return M
