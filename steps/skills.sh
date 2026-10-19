# shellcheck shell=bash
say "Agent skills and CLAUDE.md"

# Skills in skills/ follow the open Agent Skills format (https://agentskills.io),
# so any agent that supports it can load them. Each one is symlinked from this
# repo, so a git pull updates them everywhere.
#   ~/.agents/skills  Codex, Cursor, GitHub Copilot, Gemini CLI, OpenCode
#   ~/.claude/skills  Claude Code
read -r -a skill_dirs <<< "${SKILL_DIRS:-$HOME/.agents/skills $HOME/.claude/skills}"

for skill in "$REPO_DIR"/skills/*/; do
  skill="${skill%/}"
  [[ -f "$skill/SKILL.md" ]] || continue
  for dir in "${skill_dirs[@]}"; do
    link_path "$skill" "$dir/$(basename "$skill")"
  done
done

# User-level instructions for Claude Code (applies in every project).
install_file "$REPO_DIR/config/CLAUDE.md" "$HOME/.claude/CLAUDE.md" 644

# Earlier versions installed these skills as the iram-skills Claude Code plugin.
if [[ "$DRY_RUN" != "1" ]] && has claude && claude plugin list 2>/dev/null | grep -q 'iram-skills@iram-skills'; then
  warn "The old iram-skills plugin is still installed, so its skills load twice."
  info "Remove it with: claude plugin uninstall iram-skills@iram-skills"
fi

info "Check skills after editing them: bin/validate-skills"
