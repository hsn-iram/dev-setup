#!/usr/bin/env bash
# Checks are single-quoted strings that check() evals later, so $vars are meant
# to expand then, not here; "~" in check names is display text.
# shellcheck disable=SC2016,SC2034,SC2088
# tests/run.sh: end-to-end checks for install.sh, run against a throwaway HOME.
# Safe to run anywhere: it never touches your real home folder.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ALLOW_NON_MAC=1
fails=0
pass() { printf 'ok   %s\n' "$1"; }
fail() { printf 'FAIL %s\n' "$1"; fails=$((fails + 1)); }
check() { if eval "$2"; then pass "$1"; else fail "$1"; fi; }
fresh_home() { HOME="$(mktemp -d)"; export HOME; }
install() { "$REPO/install.sh" "$@" 2>&1; }

# 1. A typo in --only is rejected instead of silently running nothing.
fresh_home
check "unknown step name is rejected" '! install --only skill >/dev/null'

# 2. A full dry run creates nothing at all in a fresh home.
fresh_home
install --dry-run --yes >/dev/null
check "dry run leaves an empty home empty" '[[ -z "$(find "$HOME" -mindepth 1 | head -1)" ]]'

# 3. A real skills run links every skill and installs the rules file.
fresh_home
install --only skills >/dev/null
for s in "$REPO"/skills/*/; do
  n="$(basename "$s")"
  check "skill $n linked into ~/.claude/skills" '[[ "$(readlink "$HOME/.claude/skills/$n")" == "$REPO/skills/$n" ]]'
done
check "rules installed to ~/.claude/rules/dev-setup.md" 'cmp -s "$REPO/config/CLAUDE.md" "$HOME/.claude/rules/dev-setup.md"'
check "~/.claude/CLAUDE.md is not created" '[[ ! -e "$HOME/.claude/CLAUDE.md" ]]'
if ! command -v codex >/dev/null && ! command -v gemini >/dev/null; then
  check "~/.agents/skills not used without Codex or Gemini CLI" '[[ ! -e "$HOME/.agents/skills" ]]'
fi

# 4. Re-running changes nothing.
out="$(install --only skills)"
check "second run changes nothing" '! grep -qE "Linked|Installed|Backing up|Removing" <<< "$out"'

# 5. User edits to ~/.claude/CLAUDE.md survive a re-run.
echo "- my own rule" > "$HOME/.claude/CLAUDE.md"
install --only skills >/dev/null
check "own ~/.claude/CLAUDE.md is left alone" 'grep -q "my own rule" "$HOME/.claude/CLAUDE.md"'

# 6. Stale links are pruned; real folders and other links are not.
ln -s "$REPO/skills/deleted-skill" "$HOME/.claude/skills/deleted-skill"
mkdir -p "$HOME/.claude/skills/my-own-skill" "$HOME/.agents/skills"
ln -s /tmp "$HOME/.claude/skills/other-link"
ln -s "$REPO/skills/log-win" "$HOME/.agents/skills/log-win"
install --only skills >/dev/null
check "broken link to a deleted skill is removed" '[[ ! -L "$HOME/.claude/skills/deleted-skill" ]]'
check "link left in ~/.agents/skills by an old version is removed" '[[ ! -L "$HOME/.agents/skills/log-win" ]]'
check "your own skill folder is kept" '[[ -d "$HOME/.claude/skills/my-own-skill" ]]'
check "links that point elsewhere are kept" '[[ -L "$HOME/.claude/skills/other-link" ]]'

# 7. The old copy of the rules in ~/.claude/CLAUDE.md is moved out, if unedited.
if git -C "$REPO" cat-file -e 485b7c7 2>/dev/null; then
  fresh_home; mkdir -p "$HOME/.claude"
  git -C "$REPO" show 485b7c7:config/CLAUDE.md > "$HOME/.claude/CLAUDE.md"
  install --only skills >/dev/null
  check "old unedited ~/.claude/CLAUDE.md is moved to the backup folder" \
    '[[ ! -e "$HOME/.claude/CLAUDE.md" && -n "$(find "$HOME/.dev-setup-backup" -name CLAUDE.md)" ]]'
fi

# 8. Symlinked dotfiles are never replaced or written through.
fresh_home; mkdir -p "$HOME/dotfiles"
echo "alias ll='ls -l'" > "$HOME/dotfiles/zshrc"; ln -s "$HOME/dotfiles/zshrc" "$HOME/.zshrc"
echo "set -g mouse off" > "$HOME/dotfiles/tmux"; ln -s "$HOME/dotfiles/tmux" "$HOME/.tmux.conf"
(source "$REPO/lib/common.sh"; write_rc_block 'export X=1'; install_file "$REPO/tmux/tmux.conf" "$HOME/.tmux.conf") >/dev/null 2>&1
check "symlinked ~/.zshrc stays a symlink" '[[ -L "$HOME/.zshrc" ]]'
check "dotfiles zshrc is unchanged" '[[ "$(cat "$HOME/dotfiles/zshrc")" == "alias ll='"'"'ls -l'"'"'" ]]'
check "dotfiles tmux.conf is unchanged" '[[ "$(cat "$HOME/dotfiles/tmux")" == "set -g mouse off" ]]'

# 9. A damaged block in ~/.zshrc stops the script instead of deleting lines.
fresh_home
printf 'a\n# >>> mac-setup >>>\nexport OLD=1\nkeep_me\n' > "$HOME/.zshrc"
before="$(cat "$HOME/.zshrc")"
(source "$REPO/lib/common.sh"; write_rc_block 'export X=1') >/dev/null 2>&1; rc=$?
check "damaged block: script stops" '[[ $rc -ne 0 ]]'
check "damaged block: ~/.zshrc unchanged" '[[ "$(cat "$HOME/.zshrc")" == "$before" ]]'

# 10. A healthy block is replaced in place, and file permissions are kept.
printf 'a\n# >>> mac-setup >>>\nexport OLD=1\n# <<< mac-setup <<<\nb\n' > "$HOME/.zshrc"; chmod 644 "$HOME/.zshrc"
(source "$REPO/lib/common.sh"; write_rc_block 'export X=1') >/dev/null 2>&1
check "block replaced" 'grep -q "export X=1" "$HOME/.zshrc" && ! grep -q OLD "$HOME/.zshrc" && grep -qx b "$HOME/.zshrc"'
check "rc file permissions kept" '[[ "$(ls -l "$HOME/.zshrc" | cut -c1-10)" == "-rw-r--r--" ]]'

# 11. Every third-party plugin is pinned to a full commit SHA.
check "marketplace pins are full 40-char SHAs" \
  'python3 -c "import json,re,sys; m=json.load(open(\"$REPO/.claude-plugin/marketplace.json\")); sys.exit(not all(re.fullmatch(\"[0-9a-f]{40}\", p[\"source\"].get(\"sha\",\"\")) for p in m[\"plugins\"]))"'

echo
if (( fails )); then echo "$fails check(s) failed"; exit 1; fi
echo "All checks passed"
