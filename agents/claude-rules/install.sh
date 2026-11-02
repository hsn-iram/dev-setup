# shellcheck shell=bash
say "Claude Code rules"

# My rules themselves come from make agents-md (as ~/.claude/CLAUDE.md).

# i-have-adhd on for every session: its skill text, without the frontmatter, as
# a rules file. Claude Code loads every file in ~/.claude/rules/ in every
# project. No hook or Node needed. ADHD_ALWAYS_ON=0 skips it.
adhd_skill="$PUBLIC_SKILLS_DIR/i-have-adhd/SKILL.md"
adhd_rule="$HOME/.claude/rules/i-have-adhd.md"
if [[ "${ADHD_ALWAYS_ON:-1}" != "1" ]]; then
  [[ -f "$adhd_rule" ]] && info "ADHD_ALWAYS_ON=0: delete $adhd_rule to turn always-on off."
elif [[ -f "$adhd_skill" ]]; then
  tmp="$(mktemp)"
  awk 'NR == 1 && /^---$/ {fm = 1; next} fm && /^---$/ {fm = 0; next} !fm' "$adhd_skill" > "$tmp"
  install_file "$tmp" "$adhd_rule" 644
  rm -f "$tmp"
  info "i-have-adhd is on for every Claude Code session (ADHD_ALWAYS_ON=0 to skip)."
else
  info "i-have-adhd isn't downloaded yet, so it isn't on for every session. Run: make skills claude-rules"
fi
if [[ -f "$HOME/.claude/.i-have-adhd-always" ]]; then
  # shellcheck disable=SC2088  # display text
  info "~/.claude/.i-have-adhd-always is from the old plugin; you can delete it."
fi
