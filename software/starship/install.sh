# shellcheck shell=bash
say "Starship"

if has starship; then
  info "Already installed: $(starship --version | head -1)"
else
  brew_install starship
fi
