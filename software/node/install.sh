# shellcheck shell=bash
say "Node (with fnm)"

# fnm keeps several Node versions side by side and switches to a repo's version
# (.nvmrc or .node-version) when you cd into it. npm and npx come with Node.
if has fnm; then
  info "Already installed: $(fnm --version)"
else
  brew_install fnm
fi

# Install the latest LTS as the default version, unless there's a default already.
if [[ "$DRY_RUN" == "1" ]]; then
  info "[dry-run] fnm install --lts && fnm default lts-latest (if there's no default Node yet)"
elif fnm list 2>/dev/null | grep -q 'default'; then
  info "Default Node: $(fnm list | grep default | awk '{print $2}')"
else
  run fnm install --lts
  run fnm default lts-latest
fi
