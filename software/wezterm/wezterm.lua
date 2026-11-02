-- ~/.config/wezterm/wezterm.lua, linked from dev-setup (github.com/hsn-iram/dev-setup).
-- It's a symlink, so editing it edits the repo: WezTerm reloads on save, and git diff
-- shows the change. Machine-specific tweaks go in ~/.config/wezterm/local.lua (see the end).
--
-- WezTerm handles the look (font, colors, clipboard). tmux handles panes, windows and
-- sessions, so this config hides WezTerm's tab bar and opens straight into tmux.
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- --- Look ---------------------------------------------------------------------
-- Bundled with WezTerm, along with Nerd Font symbols as a fallback, so nothing to install.
config.font = wezterm.font 'JetBrains Mono'
config.font_size = 14
config.color_scheme = 'Catppuccin Mocha'
config.window_padding = { left = 8, right = 8, top = 6, bottom = 2 }
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.audible_bell = 'Disabled'

-- tmux keeps the session running, so closing the window loses nothing.
config.window_close_confirmation = 'NeverPrompt'

-- --- Start in tmux --------------------------------------------------------------
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

-- --- Keys -----------------------------------------------------------------------
config.keys = {
  -- Shift+Enter inserts a newline in Claude Code, inside or outside tmux.
  { key = 'Enter', mods = 'SHIFT', action = act.SendString '\x1b\r' },
  -- Escape hatch: a plain shell in a new tab, outside tmux.
  { key = 't', mods = 'CMD|SHIFT', action = act.SpawnCommandInNewTab { args = { '/bin/zsh', '-l' } } },
  -- Command palette (search every WezTerm action), the Mac way. Ctrl+Shift+P also works.
  { key = 'p', mods = 'CMD|SHIFT', action = act.ActivateCommandPalette },
}

-- --- Local overrides ------------------------------------------------------------
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
