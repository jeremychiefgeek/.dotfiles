-- explorer.lua  - Column-based file explorer (mini.files style)
--
-- Navigation:
--   l / Enter    – enter directory or open file
--   h / Backspace– go left
--   v            – open file in vertical split
--   s            – open file in horizontal split
--   .            – toggle hidden files
--   q / <M-e>    – close
--
-- File manipulation (edit the buffer like normal text, then):
--   =            – preview and apply pending changes
--
-- Editing rules:
--   - Edit a line's name  → rename that file/dir
--   - Delete a line       → delete that file/dir
--   - Add a new line      → create file (end with / to create a directory)
--   Icons (▸ / space) are stripped before applying — only the name matters.

local M = {}

-- ── Constants ─────────────────────────────────────────────────────────────────
local COL_WIDTH   = 36
local COL_HEIGHT  = 24
local COL_PADDING = 1

-- ── State ─────────────────────────────────────────────────────────────────────
local state = {
  columns     = {},
  show_hidden = false,
  active_col  = 1,
}

local shadow_wins = {}

-- ── Highlights ────────────────────────────────────────────────────────────────
local function setup_highlights()
  vim.api.nvim_set_hl(0, "ExplorerBorder",  { fg = "#676d77", bg = "#1a1d21" })
  vim.api.nvim_set_hl(0, "ExplorerTitle",   { fg = "#ccc4b4", bg = "#1a1d21", bold = true })
  vim.api.nvim_set_hl(0, "ExplorerNormal",  { fg = "#f0efeb", bg = "#22262b" })
  vim.api.nvim_set_hl(0, "ExplorerShadow",  { bg = "#0f1114" })
  vim.api.nvim_set_hl(0, "ExplorerAdded",   { fg = "#b8c4b8", bg = "#22262b", bold = true })
  vim.api.nvim_set_hl(0, "ExplorerDeleted", { fg = "#CDACAC", bg = "#22262b", bold = true })
  vim.api.nvim_set_hl(0, "ExplorerChanged", { fg = "#d4ccb4", bg = "#22262b", bold = true })
end

-- ── Helpers ───────────────────────────────────────────────────────────────────
local function is_open()
  return #state.columns > 0
    and vim.api.nvim_win_is_valid(state.columns[1].win)
end

local function scan_dir(path)
  local entries = {}
  local handle  = vim.loop.fs_scandir(path)
  if not handle then return entries end
  while true do
    local name, ftype = vim.loop.fs_scandir_next(handle)
    if not name then break end
    if state.show_hidden or name:sub(1, 1) ~= "." then
      table.insert(entries, {
        name = name,
        type = ftype,
        path = path:gsub("[\\/]$", "") .. "/" .. name,
      })
    end
  end
  table.sort(entries, function(a, b)
    if a.type ~= b.type then return a.type == "directory" end
    return a.name:lower() < b.name:lower()
  end)
  return entries
end

local function col_screen_pos(i)
  local total_w    = COL_WIDTH * i + COL_PADDING * (i - 1)
  local screen_col = math.floor((vim.o.columns - total_w) / 2)
    + (i - 1) * (COL_WIDTH + COL_PADDING)
  local screen_row = math.floor((vim.o.lines - COL_HEIGHT) / 2)
  return screen_row, screen_col
end

-- Strip leading icon (▸ or spaces) from a display line → bare name
local function strip_icon(line)
  return line:match("^[▸ ]%s(.+)$") or line:match("^%s*(.+)$") or line
end

-- ── Buffer creation ───────────────────────────────────────────────────────────
local function entry_to_line(e)
  local icon = e.type == "directory" and "▸ " or "  "
  return icon .. e.name
end

local function make_col_buf(col)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype   = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile  = false
  vim.bo[buf].filetype  = "jeremy_explorer"

  local lines = {}
  for _, e in ipairs(col.entries) do
    table.insert(lines, entry_to_line(e))
  end
  if #lines == 0 then lines = { "  (empty)" } end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Store the original lines so we can diff on =
  col.original_lines = vim.deepcopy(lines)

  return buf
end

-- ── Window creation ───────────────────────────────────────────────────────────
local function open_shadow(row, c)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, false, {
    relative  = "editor",
    width     = COL_WIDTH  + 1,
    height    = COL_HEIGHT + 1,
    row       = row + 1,
    col       = c   + 2,
    style     = "minimal",
    focusable = false,
    zindex    = 49,
  })
  vim.wo[win].winhighlight = "Normal:ExplorerShadow,NormalFloat:ExplorerShadow"
  table.insert(shadow_wins, win)
  return win
end

local function open_col_win(col, index)
  setup_highlights()
  local row, c = col_screen_pos(index)
  local short  = vim.fn.fnamemodify(col.path, ":~:.")
  if short == "" then short = col.path end

  open_shadow(row, c)

  local win = vim.api.nvim_open_win(col.buf, true, {
    relative  = "editor",
    width     = COL_WIDTH,
    height    = COL_HEIGHT,
    row       = row,
    col       = c,
    style     = "minimal",
    border    = "rounded",
    title     = " " .. short .. " ",
    title_pos = "left",
    zindex    = 50,
  })

  vim.wo[win].cursorline   = true
  vim.wo[win].wrap         = false
  vim.wo[win].number       = false
  vim.wo[win].signcolumn   = "no"
  vim.wo[win].winhighlight = table.concat({
    "Normal:ExplorerNormal",
    "NormalFloat:ExplorerNormal",
    "FloatBorder:ExplorerBorder",
    "FloatTitle:ExplorerTitle",
    "CursorLine:Visual",
  }, ",")

  return win
end

-- ── Diff / apply ──────────────────────────────────────────────────────────────

-- Compare original_lines to current buffer lines and return a list of ops:
--   { op="rename", from=path, to=path }
--   { op="delete", path=path }
--   { op="create", path=path, is_dir=bool }
local function compute_ops(col)
  local cur_lines = vim.api.nvim_buf_get_lines(col.buf, 0, -1, false)
  local orig      = col.original_lines
  local ops       = {}

  -- Build lookup: name -> entry  (for originals)
  local orig_by_name = {}
  for i, line in ipairs(orig) do
    local name = strip_icon(line)
    orig_by_name[name] = { line = line, idx = i }
  end

  -- Build lookup for current lines
  local cur_by_name = {}
  for i, line in ipairs(cur_lines) do
    local name = strip_icon(line)
    if name ~= "(empty)" and name ~= "" then
      cur_by_name[name] = { line = line, idx = i }
    end
  end

  -- Deleted: in original but not in current
  for name, info in pairs(orig_by_name) do
    if not cur_by_name[name] then
      -- Check if it was renamed (same position, different name)
      local cur_at_pos = cur_lines[info.idx]
      local cur_name   = cur_at_pos and strip_icon(cur_at_pos) or nil
      if cur_name and cur_name ~= "" and cur_name ~= "(empty)"
        and not orig_by_name[cur_name] then
        -- This is a rename
        table.insert(ops, {
          op   = "rename",
          from = col.path .. "/" .. name,
          to   = col.path .. "/" .. cur_name,
          display = "rename  " .. name .. "  →  " .. cur_name,
        })
        -- Mark cur_name as handled
        cur_by_name[cur_name] = nil
      else
        table.insert(ops, {
          op      = "delete",
          path    = col.path .. "/" .. name,
          is_dir  = orig_by_name[name].line:sub(1,1) == "▸",
          display = "delete  " .. name,
        })
      end
    end
  end

  -- Created: in current but not in original and not already handled
  for name, _ in pairs(cur_by_name) do
    if not orig_by_name[name] then
      local is_dir = name:sub(-1) == "/"
      local clean  = is_dir and name:sub(1,-2) or name
      table.insert(ops, {
        op      = "create",
        path    = col.path .. "/" .. clean,
        is_dir  = is_dir,
        display = (is_dir and "mkdir   " or "create  ") .. clean,
      })
    end
  end

  return ops
end

local function apply_ops(ops, col)
  for _, op in ipairs(ops) do
    if op.op == "rename" then
      local ok, err = os.rename(op.from, op.to)
      if not ok then
        vim.notify("Rename failed: " .. (err or ""), vim.log.levels.ERROR)
      end
    elseif op.op == "delete" then
      local ok
      if op.is_dir then
        ok = vim.fn.delete(op.path, "rf") == 0
      else
        ok = os.remove(op.path) ~= nil
      end
      if not ok then
        vim.notify("Delete failed: " .. op.path, vim.log.levels.ERROR)
      end
    elseif op.op == "create" then
      if op.is_dir then
        vim.fn.mkdir(op.path, "p")
      else
        vim.fn.mkdir(vim.fn.fnamemodify(op.path, ":h"), "p")
        local f = io.open(op.path, "w")
        if f then f:close() end
      end
    end
  end
end

local function refresh_col(col)
  col.entries = scan_dir(col.path)
  local lines = {}
  for _, e in ipairs(col.entries) do
    table.insert(lines, entry_to_line(e))
  end
  if #lines == 0 then lines = { "  (empty)" } end
  vim.api.nvim_buf_set_lines(col.buf, 0, -1, false, lines)
  col.original_lines = vim.deepcopy(lines)
end

-- Show confirmation floating window with the diff, apply on y / cancel on n
local function show_confirm(ops, col)
  if #ops == 0 then
    vim.notify("No changes.", vim.log.levels.INFO)
    return
  end

  local col_buf = col.buf  -- capture before opening confirm window

  local lines = { "  Pending changes:", "" }
  for _, op in ipairs(ops) do
    table.insert(lines, "  " .. op.display)
  end
  table.insert(lines, "")
  table.insert(lines, "  Apply? [y]es / [n]o")

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype   = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  for i, op in ipairs(ops) do
    local hl = op.op == "create"  and "ExplorerAdded"
            or op.op == "delete"  and "ExplorerDeleted"
            or "ExplorerChanged"
    vim.api.nvim_buf_add_highlight(buf, -1, hl, i + 1, 0, -1)
  end

  local width  = 52
  local height = #lines + 2
  local win    = vim.api.nvim_open_win(buf, true, {
    relative  = "editor",
    width     = width,
    height    = height,
    row       = math.floor((vim.o.lines   - height) / 2),
    col       = math.floor((vim.o.columns - width)  / 2),
    style     = "minimal",
    border    = "rounded",
    title     = " Confirm ",
    title_pos = "center",
    zindex    = 60,
  })

  vim.wo[win].winhighlight = table.concat({
    "Normal:ExplorerNormal",
    "NormalFloat:ExplorerNormal",
    "FloatBorder:ExplorerBorder",
    "FloatTitle:ExplorerTitle",
  }, ",")

  local function close_confirm()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local function revert()
    close_confirm()
    if vim.api.nvim_buf_is_valid(col_buf) then
      vim.api.nvim_buf_set_lines(col_buf, 0, -1, false, col.original_lines)
    end
  end

  vim.keymap.set("n", "y", function()
    close_confirm()
    apply_ops(ops, col)
    -- Re-focus the column window before refreshing
    if vim.api.nvim_win_is_valid(col.win) then
      vim.api.nvim_set_current_win(col.win)
    end
    if vim.api.nvim_buf_is_valid(col_buf) then
      refresh_col(col)
    end
  end, { buffer = buf, noremap = true, nowait = true })

  vim.keymap.set("n", "n",     revert, { buffer = buf, noremap = true, nowait = true })
  vim.keymap.set("n", "<Esc>", revert, { buffer = buf, noremap = true, nowait = true })
  vim.keymap.set("n", "q",     revert, { buffer = buf, noremap = true, nowait = true })
end

-- ── Keymaps ───────────────────────────────────────────────────────────────────
local function setup_keymaps(buf, col)
  local opts = { buffer = buf, noremap = true, nowait = true, silent = true }
  local map  = function(k, fn) vim.keymap.set("n", k, fn, opts) end

  map("l",     function() M.navigate_in()     end)
  map("<CR>",  function() M.navigate_in()     end)
  map("h",     function() M.go_left()         end)
  map("<BS>",  function() M.go_left()         end)
  map("v",     function() M.open_split(true)  end)
  map("s",     function() M.open_split(false) end)
  map(".",     function() M.toggle_hidden()   end)
  map("q",     function() M.close()           end)
  map("<M-e>", function() M.close()           end)

  -- = triggers diff + confirm
  map("=", function()
    local ops = compute_ops(col)
    show_confirm(ops, col)
  end)
end

-- ── Column management ─────────────────────────────────────────────────────────
local function push_column(path, focus_row)
  local col = { path = path, entries = scan_dir(path) }
  table.insert(state.columns, col)
  local idx        = #state.columns
  col.buf          = make_col_buf(col)
  col.win          = open_col_win(col, idx)
  setup_keymaps(col.buf, col)
  state.active_col = idx

  local saved = focus_row or col._saved_row or 1
  pcall(vim.api.nvim_win_set_cursor, col.win, { saved, 0 })

  vim.api.nvim_create_autocmd("WinLeave", {
    buffer   = col.buf,
    once     = true,
    callback = function()
      vim.schedule(function()
        local cur_win     = vim.api.nvim_get_current_win()
        local in_explorer = false
        for _, c in ipairs(state.columns) do
          if vim.api.nvim_win_is_valid(c.win) and c.win == cur_win then
            in_explorer = true
            break
          end
        end
        if not in_explorer then M.close() end
      end)
    end,
  })
end

local function pop_column()
  if #state.columns <= 1 then return end
  local col = table.remove(state.columns)
  if vim.api.nvim_win_is_valid(col.win) then
    col._saved_row = vim.api.nvim_win_get_cursor(col.win)[1]
    vim.api.nvim_win_close(col.win, true)
  end
  local shadow = table.remove(shadow_wins)
  if shadow and vim.api.nvim_win_is_valid(shadow) then
    vim.api.nvim_win_close(shadow, true)
  end
  state.active_col = #state.columns
  local prev = state.columns[#state.columns]
  if vim.api.nvim_win_is_valid(prev.win) then
    vim.api.nvim_set_current_win(prev.win)
  end
end

local function trim_columns_after(i)
  while #state.columns > i do
    local col = table.remove(state.columns)
    if vim.api.nvim_win_is_valid(col.win) then
      vim.api.nvim_win_close(col.win, true)
    end
    local shadow = table.remove(shadow_wins)
    if shadow and vim.api.nvim_win_is_valid(shadow) then
      vim.api.nvim_win_close(shadow, true)
    end
  end
end

-- ── Entry under cursor ────────────────────────────────────────────────────────
local function active_col()
  return state.columns[state.active_col]
    or  state.columns[#state.columns]
end

local function current_entry()
  local col = active_col()
  if not col then return nil end
  local row  = vim.api.nvim_win_get_cursor(col.win)[1]
  -- Match against original entries by row (buffer may be edited)
  return col.entries[row]
end

-- ── Public actions ────────────────────────────────────────────────────────────
function M.navigate_in()
  local e = current_entry()
  if not e then return end
  if e.type == "directory" then
    trim_columns_after(state.active_col)
    push_column(e.path)
  else
    local path = e.path
    M.close()
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  end
end

function M.go_left()
  if #state.columns <= 1 then M.close(); return end
  pop_column()
end

function M.open_split(vertical)
  local e = current_entry()
  if not e or e.type == "directory" then return end
  local path = e.path
  M.close()
  local cmd = vertical and "vsplit" or "split"
  vim.cmd(cmd .. " " .. vim.fn.fnameescape(path))
end

function M.toggle_hidden()
  state.show_hidden = not state.show_hidden
  for _, col in ipairs(state.columns) do
    refresh_col(col)
  end
end

function M.close()
  for i = #state.columns, 1, -1 do
    local col = state.columns[i]
    if vim.api.nvim_win_is_valid(col.win) then
      vim.api.nvim_win_close(col.win, true)
    end
  end
  for _, w in ipairs(shadow_wins) do
    if vim.api.nvim_win_is_valid(w) then
      vim.api.nvim_win_close(w, true)
    end
  end
  shadow_wins      = {}
  state.columns    = {}
  state.active_col = 1
end

-- ── Entry point ───────────────────────────────────────────────────────────────
function M.open(start_path)
  if is_open() then M.close(); return end

  local cwd      = vim.fn.fnamemodify(vim.fn.getcwd(), ":p"):gsub("[\\/]$", "")
  local cur_file = vim.fn.expand("%:p")
  local cur_dir  = vim.fn.fnamemodify(cur_file, ":h"):gsub("[\\/]$", "")

  start_path = vim.fn.fnamemodify(start_path or cwd, ":p"):gsub("[\\/]$", "")

  state.columns    = {}
  state.active_col = 1

  push_column(start_path)

  if cur_dir ~= start_path and cur_dir:sub(1, #start_path) == start_path then
    local relative = cur_dir:sub(#start_path + 2)
    local parts    = vim.split(relative, "[/\\]", { trimempty = true })
    local path     = start_path
    for _, part in ipairs(parts) do
      path = path .. "/" .. part
      local col = state.columns[#state.columns]
      for i, e in ipairs(col.entries) do
        if e.name == part then
          pcall(vim.api.nvim_win_set_cursor, col.win, { i, 0 })
          break
        end
      end
      push_column(path)
    end
    local col   = state.columns[#state.columns]
    local fname = vim.fn.fnamemodify(cur_file, ":t")
    for i, e in ipairs(col.entries) do
      if e.name == fname then
        pcall(vim.api.nvim_win_set_cursor, col.win, { i, 0 })
        break
      end
    end
  end
end

return M
