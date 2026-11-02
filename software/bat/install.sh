# shellcheck shell=bash
say "bat"

if has bat; then
  info "Already installed: $(bat --version)"
else
  brew_install bat
fi
