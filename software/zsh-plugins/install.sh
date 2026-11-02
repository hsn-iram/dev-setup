# shellcheck shell=bash
say "zsh plugins"

for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  if has brew && [[ -d "$(brew --prefix)/share/$plugin" ]]; then
    info "Already installed: $plugin"
  else
    brew_install "$plugin"
  fi
done
