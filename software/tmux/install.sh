# shellcheck shell=bash
say "tmux"

if has tmux; then
  info "Already installed: $(tmux -V)"
else
  brew_install tmux
fi
