# shellcheck shell=bash
say "WezTerm config"

# A symlink, not a copy: WezTerm reloads on save, and edits show up in git diff.
link_path "$STEP_DIR/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"

if [[ -e "$HOME/.wezterm.lua" ]]; then
  info "WezTerm now ignores ~/.wezterm.lua. Move anything you need from it into"
  info "~/.config/wezterm/local.lua (see the end of wezterm.lua)."
fi
if [[ "$DRY_RUN" != "1" ]] && ! has tmux; then
  info "tmux isn't installed, so WezTerm opens a plain shell. To start in tmux: make tmux"
fi
