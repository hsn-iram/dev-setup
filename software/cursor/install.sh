# shellcheck shell=bash
say "Cursor"

if [[ -d "/Applications/Cursor.app" ]]; then
  info "Cursor is already installed."
else
  brew_install --cask cursor
fi
