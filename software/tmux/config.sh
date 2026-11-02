# shellcheck shell=bash
say "tmux config"

install_file "$STEP_DIR/tmux.conf" "$HOME/.tmux.conf" 644
install_file "$STEP_DIR/tclaude" "$HOME/.local/bin/tclaude" 755
install_file "$STEP_DIR/cheatsheet.txt" "$HOME/.config/tmux/cheatsheet.txt" 644

# Reload any running tmux server so the new config applies now.
if has tmux && tmux info >/dev/null 2>&1; then
  run tmux source-file "$HOME/.tmux.conf" || warn "Couldn't reload tmux; restart it to pick up the config."
fi

if has claude; then
  info "Run /terminal-setup once in Claude Code from your terminal app (outside tmux)"
  info "if Shift+Enter doesn't insert a newline there."
fi
