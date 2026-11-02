# shellcheck shell=bash
say "Node config"

# Load fnm in every new terminal, switching Node versions on cd.
if [[ -f "$RC_FILE" ]] && grep -v '^#' "$RC_FILE" | grep -q 'fnm env' \
   && ! grep -qxF '# >>> dev-setup fnm >>>' "$RC_FILE"; then
  info "$RC_FILE already loads fnm; leaving it as is."
else
  # shellcheck disable=SC2016  # literal $(...) wanted in the rc file
  write_rc_block 'eval "$(fnm env --use-on-cd --shell zsh)"' fnm
fi
