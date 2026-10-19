# shellcheck shell=bash
say "tmux"

if has tmux; then
  info "Already installed: $(tmux -V)"
elif has brew; then
  run brew install tmux
else
  warn "Skipping tmux install: Homebrew not found. Installing the config anyway."
fi

install_file "$REPO_DIR/tmux/tmux.conf" "$HOME/.tmux.conf" 644
install_file "$REPO_DIR/bin/tclaude" "$HOME/.local/bin/tclaude" 755

# Reload any running tmux server so the new config applies now.
if has tmux && tmux info >/dev/null 2>&1; then
  run tmux source-file "$HOME/.tmux.conf" || warn "Couldn't reload tmux; restart it to pick up the config."
fi

info "Run /terminal-setup once in Claude Code from your terminal app (outside tmux)"
info "if Shift+Enter doesn't insert a newline there."
