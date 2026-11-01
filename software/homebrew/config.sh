# shellcheck shell=bash
say "Homebrew config"

# Put brew on PATH in new terminals. /opt/homebrew on Apple silicon, /usr/local on Intel.
brew_bin=""
for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [[ -x "$b" ]] && { brew_bin="$b"; break; }
done
if [[ -n "$brew_bin" ]]; then
  write_rc_block "eval \"\$($brew_bin shellenv)\"" homebrew
else
  info "Homebrew isn't installed, so there's nothing to configure (make homebrew)."
fi
