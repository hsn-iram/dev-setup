# shellcheck shell=bash
say "WezTerm"

# No font to install: WezTerm bundles JetBrains Mono and the Nerd Font symbols.
if [[ -d "/Applications/WezTerm.app" ]]; then
  info "WezTerm is already installed."
else
  brew_install --cask wezterm
fi
