-- pack.lua - Simple plugin manager
-- Plugins are git cloned into ~/.config/nvim/plugins/
-- and loaded via vim.opt.runtimepath.
--
-- Usage in init.lua:
--   local pack = require("pack")
--   pack.setup({
--     "nvim-lua/plenary.nvim",
--     "nvim-telescope/telescope.nvim",
--   })
--
-- Commands:
--   :PackInstall  - install any missing plugins
--   :PackUpdate   - update all installed plugins
--   :PackClean    - remove plugins no longer in the list

local M = {}

local plugin_dir = vim.fn.stdpath("config") .. "/plugins"
local registry   = {}   -- list of { name, url, dir }

-- ── Helpers ───────────────────────────────────────────────────────────────────
local function short_name(spec)
  -- "author/repo" -> "repo",  full URLs -> last path segment
  return spec:match("([^/]+)$"):gsub("%.git$", "")
end

local function plugin_url(spec)
  if spec:match("^https?://") then return spec end
  return "https://github.com/" .. spec .. ".git"
end

local function installed_dirs()
  local dirs = {}
  local handle = vim.loop.fs_scandir(plugin_dir)
  if not handle then return dirs end
  while true do
    local name, ftype = vim.loop.fs_scandir_next(handle)
    if not name then break end
    if ftype == "directory" then dirs[name] = true end
  end
  return dirs
end

-- ── UI ────────────────────────────────────────────────────────────────────────
local ui = {
  buf = nil,
  win = nil,
  lines = {},
}

local function ui_open()
  ui.lines = {}
  ui.buf   = vim.api.nvim_create_buf(false, true)
  vim.bo[ui.buf].buftype   = "nofile"
  vim.bo[ui.buf].bufhidden = "wipe"
  vim.bo[ui.buf].filetype  = "jeremy_pack"

  local width  = 60
  local height = 20
  ui.win = vim.api.nvim_open_win(ui.buf, true, {
    relative  = "editor",
    width     = width,
    height    = height,
    row       = math.floor((vim.o.lines   - height) / 2),
    col       = math.floor((vim.o.columns - width)  / 2),
    style     = "minimal",
    border    = "rounded",
    title     = " Pack ",
    title_pos = "center",
    zindex    = 60,
  })

  vim.wo[ui.win].winhighlight = table.concat({
    "Normal:ExplorerNormal",
    "NormalFloat:ExplorerNormal",
    "FloatBorder:ExplorerBorder",
    "FloatTitle:ExplorerTitle",
  }, ",")

  vim.keymap.set("n", "q",     function() ui_close() end, { buffer = ui.buf, noremap = true })
  vim.keymap.set("n", "<Esc>", function() ui_close() end, { buffer = ui.buf, noremap = true })
end

function ui_close()
  if ui.win and vim.api.nvim_win_is_valid(ui.win) then
    vim.api.nvim_win_close(ui.win, true)
  end
  ui.buf = nil
  ui.win = nil
end

local function ui_set(lines)
  if not ui.buf or not vim.api.nvim_buf_is_valid(ui.buf) then return end
  vim.bo[ui.buf].modifiable = true
  vim.api.nvim_buf_set_lines(ui.buf, 0, -1, false, lines)
  vim.bo[ui.buf].modifiable = false
  -- Scroll to bottom
  if ui.win and vim.api.nvim_win_is_valid(ui.win) then
    vim.api.nvim_win_set_cursor(ui.win, { #lines, 0 })
  end
end

local function ui_append(line)
  table.insert(ui.lines, line)
  ui_set(ui.lines)
  vim.cmd("redraw")
end

local function ui_update_last(line)
  if #ui.lines == 0 then
    ui_append(line)
  else
    ui.lines[#ui.lines] = line
    ui_set(ui.lines)
    vim.cmd("redraw")
  end
end

-- ── Git operations ────────────────────────────────────────────────────────────
local function git_clone(url, dir, on_done)
  local stdout = {}
  local stderr = {}
  vim.fn.jobstart({ "git", "clone", "--depth=1", url, dir }, {
    on_stdout = function(_, data) vim.list_extend(stdout, data) end,
    on_stderr = function(_, data) vim.list_extend(stderr, data) end,
    on_exit   = function(_, code)
      vim.schedule(function() on_done(code == 0, stderr) end)
    end,
  })
end

local function git_pull(dir, on_done)
  local stderr = {}
  local stdout = {}
  vim.fn.jobstart({ "git", "-C", dir, "pull", "--ff-only" }, {
    on_stdout = function(_, data) vim.list_extend(stdout, data) end,
    on_stderr = function(_, data) vim.list_extend(stderr, data) end,
    on_exit   = function(_, code)
      vim.schedule(function()
        local out = table.concat(stdout, " ")
        local already = out:match("Already up to date") ~= nil
        on_done(code == 0, already, stderr)
      end)
    end,
  })
end

-- ── Commands ──────────────────────────────────────────────────────────────────
function M.install()
  vim.fn.mkdir(plugin_dir, "p")
  ui_open()
  ui_append("  PackInstall")
  ui_append("")

  local pending = 0
  local done    = 0

  for _, p in ipairs(registry) do
    if vim.fn.isdirectory(p.dir) == 0 then
      pending = pending + 1
      local label = "  ⟳ " .. p.name .. " installing..."
      ui_append(label)
      local line_idx = #ui.lines

      git_clone(p.url, p.dir, function(ok, _err)
        if ok then
          -- source the plugin now without restart
          vim.opt.runtimepath:append(p.dir)
          vim.cmd("silent! packadd " .. p.name)
          ui.lines[line_idx] = "  ✓ " .. p.name
        else
          ui.lines[line_idx] = "  ✗ " .. p.name .. " (failed)"
        end
        done = done + 1
        ui_set(ui.lines)
        vim.cmd("redraw")
        if done == pending then
          ui_append("")
          ui_append("  Done. Press q to close.")
        end
      end)
    end
  end

  if pending == 0 then
    ui_append("  All plugins already installed.")
    ui_append("")
    ui_append("  Press q to close.")
  end
end

function M.update()
  ui_open()
  ui_append("  PackUpdate")
  ui_append("")

  local total = #registry
  local done  = 0

  if total == 0 then
    ui_append("  No plugins registered.")
    ui_append("")
    ui_append("  Press q to close.")
    return
  end

  for _, p in ipairs(registry) do
    if vim.fn.isdirectory(p.dir) == 0 then
      ui_append("  - " .. p.name .. " (not installed, run :PackInstall)")
      done = done + 1
    else
      local label = "  ⟳ " .. p.name .. " updating..."
      ui_append(label)
      local line_idx = #ui.lines

      git_pull(p.dir, function(ok, already, _err)
        if not ok then
          ui.lines[line_idx] = "  ✗ " .. p.name .. " (failed)"
        elseif already then
          ui.lines[line_idx] = "  ✓ " .. p.name .. " (up to date)"
        else
          ui.lines[line_idx] = "  ↑ " .. p.name .. " (updated)"
        end
        done = done + 1
        ui_set(ui.lines)
        vim.cmd("redraw")
        if done == total then
          ui_append("")
          ui_append("  Done. Press q to close.")
        end
      end)
    end
  end
end

function M.clean()
  ui_open()
  ui_append("  PackClean")
  ui_append("")

  local registered = {}
  for _, p in ipairs(registry) do registered[p.name] = true end

  local installed = installed_dirs()
  local removed   = 0

  for name, _ in pairs(installed) do
    if not registered[name] then
      local dir = plugin_dir .. "/" .. name
      vim.fn.delete(dir, "rf")
      ui_append("  ✗ removed " .. name)
      removed = removed + 1
    end
  end

  if removed == 0 then
    ui_append("  Nothing to clean.")
  end
  ui_append("")
  ui_append("  Done. Press q to close.")
end

-- ── Setup ─────────────────────────────────────────────────────────────────────
function M.setup(specs)
  vim.fn.mkdir(plugin_dir, "p")

  for _, spec in ipairs(specs) do
    local name = short_name(spec)
    local dir  = plugin_dir .. "/" .. name
    table.insert(registry, { name = name, url = plugin_url(spec), dir = dir })
    -- Add to runtimepath if already installed
    if vim.fn.isdirectory(dir) == 1 then
      vim.opt.runtimepath:append(dir)
      -- Run plugin's init if present
      local init = dir .. "/plugin"
      if vim.fn.isdirectory(init) == 1 then
        vim.cmd("silent! runtime! " .. init .. "/**/*.vim")
        vim.cmd("silent! runtime! " .. init .. "/**/*.lua")
      end
    end
  end

  -- Register commands
  vim.api.nvim_create_user_command("PackInstall", function() M.install() end, {})
  vim.api.nvim_create_user_command("PackUpdate",  function() M.update()  end, {})
  vim.api.nvim_create_user_command("PackClean",   function() M.clean()   end, {})
end

return M
