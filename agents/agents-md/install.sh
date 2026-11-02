# shellcheck shell=bash
say "Global AGENTS.md"

# One rules file for every agent, at each agent's global (all-projects) path.
# Links, so a git pull updates them all. Only for agents that are installed;
# run make agents-md again after installing one.
rules="$STEP_DIR/AGENTS.md"

# link_for COMMAND NAME DEST: link DEST if COMMAND is installed. If it isn't,
# remove a link this step made earlier; anything else at DEST is left alone.
link_for() {
  local cmd="$1" name="$2" dest="$3"
  if has "$cmd"; then
    if [[ -f "$dest" && ! -L "$dest" ]]; then
      warn "$dest is replaced by a link. Copy any of your own lines from the backup into agents/agents-md/AGENTS.md."
    fi
    link_path "$rules" "$dest"
  elif [[ -L "$dest" && "$(readlink "$dest")" == "$rules" ]]; then
    info "$name isn't installed; removing $dest"
    run rm "$dest"
  else
    info "$name isn't installed; skipping $dest"
  fi
}

# Claude Code reads CLAUDE.md, not AGENTS.md.
link_for claude "Claude Code" "$HOME/.claude/CLAUDE.md"
# Never creates ~/.codex early: IT checks for it to see their Codex rollout finished.
link_for codex Codex "${CODEX_HOME:-$HOME/.codex}/AGENTS.md"
link_for gemini "Gemini CLI" "$HOME/.gemini/GEMINI.md"
link_for opencode OpenCode "$HOME/.config/opencode/AGENTS.md"

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
