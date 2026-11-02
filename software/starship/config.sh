# shellcheck shell=bash
say "Starship config"

# A symlink, so prompt tweaks happen in the repo.
link_path "$STEP_DIR/starship.toml" "$HOME/.config/starship.toml"
# shellcheck disable=SC2016
write_rc_block 'command -v starship >/dev/null && eval "$(starship init zsh)"' starship
