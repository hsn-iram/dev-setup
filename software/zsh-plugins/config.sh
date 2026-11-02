# shellcheck shell=bash
say "zsh plugins config"

# Grey suggestions from history (→ or Ctrl+F accepts one), and commands colored as you
# type. Both use the theme's colors. Syntax highlighting has to load last.
# shellcheck disable=SC2016
write_rc_block '_dev_share="${HOMEBREW_PREFIX:-/opt/homebrew}/share"
[[ -r $_dev_share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source $_dev_share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r $_dev_share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source $_dev_share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
unset _dev_share' zsh-plugins
