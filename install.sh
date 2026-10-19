#!/usr/bin/env bash
# mac-setup: set up a Mac for Claude Code, its plugins, tmux and Cursor.
# Run ./install.sh --help for options. Safe to re-run.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_DIR
# shellcheck source=lib/common.sh
source "$REPO_DIR/lib/common.sh"

ALL_STEPS=(preflight claude plugins tmux cursor)
ONLY=""; SKIP=""
CLAUDE_VIA="${CLAUDE_VIA:-native}"

usage() {
  cat <<EOF
Usage: ./install.sh [options]

  --dry-run             Show what would change; change nothing.
  --only a,b            Run only these steps (${ALL_STEPS[*]}).
  --skip a,b            Skip these steps.
  --claude-via brew     Install Claude Code with Homebrew instead of the official
                        native installer (use if your company requires brew).
  --yes                 Answer yes to prompts (including third-party plugins).
  -h, --help            Show this help.

Steps:
  preflight  Checks: macOS, not root, Homebrew, company-managed Claude settings.
  claude     Installs Claude Code; puts ~/.local/bin on PATH in ~/.zshrc.
  plugins    Installs the plugins listed in config/plugins.conf.
  tmux       Installs tmux (Homebrew), ~/.tmux.conf, and the tclaude helper.
  cursor     Installs Cursor (Homebrew) and the Claude Code extension.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --only) ONLY="${2:?--only needs a list}"; shift ;;
    --skip) SKIP="${2:?--skip needs a list}"; shift ;;
    --claude-via) CLAUDE_VIA="${2:?--claude-via needs native|brew}"; shift ;;
    --yes) ASSUME_YES=1 ;;
    -h|--help) usage; exit 0 ;;
    *) usage; die "Unknown option: $1" ;;
  esac
  shift
done
export DRY_RUN ASSUME_YES CLAUDE_VIA

wants() {
  local s="$1"
  [[ -n "$ONLY" && ",$ONLY," != *",$s,"* ]] && return 1
  [[ ",$SKIP," == *",$s,"* ]] && return 1
  return 0
}

[[ "$DRY_RUN" == "1" ]] && say "DRY RUN: nothing will be changed"

for step in "${ALL_STEPS[@]}"; do
  if wants "$step"; then
    # shellcheck source=/dev/null
    source "$REPO_DIR/steps/$step.sh"
  fi
done

say "Done."
cat <<'EOF'
Next:
  1. Open a new terminal (or: source ~/.zshrc).
  2. Run `claude` and log in. Use the account your company approved.
  3. Inside tmux, Shift+Enter inserts a newline. Run `tclaude` in a project to try it.
EOF
