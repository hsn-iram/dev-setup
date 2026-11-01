# shellcheck shell=bash
say "uv"

# Python tool runner and package manager (Astral). bin/validate-skills uses its
# uvx to run the skill validator without installing anything globally.
if has uv; then
  info "Already installed: $(uv --version)"
else
  brew_install uv
fi
