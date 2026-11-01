# shellcheck shell=bash
say "Preflight checks"

[[ "$EUID" -eq 0 ]] && die "Don't run this as root or with sudo. It only installs into your home folder."

if [[ "$(uname)" != "Darwin" ]]; then
  [[ "${ALLOW_NON_MAC:-0}" == "1" ]] || die "This script is for macOS. (ALLOW_NON_MAC=1 overrides, for testing.)"
  warn "Not macOS: continuing because ALLOW_NON_MAC=1"
fi

# Put Homebrew on PATH if it's installed but this shell doesn't know about it yet.
if ! has brew; then
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$b" ]] && eval "$("$b" shellenv)" && break
  done
fi
if has brew; then
  info "Homebrew: $(brew --version | head -1)"
else
  info "Homebrew isn't installed. Programs need it (make homebrew); config and agent steps don't."
fi

has git || warn "git not found. Run: xcode-select --install"

# Company policy: if IT manages Claude Code settings, those always win.
MANAGED="/Library/Application Support/ClaudeCode/managed-settings.json"
if [[ -f "$MANAGED" ]]; then
  warn "Company-managed Claude Code settings found: $MANAGED"
  info "Your org's policy overrides anything this script sets (plugins, login, permissions)."
  info "If a step below is blocked, that's the policy working. Don't work around it."
fi

if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
  warn "ANTHROPIC_API_KEY is set in your environment."
  info "Claude Code will use that key (API billing) instead of your claude.ai login."
  info "Remove it from your shell config if you meant to use a subscription or company account."
fi

info "Checks done."
