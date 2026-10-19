# shellcheck shell=bash
say "Claude Code plugins (config/plugins.conf)"

if ! has claude; then
  if [[ "$DRY_RUN" == "1" ]]; then
    info "[dry-run] claude isn't installed yet; plugin checks below are approximate."
  else
    die "Claude Code isn't installed. Run the claude step first."
  fi
fi

# In dry-run we don't call claude at all: even read-only commands create ~/.claude state.
has_marketplace() { [[ "$DRY_RUN" != "1" ]] && claude plugin marketplace list 2>/dev/null | grep -q -- "$1"; }
has_plugin()      { [[ "$DRY_RUN" != "1" ]] && claude plugin list 2>/dev/null | grep -q -- "$1@$2"; }

trim() { local s="$1"; s="${s#"${s%%[![:space:]]*}"}"; printf '%s' "${s%"${s##*[![:space:]]}"}"; }

while IFS="|" read -r -u 3 src market plugin trust; do
  src="$(trim "$src")"
  [[ -z "$src" || "$src" == \#* ]] && continue
  market="$(trim "$market")"; plugin="$(trim "$plugin")"; trust="$(trim "$trust")"
  [[ "$src" == "local" ]] && src="$REPO_DIR"

  if [[ "$trust" == "third-party" ]]; then
    warn "Third-party plugin: $plugin (from $src). It isn't from Anthropic or your company."
    confirm "Install $plugin?" || { info "Skipped $plugin"; continue; }
  fi

  if has_marketplace "$market"; then
    run claude plugin marketplace update "$market" || warn "Couldn't update marketplace $market"
  else
    run claude plugin marketplace add "$src" || { warn "Couldn't add marketplace $src (blocked by policy?)"; continue; }
  fi

  if has_plugin "$plugin" "$market"; then
    info "Already installed: $plugin@$market"
  else
    run claude plugin install "$plugin@$market" --scope user || warn "Couldn't install $plugin@$market"
  fi
done 3< "$REPO_DIR/config/plugins.conf"

# i-have-adhd: turn it on for every session unless ADHD_ALWAYS_ON=0.
if has_plugin i-have-adhd i-have-adhd || [[ "$DRY_RUN" == "1" ]]; then
  if [[ "${ADHD_ALWAYS_ON:-1}" == "1" ]]; then
    run mkdir -p "$HOME/.claude"
    run touch "$HOME/.claude/.i-have-adhd-always"
    info "i-have-adhd is on for every session (delete ~/.claude/.i-have-adhd-always to turn it off)"
  fi
  has node || info "Note: always-on mode needs Node. Without it, type /i-have-adhd in each session."
fi

# caveman is on in every session by default, and it clashes with i-have-adhd's
# always-on style. Default it to off (turn on per session with /caveman) unless
# CAVEMAN_ALWAYS_ON=1. An existing caveman config is never overwritten.
CAVEMAN_CFG="${XDG_CONFIG_HOME:-$HOME/.config}/caveman/config.json"
if has_plugin caveman caveman || [[ "$DRY_RUN" == "1" ]]; then
  if [[ "${CAVEMAN_ALWAYS_ON:-0}" == "1" ]]; then
    info "caveman stays on for every session (CAVEMAN_ALWAYS_ON=1)."
  elif [[ -f "$CAVEMAN_CFG" ]]; then
    info "Keeping your existing caveman config: $CAVEMAN_CFG"
  else
    run mkdir -p "$(dirname "$CAVEMAN_CFG")"
    if [[ "$DRY_RUN" == "1" ]]; then
      info "[dry-run] write {\"defaultMode\": \"off\"} to $CAVEMAN_CFG"
    else
      printf '{\n  "defaultMode": "off"\n}\n' > "$CAVEMAN_CFG"
    fi
    info "caveman is off by default; type /caveman in a session to turn it on."
  fi
  has node || info "Note: caveman's hooks need Node. Without it, they quietly do nothing."
fi
