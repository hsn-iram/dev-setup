# shellcheck shell=bash
say "Cursor"

if [[ -d "/Applications/Cursor.app" ]]; then
  info "Cursor is already installed."
elif has brew; then
  info "Cursor is a third-party app (Anysphere). Check it's approved at work before installing."
  if confirm "Install Cursor with Homebrew?"; then
    run brew install --cask cursor
  else
    info "Skipped Cursor."; return 0
  fi
else
  warn "Skipping Cursor: Homebrew not found. Download it from https://cursor.com if your company allows it."
  return 0
fi

# The Claude Code extension (Anthropic, ID anthropic.claude-code) connects Cursor
# to the claude CLI: diffs open in the editor, and Claude sees your selection.
# Docs: https://code.claude.com/docs/en/vs-code
if has cursor; then
  if cursor --list-extensions 2>/dev/null | grep -qi '^anthropic.claude-code$'; then
    info "Claude Code extension already installed in Cursor."
  else
    run cursor --install-extension anthropic.claude-code \
      || warn "Couldn't install the extension from the CLI. In Cursor: Cmd+Shift+X, search \"Claude Code\"."
  fi
else
  info "The cursor command isn't on PATH yet. To add the extension:"
  info "open Cursor, press Cmd+Shift+X, search \"Claude Code\" (publisher: Anthropic), then Install."
fi

info "We don't change your Cursor settings. In Cursor's terminal, run claude, then /ide if it doesn't connect."
