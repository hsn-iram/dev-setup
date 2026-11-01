# shellcheck shell=bash
say "Agent skills"

# Each folder here is a skill in the open Agent Skills format (https://agentskills.io),
# so any agent that supports it can load it. Each one is symlinked from this
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

# Earlier versions kept skills in the repo's top-level skills/ folder. Remove
# links into it first, so they're replaced instead of backed up.
for dir in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
  prune_links "$dir" "$REPO_DIR/skills"
done

skill_names=()
for skill in "$STEP_DIR"/*/; do
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
    prune_links "$dir" "$STEP_DIR" ${skill_names[@]+"${skill_names[@]}"}
  else
    prune_links "$dir" "$STEP_DIR"
  fi
done

# Earlier versions installed these skills as the iram-skills Claude Code plugin.
if [[ "$DRY_RUN" != "1" ]] && has claude && claude plugin list 2>/dev/null | grep -q 'iram-skills@iram-skills'; then
  warn "The old iram-skills plugin is still installed, so its skills load twice."
  info "Remove it with: claude plugin uninstall iram-skills@iram-skills"
fi

info "Check skills after editing them: bin/validate-skills"
