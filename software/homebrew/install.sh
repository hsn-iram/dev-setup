# shellcheck shell=bash
say "Homebrew"

if has brew; then
  info "Already installed: $(command -v brew)"
else
  # Official installer (https://brew.sh). It's the one step that uses sudo: it asks
  # for your Mac password to create /opt/homebrew, so it needs an admin account.
  info "Homebrew's installer asks for your Mac password (it needs admin rights)."
  if [[ "$DRY_RUN" == "1" ]]; then
    # shellcheck disable=SC2016  # the command is printed, not run
    info '[dry-run] /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      [[ -x "$b" ]] && eval "$("$b" shellenv)" && break
    done
    has brew || die "brew isn't on PATH after install. Open a new terminal and re-run."
  fi
fi
