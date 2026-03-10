-- explorer.lua  - Column-based file explorer (mini.files style)
-- Each column is a real buffer + window; cursor movement is native.
--
-- Keybinds (inside any explorer column):
--   l / Enter    – enter directory (opens new column) or open file
--   h / Backspace– go left / close rightmost column
--   v            – open file in vertical split
--   s            – open file in horizontal split
--   n            – new file or directory (end name with / for dir)
--   r            – rename entry under cursor
--   d            – delete entry under cursor (confirms first)
--   .            – toggle hidden files
--   q / <M-e>    – close explorer

local M = {}

-- ── Constants ─────────────────────────────────────────────────────────────────
local COL_WIDTH   = 32
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
  vim.api.nvim_set_hl(0, "ExplorerBorder", { fg = "#676d77", bg = "#1a1d21" })
  vim.api.nvim_set_hl(0, "ExplorerTitle",  { fg = "#ccc4b4", bg = "#1a1d21", bold = true })
  vim.api.nvim_set_hl(0, "ExplorerNormal", { fg = "#f0efeb", bg = "#22262b" })
  vim.api.nvim_set_hl(0, "ExplorerShadow", { bg = "#0f1114" })
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
  local total_w   = COL_WIDTH * i + COL_PADDING * (i - 1)
  local screen_col = math.floor((vim.o.columns - total_w) / 2)
    + (i - 1) * (COL_WIDTH + COL_PADDING)
  local screen_row = math.floor((vim.o.lines - COL_HEIGHT) / 2)
  return screen_row, screen_col
end

-- ── Buffer creation ───────────────────────────────────────────────────────────
local function make_col_buf(col)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype   = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile  = false
  vim.bo[buf].filetype  = "jeremy_explorer"

  local lines = {}
  for _, e in ipairs(col.entries) do
    local icon = e.type == "directory" and "▸ " or "  "
    table.insert(lines, icon .. e.name)
  end
  if #lines == 0 then lines = { "  (empty)" } end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

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

  vim.wo[win].cursorline  = true
  vim.wo[win].wrap        = false
  vim.wo[win].number      = false
  vim.wo[win].signcolumn  = "no"
  vim.wo[win].winhighlight = table.concat({
    "Normal:ExplorerNormal",
    "NormalFloat:ExplorerNormal",
    "FloatBorder:ExplorerBorder",
    "FloatTitle:ExplorerTitle",
    "CursorLine:Visual",
  }, ",")

  return win
end

-- ── Keymaps ───────────────────────────────────────────────────────────────────
local function setup_keymaps(buf)
  local opts = { buffer = buf, noremap = true, nowait = true, silent = true }
  local map  = function(k, fn) vim.keymap.set("n", k, fn, opts) end

  map("l",     function() M.navigate_in()      end)
  map("<CR>",  function() M.navigate_in()      end)
  map("h",     function() M.go_left()          end)
  map("<BS>",  function() M.go_left()          end)
  map("v",     function() M.open_split(true)   end)
  map("s",     function() M.open_split(false)  end)
  map("n",     function() M.create_new()       end)
  map("r",     function() M.rename()           end)
  map("d",     function() M.delete()           end)
  map(".",     function() M.toggle_hidden()    end)
  map("q",     function() M.close()            end)
  map("<M-e>", function() M.close()            end)
end

-- ── Column management ─────────────────────────────────────────────────────────
local function push_column(path, focus_row)
  local col = { path = path, entries = scan_dir(path) }
  table.insert(state.columns, col)
  local idx    = #state.columns
  col.buf      = make_col_buf(col)
  col.win      = open_col_win(col, idx)
  setup_keymaps(col.buf)
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
  -- Close the corresponding shadow
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
  local row = vim.api.nvim_win_get_cursor(col.win)[1]
  return col.entries[row]
end

local function refresh_col(col)
  col.entries = scan_dir(col.path)
  local lines = {}
  for _, e in ipairs(col.entries) do
    local icon = e.type == "directory" and "▸ " or "  "
    table.insert(lines, icon .. e.name)
  end
  if #lines == 0 then lines = { "  (empty)" } end
  vim.bo[col.buf].modifiable = true
  vim.api.nvim_buf_set_lines(col.buf, 0, -1, false, lines)
  vim.bo[col.buf].modifiable = false
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
  if #state.columns <= 1 then
    M.close()
    return
  end
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

function M.create_new()
  local col = active_col()
  if not col then return end
  local input = vim.fn.input("New (end with / for dir): ",
    col.path:gsub("[\\/]$", "") .. "/")
  if input == "" then return end
  if input:sub(-1) == "/" then
    vim.fn.mkdir(input, "p")
  else
    vim.fn.mkdir(vim.fn.fnamemodify(input, ":h"), "p")
    local f = io.open(input, "w")
    if f then f:close() end
  end
  refresh_col(col)
end

function M.rename()
  local e = current_entry()
  if not e then return end
  local new_path = vim.fn.input("Rename to: ", e.path)
  if new_path == "" or new_path == e.path then return end
  local ok, err = os.rename(e.path, new_path)
  if not ok then
    vim.notify("Rename failed: " .. (err or "unknown"), vim.log.levels.ERROR)
  else
    refresh_col(active_col())
  end
end

function M.delete()
  local e = current_entry()
  if not e then return end
  local confirm = vim.fn.input("Delete '" .. e.name .. "'? [y/N]: ")
  if confirm:lower() ~= "y" then return end
  local ok
  if e.type == "directory" then
    ok = vim.fn.delete(e.path, "rf") == 0
  else
    ok = os.remove(e.path) ~= nil
  end
  if not ok then
    vim.notify("Delete failed", vim.log.levels.ERROR)
  else
    trim_columns_after(state.active_col)
    refresh_col(active_col())
  end
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

  -- Always open from cwd, then walk down to the file's directory
  -- so parent columns exist and you can navigate back up
  push_column(start_path)

  if cur_dir ~= start_path and cur_dir:sub(1, #start_path) == start_path then
    -- Build the chain of subdirectories between cwd and the current file
    local relative = cur_dir:sub(#start_path + 2)  -- strip cwd + separator
    local parts    = vim.split(relative, "[/\\]", { trimempty = true })
    local path     = start_path
    for _, part in ipairs(parts) do
      path = path .. "/" .. part
      -- Find and set the cursor on this entry in the current column
      local col = state.columns[#state.columns]
      for i, e in ipairs(col.entries) do
        if e.name == part then
          pcall(vim.api.nvim_win_set_cursor, col.win, { i, 0 })
          break
        end
      end
      push_column(path)
    end
    -- In the final column, place cursor on the actual file
    local col = state.columns[#state.columns]
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
