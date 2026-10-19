# shellcheck shell=bash
say "Agent skills and Claude Code rules"

# Skills in skills/ follow the open Agent Skills format (https://agentskills.io),
# so any agent that supports it can load them. Each one is symlinked from this
# repo, so a git pull updates them everywhere.
#
# Where they're linked (override with SKILL_DIRS="dir1 dir2"):
#   ~/.claude/skills  always. Claude Code reads it, and so do Cursor, Copilot in
#                     VS Code and OpenCode.
#   ~/.agents/skills  only if Codex or Gemini CLI is installed, since they don't
#                     read ~/.claude/skills. Cursor reads both folders and shows
#                     each skill twice, so we don't add this one unless needed.
if [[ -n "${SKILL_DIRS:-}" ]]; then
  read -r -a skill_dirs <<< "$SKILL_DIRS"
else
  skill_dirs=("$HOME/.claude/skills")
  if has codex || has gemini; then
    skill_dirs+=("$HOME/.agents/skills")
    info "Codex or Gemini CLI found: also linking into ~/.agents/skills (Cursor will list each skill twice)."
  fi
fi

skill_names=()
for skill in "$REPO_DIR"/skills/*/; do
  skill="${skill%/}"
  [[ -f "$skill/SKILL.md" ]] || continue
  skill_names+=("$(basename "$skill")")
  for dir in "${skill_dirs[@]}"; do
    link_path "$skill" "$dir/$(basename "$skill")"
  done
done

# Clean up links this repo made earlier: skills that were deleted or renamed,
# and folders we no longer link into. Real files are never touched.
for dir in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
  if [[ " ${skill_dirs[*]} " == *" $dir "* ]]; then
    prune_links "$dir" "$REPO_DIR/skills" ${skill_names[@]+"${skill_names[@]}"}
  else
    prune_links "$dir" "$REPO_DIR/skills"
  fi
done

# Personal rules for Claude Code. Claude Code loads every file in ~/.claude/rules/
# in every project, next to ~/.claude/CLAUDE.md. Installing here leaves your own
# ~/.claude/CLAUDE.md alone, so re-running never overwrites your edits.
install_file "$REPO_DIR/config/CLAUDE.md" "$HOME/.claude/rules/dev-setup.md" 644

# Earlier versions installed these rules as ~/.claude/CLAUDE.md itself.
OLD_CLAUDE_MD_SHA="aec4b598ffd17d0257e1bd57f974b9717e2c265d30db5d2276ed14d1b77002a3"
# shellcheck disable=SC2016  # literal backticks: the old file's header text
OLD_CLAUDE_MD_HEADER='Installed to `~/.claude/CLAUDE.md` by dev-setup'
if [[ -f "$HOME/.claude/CLAUDE.md" && ! -L "$HOME/.claude/CLAUDE.md" ]]; then
  if [[ "$(shasum -a 256 < "$HOME/.claude/CLAUDE.md" | cut -d' ' -f1)" == "$OLD_CLAUDE_MD_SHA" ]]; then
    backup="$HOME/.dev-setup-backup/$STAMP/.claude/CLAUDE.md"
    info "Moving the old unedited copy of these rules out of ~/.claude/CLAUDE.md -> $backup"
    run mkdir -p "$(dirname "$backup")"
    run mv "$HOME/.claude/CLAUDE.md" "$backup"
  elif grep -qF "$OLD_CLAUDE_MD_HEADER" "$HOME/.claude/CLAUDE.md"; then
    # shellcheck disable=SC2088  # display text
    warn "~/.claude/CLAUDE.md still holds an edited copy of the old dev-setup rules, so they load twice."
    info "Keep your own lines there and delete the dev-setup part. The rules now live in ~/.claude/rules/dev-setup.md."
  fi
fi

# Earlier versions installed these skills as the iram-skills Claude Code plugin.
if [[ "$DRY_RUN" != "1" ]] && has claude && claude plugin list 2>/dev/null | grep -q 'iram-skills@iram-skills'; then
  warn "The old iram-skills plugin is still installed, so its skills load twice."
  info "Remove it with: claude plugin uninstall iram-skills@iram-skills"
fi

info "Check skills after editing them: bin/validate-skills"
