# shellcheck shell=bash
say "Claude Code rules"

# Claude Code loads every file in ~/.claude/rules/ in every project, next to
# ~/.claude/CLAUDE.md. Installing here leaves your own ~/.claude/CLAUDE.md alone.
install_file "$STEP_DIR/CLAUDE.md" "$HOME/.claude/rules/dev-setup.md" 644

# i-have-adhd on for every session: its skill text, without the frontmatter, as
# a rules file. No hook or Node needed. ADHD_ALWAYS_ON=0 skips it.
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
# shellcheck disable=SC2088  # display text
[[ -f "$HOME/.claude/.i-have-adhd-always" ]] && info "~/.claude/.i-have-adhd-always is from the old plugin; you can delete it."

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
