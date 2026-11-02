# shellcheck shell=bash
say "Claude Code plugins (agents/claude-plugins/plugins.conf)"

# Claude Code only. Plain skills belong in agents/skills (they work in every agent);
# use a plugin only for what needs Claude Code itself, like hooks.
if ! has claude; then
  if [[ "$DRY_RUN" == "1" ]]; then
    info "[dry-run] claude isn't installed yet; plugin checks below are approximate."
  else
    warn "Skipping Claude Code plugins: Claude Code isn't installed. Install it with: make claude-code"
    return 0
  fi
fi

# In dry-run we don't call claude at all: even read-only commands create ~/.claude state.
has_marketplace() { [[ "$DRY_RUN" != "1" ]] && claude plugin marketplace list 2>/dev/null | grep -q -- "$1"; }
has_plugin()      { [[ "$DRY_RUN" != "1" ]] && claude plugin list 2>/dev/null | grep -q -- "$1@$2"; }

seen_markets=""; count=0
while IFS="|" read -r -u 3 src market plugin trust; do
  src="$(trim "$src")"
  [[ -z "$src" || "$src" == \#* ]] && continue
  market="$(trim "$market")"; plugin="$(trim "$plugin")"; trust="$(trim "$trust")"
  [[ "$src" == "local" ]] && src="$REPO_DIR"
  count=$((count + 1))

  if [[ "$trust" == "third-party" ]]; then
    warn "Third-party plugin: $plugin (from $src). It isn't from Anthropic or your company."
    confirm "Install $plugin?" || { info "Skipped $plugin"; continue; }
  fi

  # Add or refresh each marketplace once per run, even if it lists several plugins.
  if [[ " $seen_markets " != *" $market "* ]]; then
    seen_markets="$seen_markets $market"
    if has_marketplace "$market"; then
      run claude plugin marketplace update "$market" || warn "Couldn't update marketplace $market"
    else
      run claude plugin marketplace add "$src" || { warn "Couldn't add marketplace $src (blocked by policy?)"; continue; }
    fi
  fi

  if has_plugin "$plugin" "$market"; then
    if [[ "$src" == "$REPO_DIR" ]]; then
      # Pinned in this repo: move to the pinned commit if the pin changed.
      run claude plugin update "$plugin@$market" || warn "Couldn't update $plugin@$market"
    else
      info "Already installed: $plugin@$market"
    fi
  else
    run claude plugin install "$plugin@$market" --scope user || warn "Couldn't install $plugin@$market"
  fi
done 3< "$STEP_DIR/plugins.conf"

(( count > 0 )) || info "No plugins listed in plugins.conf; nothing to install."
