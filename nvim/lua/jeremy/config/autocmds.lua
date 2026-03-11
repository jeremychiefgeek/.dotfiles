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

    -- New-file templates
    if vim.fn.filereadable(vim.fn.expand("%")) == 0 then
      local fname = vim.fn.expand("%")
      if fname:match("%.[hH][iI][nN]?$") then
        require("jeremy.config.autocmds")._header_format()
      elseif fname:match("%.[cC][pP][pP]?$") or fname:match("%.cin$") then
        require("jeremy.config.autocmds")._source_format()
      end
    end
  end,
})

-- ── Exported helpers (called from the FileType callback above) ────────────────

local M = {}

function M._header_format()
  local base  = vim.fn.fnamemodify(vim.fn.expand("%"), ":t:r"):upper()
  local guard = base .. "_H"
  vim.fn.setline(1,  "#ifndef " .. guard)
  vim.fn.append(1,  "/* ========================================================================")
  vim.fn.append(2,  "   $File: $")
  vim.fn.append(3,  "   $Date: $")
  vim.fn.append(4,  "   $Revision: $")
  vim.fn.append(5,  "   $Creator: Jeremy Evans $")
  vim.fn.append(6,  "   $Notice: (C) Copyright 2026 by Chief Geek, LLC. All Rights Reserved. $")
  vim.fn.append(7,  "   ======================================================================== */")
  vim.fn.append(8,  "")
  vim.fn.append(9,  "#define " .. guard)
  vim.fn.append(10, "#endif")
end

function M._source_format()
  vim.fn.setline(1, "/* ========================================================================")
  vim.fn.append(1,  "   $File: $")
  vim.fn.append(2,  "   $Date: $")
  vim.fn.append(3,  "   $Revision: $")
  vim.fn.append(4,  "   $Creator: Jeremy Evans $")
  vim.fn.append(5,  "   $Notice: (C) Copyright 2026 by Chief Geek, LLC. All Rights Reserved. $")
  vim.fn.append(6,  "   ======================================================================== */")
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
