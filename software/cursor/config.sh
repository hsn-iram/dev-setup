# shellcheck shell=bash
say "Cursor config"

# The Claude Code extension (Anthropic, ID anthropic.claude-code) connects Cursor
# to the claude CLI: diffs open in the editor, and Claude sees your selection.
# Docs: https://code.claude.com/docs/en/vs-code
if ! has claude; then
  info "Skipping the Claude Code extension: Claude Code isn't installed (make claude-code)."
elif ! has cursor; then
  info "The cursor command isn't on PATH yet. To add the Claude Code extension:"
  info "open Cursor, press Cmd+Shift+X, search \"Claude Code\" (publisher: Anthropic), then Install."
elif cursor --list-extensions 2>/dev/null | grep -qi '^anthropic.claude-code$'; then
  info "Claude Code extension already installed in Cursor."
else
  run cursor --install-extension anthropic.claude-code \
    || warn "Couldn't install the extension from the CLI. In Cursor: Cmd+Shift+X, search \"Claude Code\"."
fi

info "Cursor's own settings aren't changed."
