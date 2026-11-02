-- ~/.config/wezterm/wezterm.lua, linked from dev-setup (github.com/hsn-iram/dev-setup).
-- It's a symlink, so editing it edits the repo: WezTerm reloads on save, and git diff
-- shows the change. Machine-specific tweaks go in ~/.config/wezterm/local.lua (see the end).
--
-- WezTerm handles the look (font, colors, transparency). tmux handles panes, windows and
-- sessions, so this config hides WezTerm's tab bar and title bar and opens straight into tmux.
-- Inspired by Kun Chen's config (github.com/kunchenguid/dotfiles).

local wezterm = require 'wezterm' ---@type Wezterm
local act = wezterm.action
local config = wezterm.config_builder()

-- --- Settings to tweak ------------------------------------------------------------
-- Themes Cmd+Shift+L cycles through. The first is the default. Any name from
-- wezterm.org/colorschemes works.
local THEMES = {
  'rose-pine-moon', -- muted purples and soft rose
  'Catppuccin Mocha', -- soft pastels on dark blue-grey
  'Tokyo Night', -- cool blues and violets
  'Kanagawa (Gogh)', -- warm ink-painting tones
}
local FONT_SIZE = 15
local OPACITY = 0.8 -- 1.0 is solid. Cmd+Shift+O switches between this and solid.
local BLUR = 50 -- Blurs whatever is behind the window, so text stays readable on any wallpaper.
local UNFOCUSED_OPACITY = 0.62 -- Unfocused windows fade further...
local UNFOCUSED_TEXT = { hue = 1.0, saturation = 0.25, brightness = 0.45 } -- ...and dim their text.

-- --- Theme: remembered between restarts -------------------------------------------
-- The current theme's name lives in this file. It's outside the repo, so switching
-- themes never shows up in git.
local THEME_FILE = wezterm.home_dir .. '/.config/wezterm/theme'

local function saved_theme()
  local f = io.open(THEME_FILE, 'r')
  if not f then
    return THEMES[1]
  end
  local name = f:read 'l'
  f:close()
  for _, theme in ipairs(THEMES) do
    if theme == name then
      return name
    end
  end
  return THEMES[1]
end

local function use_theme(name)
  local f = io.open(THEME_FILE, 'w')
  if f then
    f:write(name, '\n')
    f:close()
  end
  wezterm.reload_configuration()
end

local function next_theme()
  local current = saved_theme()
  for i, theme in ipairs(THEMES) do
    if theme == current then
      return THEMES[i % #THEMES + 1]
    end
  end
  return THEMES[1]
end

-- --- Look -------------------------------------------------------------------------
config.color_scheme = saved_theme()

-- Tab bar colors come from the theme too, matching tmux: the accent color (magenta)
-- marks the active tab, and the rest stay dim. Shows when there's a second tab.
local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]
if scheme then
  local accent, dim = scheme.ansi[6], scheme.brights[1]
  config.colors = {
    tab_bar = {
      background = scheme.background,
      active_tab = { bg_color = accent, fg_color = scheme.background, intensity = 'Bold' },
      inactive_tab = { bg_color = scheme.background, fg_color = dim },
      inactive_tab_hover = { bg_color = scheme.background, fg_color = scheme.foreground },
      new_tab = { bg_color = scheme.background, fg_color = dim },
      new_tab_hover = { bg_color = scheme.background, fg_color = accent },
    },
  }
end
-- Bundled with WezTerm, along with Nerd Font symbols as a fallback, so nothing to install.
config.font = wezterm.font 'JetBrains Mono'
config.font_size = FONT_SIZE
config.line_height = 1.1
config.window_padding = { left = 12, right = 12, top = 10, bottom = 6 }
config.window_decorations = 'RESIZE' -- No title bar. Cmd+drag moves the window.
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.audible_bell = 'Disabled'
config.max_fps = 120

-- wezterm.GLOBAL survives config reloads, so Cmd+Shift+O's choice sticks until you quit.
config.window_background_opacity = wezterm.GLOBAL.solid and 1.0 or OPACITY
config.macos_window_background_blur = BLUR

-- tmux keeps the session running, so closing the window loses nothing.
config.window_close_confirmation = 'NeverPrompt'

-- --- Fade unfocused windows ---------------------------------------------------------
-- Overrides apply to one window on top of the config above.
local function same_hsb(a, b)
  if a == nil or b == nil then
    return a == b
  end
  return a.hue == b.hue and a.saturation == b.saturation and a.brightness == b.brightness
end

wezterm.on('window-focus-changed', function(window)
  local overrides = window:get_config_overrides() or {}
  local text, opacity
  if not window:is_focused() then
    text = UNFOCUSED_TEXT
    opacity = not wezterm.GLOBAL.solid and UNFOCUSED_OPACITY or nil
  end
  -- Each set_config_overrides() call reloads the window, so skip it when nothing changed.
  if same_hsb(overrides.foreground_text_hsb, text) and overrides.window_background_opacity == opacity then
    return
  end
  overrides.foreground_text_hsb = text
  overrides.window_background_opacity = opacity
  window:set_config_overrides(overrides)
end)

-- --- Start in tmux ------------------------------------------------------------------
-- Apps opened from the Dock don't get Homebrew on PATH, so look for tmux directly.
-- If it isn't installed, WezTerm opens a normal shell instead.
for _, tmux in ipairs { '/opt/homebrew/bin/tmux', '/usr/local/bin/tmux' } do
  local f = io.open(tmux, 'r')
  if f then
    f:close()
    -- Attach to the session "main", or create it if it doesn't exist yet.
    config.default_prog = { tmux, 'new-session', '-A', '-s', 'main' }
    break
  end
end

-- --- Keys ---------------------------------------------------------------------------
config.keys = {
  -- Shift+Enter inserts a newline in Claude Code, inside or outside tmux.
  { key = 'Enter', mods = 'SHIFT', action = act.SendString '\x1b\r' },
  -- Escape hatch: a plain shell in a new tab, outside tmux.
  { key = 't', mods = 'CMD|SHIFT', action = act.SpawnCommandInNewTab { args = { '/bin/zsh', '-l' } } },
  -- Command palette (search every WezTerm action), the Mac way. Ctrl+Shift+P also works.
  { key = 'p', mods = 'CMD|SHIFT', action = act.ActivateCommandPalette },
  -- Next theme ("look").
  {
    key = 'l',
    mods = 'CMD|SHIFT',
    action = wezterm.action_callback(function()
      use_theme(next_theme())
    end),
  },
  -- Solid or see-through ("opaque"), for screen sharing or a busy background.
  {
    key = 'o',
    mods = 'CMD|SHIFT',
    action = wezterm.action_callback(function()
      wezterm.GLOBAL.solid = not wezterm.GLOBAL.solid
      wezterm.reload_configuration()
    end),
  },
}

-- Every theme is also in the command palette: Cmd+Shift+P, then type "theme".
wezterm.on('augment-command-palette', function()
  local entries = {}
  for _, theme in ipairs(THEMES) do
    table.insert(entries, {
      brief = 'Theme: ' .. theme,
      icon = 'md_palette',
      action = wezterm.action_callback(function()
        use_theme(theme)
      end),
    })
  end
  return entries
end)

-- --- Local overrides ----------------------------------------------------------------
-- ~/.config/wezterm/local.lua is not in git. It should return a function that
-- changes config, for example:
--   return function(config) config.font_size = 16 end
local local_file = wezterm.home_dir .. '/.config/wezterm/local.lua'
local f = io.open(local_file, 'r')
if f then
  f:close()
  wezterm.add_to_config_reload_watch_list(local_file)
  dofile(local_file)(config)
end

return config
