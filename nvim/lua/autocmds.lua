local au  = vim.api.nvim_create_autocmd
local aug = vim.api.nvim_create_augroup

-- ── File-type associations ──────────────────────────────────────────────────
local ft = aug("jeremy_filetypes", { clear = true })

au({"BufNewFile","BufRead"}, {
  group   = ft,
  pattern = {"*.cpp","*.hin","*.cin","*.inl","*.rdc","*.h","*.c","*.cc","*.c8"},
  command = "setfiletype cpp",
})
au({"BufNewFile","BufRead"}, { group = ft, pattern = "*.txt", command = "setfiletype text" })
au({"BufNewFile","BufRead"}, { group = ft, pattern = "*.ms",  command = "setfiletype fundamental" })
au({"BufNewFile","BufRead"}, { group = ft, pattern = {"*.m","*.mm"}, command = "setfiletype objc" })

-- ── Keyword highlighting (TODO / STUDY / IMPORTANT / NOTE) ──────────────────
local kw = aug("jeremy_keywords", { clear = true })

au("Syntax", {
  group   = kw,
  pattern = {"c","cpp","vim"},
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

-- ── C/C++ style ─────────────────────────────────────────────────────────────
local cs = aug("jeremy_c_style", { clear = true })

au("FileType", {
  group    = cs,
  pattern  = {"c","cpp"},
  callback = function(ev)
    local opt = vim.opt_local
    opt.tabstop    = 4
    opt.shiftwidth = 4
    opt.expandtab  = true
    opt.cindent    = true
    opt.cinoptions = "l1,g0,h-4,t0,+4,(4,u0,w1,W4,m1,j1"

    local buf = ev.buf
    local map = function(lhs, rhs) vim.keymap.set("n", lhs, rhs, { buffer = buf, noremap = true }) end
    local imap = function(lhs, rhs) vim.keymap.set("i", lhs, rhs, { buffer = buf, noremap = true }) end

    imap("<CR>",    "<CR><C-f>")
    imap("<Tab>",   "<C-n>")
    imap("<S-Tab>", "<Tab>")

    -- Header guard for new .h files
    local fname = vim.api.nvim_buf_get_name(buf)
    if not vim.loop.fs_stat(fname) and fname:match("%.h$") then
      local base  = vim.fn.fnamemodify(fname, ":t:r"):upper()
      local guard = base .. "_H"
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "#if !defined(" .. guard .. ")", "",
        "#define " .. guard, "#endif",
      })
    end

    -- Corresponding file (F12 / Alt-c)
    local function find_corresponding(other_win)
      local f    = vim.api.nvim_buf_get_name(0)
      local base = vim.fn.fnamemodify(f, ":r")
      local dest
      if     f:match("%.c$")   then dest = base .. ".h"
      elseif f:match("%.h$")   then
        dest = vim.loop.fs_stat(base..".c") and base..".c" or base..".cpp"
      elseif f:match("%.hin$") then dest = base .. ".cin"
      elseif f:match("%.cin$") then dest = base .. ".hin"
      elseif f:match("%.cpp$") then dest = base .. ".h"
      end
      if not dest then vim.notify("No corresponding file found", vim.log.levels.ERROR); return end
      if other_win then
        local cur = vim.api.nvim_buf_get_name(0)
        vim.cmd("wincmd w")
        vim.cmd("edit " .. vim.fn.fnameescape(cur))
      end
      vim.cmd("edit " .. vim.fn.fnameescape(dest))
      if other_win then vim.cmd("wincmd p") end
    end

    map("<F12>",   function() find_corresponding(false) end)
    map("<M-c>",   function() find_corresponding(false) end)
    map("<M-F12>", function() find_corresponding(true)  end)
    map("<M-C>",   function() find_corresponding(true)  end)

    -- Save with retab
    map("<M-s>", function()
      local pos = vim.api.nvim_win_get_cursor(0)
      vim.cmd("retab!")
      vim.cmd("write")
      vim.api.nvim_win_set_cursor(0, pos)
    end)

    map("<M-j>", "g<C-]>")
    map("<M-.>", function()
      vim.fn.setreg("/", "")
      vim.cmd("normal! gqip")
    end)
    map("<M-/>", "vaf")
    map("<M-a>", "p=']")
    map("<M-z>", "d")

    -- Re-indent after paste (mirrors jeremy_yank_indent)
    map("p", "p=']")
    map("P", "P=']")

    -- Errorformat additions
    vim.opt_local.errorformat:prepend(
      "%*[0-9]>%f(%l) : %t%*[a-z ]C%n: %m,"
      .. "%f(%l) : %t%*[a-z ]C%n: %m"
    )
  end,
})

-- ── Re-indent after paste (vim files) ────────────────────────────────────────
local yi = aug("jeremy_yank_indent", { clear = true })

au("FileType", {
  group    = yi,
  pattern  = "vim",
  callback = function(ev)
    local buf = ev.buf
    vim.keymap.set("n", "p", "p=']", { buffer = buf, noremap = true })
    vim.keymap.set("n", "P", "P=']", { buffer = buf, noremap = true })
  end,
})

-- ── Startup: vertical split when opening with no args ───────────────────────
local su = aug("jeremy_startup", { clear = true })

au("VimEnter", {
  group    = su,
  callback = function()
    if vim.fn.argc() == 0 then vim.cmd("vsplit") end
  end,
})

-- ── Maximise on Windows GUI startup ─────────────────────────────────────────
if vim.g.jeremy_win32 then
  local mx = aug("jeremy_maximize", { clear = true })
  au("GUIEnter", { group = mx, command = "simalt ~x" })
end
