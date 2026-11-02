# shellcheck shell=bash
say "Global AGENTS.md"

# One rules file for every agent, at each agent's global (all-projects) path.
# Links, so a git pull updates them all. Agents that aren't installed are
# skipped; run make agents-md again after installing one.
rules="$STEP_DIR/AGENTS.md"

# Claude Code reads CLAUDE.md, not AGENTS.md. Always linked.
if [[ -f "$HOME/.claude/CLAUDE.md" && ! -L "$HOME/.claude/CLAUDE.md" ]]; then
  # shellcheck disable=SC2088  # display text
  warn "~/.claude/CLAUDE.md is replaced by a link. Copy any of your own lines from the backup into agents/agents-md/AGENTS.md."
fi
link_path "$rules" "$HOME/.claude/CLAUDE.md"

# Not created before Codex is installed: IT checks for ~/.codex to see that
# their Codex rollout finished.
if has codex; then link_path "$rules" "${CODEX_HOME:-$HOME/.codex}/AGENTS.md"
else info "Codex isn't installed; skipping ~/.codex/AGENTS.md"; fi

if has gemini; then link_path "$rules" "$HOME/.gemini/GEMINI.md"
else info "Gemini CLI isn't installed; skipping ~/.gemini/GEMINI.md"; fi

if has opencode; then link_path "$rules" "$HOME/.config/opencode/AGENTS.md"
else info "OpenCode isn't installed; skipping ~/.config/opencode/AGENTS.md"; fi

# Cursor has no global AGENTS.md. Its global rules are .mdc files in
# ~/.cursor/rules, which need frontmatter to be always on, so this is a copy.
if [[ -d "$HOME/.cursor" ]] || has cursor; then
  tmp="$(mktemp)"
  { printf -- '---\ndescription: My global agent rules from dev-setup\nalwaysApply: true\n---\n'; cat "$rules"; } > "$tmp"
  install_file "$tmp" "$HOME/.cursor/rules/agents.mdc" 644
  rm -f "$tmp"
else
  info "Cursor isn't installed; skipping ~/.cursor/rules/agents.mdc"
fi

# Earlier versions copied these rules to ~/.claude/rules/dev-setup.md, so with
# ~/.claude/CLAUDE.md they'd load twice. Each run overwrote that copy, so it
# held no edits of its own.
old_rules="$HOME/.claude/rules/dev-setup.md"
if [[ -f "$old_rules" && ! -L "$old_rules" ]] \
   && grep -qF 'Installed by dev-setup to ~/.claude/rules/dev-setup.md' "$old_rules"; then
  backup="$HOME/.dev-setup-backup/$STAMP/.claude/rules/dev-setup.md"
  info "Moving the old copy of these rules out of $old_rules -> $backup"
  run mkdir -p "$(dirname "$backup")"
  run mv "$old_rules" "$backup"
fi
