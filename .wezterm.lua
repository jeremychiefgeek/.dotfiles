local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Theme plugin
local rp_plugin = wezterm.plugin.require("https://github.com/neapsix/wezterm")
local theme = rp_plugin.main

-- ------------------------------------------------------------
-- Basics
-- ------------------------------------------------------------
config.default_prog = { "powershell.exe", "-NoLogo" }
config.default_cwd = "$HOME/games"

config.initial_cols = 120
config.initial_rows = 28
config.scrollback_lines = 15000

-- ------------------------------------------------------------
-- Fonts
-- ------------------------------------------------------------
config.font = wezterm.font_with_fallback({
  "FiraMono Nerd Font",
  "JetBrainsMono Nerd Font",
  "Cascadia Mono NF",
})
config.font_size = 11.0
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"

-- ------------------------------------------------------------
-- Colors / Theme
-- ------------------------------------------------------------
config.colors = theme.colors()
config.window_frame = theme.window_frame()

config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 650

-- ------------------------------------------------------------
-- Window polish
-- ------------------------------------------------------------
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.integrated_title_button_style = "Windows"
config.integrated_title_button_alignment = "Right"

config.window_padding = {
  left = 14,
  right = 14,
  top = 12,
  bottom = 10,
}

config.window_background_opacity = 0.92
config.win32_system_backdrop = "Acrylic"
config.text_background_opacity = 1.0

config.window_background_gradient = {
  orientation = "Vertical",
  interpolation = "Linear",
  blend = "Rgb",
  colors = {
    "#0b0f14",
    "#0b0f14",
    "#0e141c",
  },
}

-- ------------------------------------------------------------
-- Tab bar
-- ------------------------------------------------------------
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

-- ------------------------------------------------------------
-- Leader key
-- ------------------------------------------------------------
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1200 }

config.keys = {
  { key = "\\", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "-", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

  { key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },

  { key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
  { key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },

  { key = "n", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },
}

-- ------------------------------------------------------------
-- Helpers
-- ------------------------------------------------------------
local function basename(s)
  return s:gsub("(.*[/\\])", "")
end

-- ------------------------------------------------------------
-- Tab titles (FIXED)
-- ------------------------------------------------------------
wezterm.on("format-tab-title", function(tab)
  local pane = tab.active_pane
  local cwd_uri = pane.current_working_dir and pane.current_working_dir.file_path or ""
  local cwd = cwd_uri ~= "" and basename(cwd_uri) or "shell"
  local idx = tab.tab_index + 1

  return {
    {
      Text = "  " .. idx .. "  " .. cwd .. "  ",
    },
  }
end)

-- ------------------------------------------------------------
-- Right status
-- ------------------------------------------------------------
wezterm.on("update-right-status", function(window, pane)
  local cwd_uri = pane.current_working_dir and pane.current_working_dir.file_path or ""
  local cwd = cwd_uri ~= "" and basename(cwd_uri) or ""
  local date = wezterm.strftime("%a %b %d  %I:%M %p")

  window:set_right_status(wezterm.format({
    { Attribute = { Intensity = "Half" } },
    { Text = "  " .. cwd .. "  " .. date .. "  " },
  }))
end)

-- ------------------------------------------------------------
-- QoL
-- ------------------------------------------------------------
config.audible_bell = "Disabled"
config.warn_about_missing_glyphs = false

return config

