# shellcheck shell=bash
say "Agent skills (mine + public)"

# Skills use the open Agent Skills format (https://agentskills.io), so any agent
# that supports it can load them: my own (folders here) and the public ones in
# public.conf, each pinned to a reviewed commit. All are symlinked, so a git pull
# plus make skills updates every agent at once.
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

# --- Public skills: download each at its pinned commit ------------------------
PUBLIC_CONF="${PUBLIC_SKILLS_CONF:-$STEP_DIR/public.conf}"
skill_names=(); public_names=(); public_paths=()
while IFS="|" read -r -u 3 repo sha path trust; do
  repo="$(trim "$repo")"
  [[ -z "$repo" || "$repo" == \#* ]] && continue
  sha="$(trim "$sha")"; path="$(trim "$path")"; trust="$(trim "$trust")"
  name="$(basename "$path")"
  [[ "$sha" =~ ^[0-9a-f]{40}$ ]] || die "public.conf: $name needs a full 40-character commit, got '$sha'"
  [[ -f "$STEP_DIR/$name/SKILL.md" ]] && die "public.conf: $name has the same name as one of my skills"
  dest="$PUBLIC_SKILLS_DIR/$name"
  if [[ -f "$dest/.dev-setup-pin" && "$(cat "$dest/.dev-setup-pin")" == "$repo@$sha" ]]; then
    info "Up to date: $name ($trust, $repo@${sha:0:7})"
  elif [[ "$DRY_RUN" == "1" ]]; then
    info "[dry-run] download $name ($trust) from $repo@${sha:0:7}"
  else
    info "Downloading $name ($trust) from $repo@${sha:0:7}"
    tmp="$(mktemp -d)"
    if curl -fsSL "https://codeload.github.com/$repo/tar.gz/$sha" \
         | tar -xz -C "$tmp" "${repo#*/}-$sha/$path" \
       && [[ -f "$tmp/${repo#*/}-$sha/$path/SKILL.md" ]]; then
      rm -rf "$dest"; mkdir -p "$PUBLIC_SKILLS_DIR"
      mv "$tmp/${repo#*/}-$sha/$path" "$dest"
      echo "$repo@$sha" > "$dest/.dev-setup-pin"
    else
      warn "Couldn't download $name from $repo@${sha:0:7}; skipping it."
    fi
    rm -rf "$tmp"
  fi
  public_names+=("$name"); public_paths+=("$dest")
done 3< "$PUBLIC_CONF"

# --- Link my skills and the public ones into each agent's folder ---------------
for skill in "$STEP_DIR"/*/; do
  skill="${skill%/}"
  [[ -f "$skill/SKILL.md" ]] || continue
  skill_names+=("$(basename "$skill")")
  for dir in "${skill_dirs[@]}"; do
    link_path "$skill" "$dir/$(basename "$skill")"
  done
done
i=0
while (( i < ${#public_names[@]} )); do
  if [[ -d "${public_paths[$i]}" || "$DRY_RUN" == "1" ]]; then
    for dir in "${skill_dirs[@]}"; do
      link_path "${public_paths[$i]}" "$dir/${public_names[$i]}"
    done
  fi
  i=$((i + 1))
done

# Clean up links this repo made earlier: skills that were deleted, renamed or
# removed from public.conf, and folders we no longer link into. Real files are
# never touched.
for dir in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
  if [[ " ${skill_dirs[*]} " == *" $dir "* ]]; then
    prune_links "$dir" "$STEP_DIR" ${skill_names[@]+"${skill_names[@]}"}
    prune_links "$dir" "$PUBLIC_SKILLS_DIR" ${public_names[@]+"${public_names[@]}"}
  else
    prune_links "$dir" "$STEP_DIR"
    prune_links "$dir" "$PUBLIC_SKILLS_DIR"
  fi
done

# Earlier versions installed these skills as Claude Code plugins. Two copies of a
# skill both load, so point out the plugin copies.
if [[ "$DRY_RUN" != "1" ]] && has claude; then
  plugins="$(claude plugin list 2>/dev/null || true)"
  for old in iram-skills@iram-skills i-have-adhd@dev-setup caveman@dev-setup \
             i-have-adhd@i-have-adhd caveman@caveman \
             document-skills@anthropic-agent-skills example-skills@anthropic-agent-skills; do
    if grep -q -- "$old" <<< "$plugins"; then
      warn "Old plugin copy still installed: $old. Its skills now come from make skills, so they load twice."
      info "Remove it with: claude plugin uninstall $old"
    fi
  done
fi

info "Check my skills after editing them: bin/validate-skills"
