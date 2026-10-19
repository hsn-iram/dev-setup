# shellcheck shell=bash
say "Claude Code"

if has claude; then
  if [[ "$DRY_RUN" == "1" ]]; then info "Already installed: $(command -v claude)"
  else info "Already installed: $(claude --version 2>/dev/null || echo unknown)"; fi
elif [[ "$CLAUDE_VIA" == "brew" ]]; then
  has brew || die "--claude-via brew needs Homebrew."
  run brew install --cask claude-code
  info "Homebrew installs don't auto-update. Upgrade with: brew upgrade claude-code"
else
  # Official native installer from Anthropic (auto-updates, no Node needed).
  # Docs: https://code.claude.com/docs/en/setup
  info "Using Anthropic's official installer: https://claude.ai/install.sh"
  if [[ "$DRY_RUN" == "1" ]]; then
    info "[dry-run] curl -fsSL https://claude.ai/install.sh | bash"
  else
    curl -fsSL https://claude.ai/install.sh | bash
  fi
fi

# ~/.local/bin holds the native claude binary and the tclaude helper.
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
# shellcheck disable=SC2016  # literal $HOME/$PATH wanted in the rc file
write_rc_block 'export PATH="$HOME/.local/bin:$PATH"'

if [[ "$DRY_RUN" != "1" ]]; then
  has claude || die "claude isn't on PATH after install. Open a new terminal and re-run."
fi
