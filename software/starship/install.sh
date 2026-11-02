# shellcheck shell=bash
say "Starship"

if has starship; then
  # Not starship --version: it creates ~/.cache/starship, even in a dry run.
  info "Already installed: $(command -v starship)"
else
  brew_install starship
fi
