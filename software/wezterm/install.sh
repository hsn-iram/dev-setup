# shellcheck shell=bash
say "WezTerm"

if [[ -d "/Applications/WezTerm.app" ]]; then
  info "WezTerm is already installed."
else
  brew_install --cask wezterm
fi

if compgen -G "$HOME/Library/Fonts/JetBrainsMonoNerdFont*" >/dev/null \
   || compgen -G "/Library/Fonts/JetBrainsMonoNerdFont*" >/dev/null; then
  info "JetBrains Mono Nerd Font is already installed."
else
  brew_install --cask font-jetbrains-mono-nerd-font
fi
