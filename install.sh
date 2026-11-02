#!/usr/bin/env bash
# dev-setup engine. Usually run through make (run `make` to see targets).
# Installs only the steps you name, or the ones in your approved list. Safe to re-run.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_DIR
# shellcheck source=lib/common.sh
source "$REPO_DIR/lib/common.sh"

# Order matters: Homebrew first (programs need it), and software before agents
# (the plugins step needs Claude Code).
SOFTWARE=(homebrew uv node tenv claude-code tmux cursor)
AGENTS=(plugins skills rules)
CONFIGS=()
for s in "${SOFTWARE[@]}"; do
  [[ -f "$REPO_DIR/software/$s/config.sh" ]] && CONFIGS+=("$s-config")
done
APPROVED_FILE="${APPROVED_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/dev-setup/approved}"
CLAUDE_VIA="${CLAUDE_VIA:-native}"
STEPS=""; USE_APPROVED=0; INIT_APPROVED=0

usage() {
  cat <<EOF
Pick what to install. Nothing installs unless you name it.

  Programs (each also writes its config):
    ${SOFTWARE[*]}
  Config only, for a program installed another way:
    ${CONFIGS[*]}
  AI agent setup (installs no programs), or "agents" for all three:
    ${AGENTS[*]}

  make tmux node                 install these
  make tmux node dry-run=true    preview, change nothing (or: make dry-run tmux node)
  make approved                  create or show this laptop's approved list
  make install                   install everything on the approved list
  make test                      run the tests

  Options: dry-run=true   yes=true (answer yes to prompts)   claude-via=brew
  Without make: ./install.sh [--dry-run] [--yes] [--claude-via brew] [--approved] step ...
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --yes) ASSUME_YES=1 ;;
    --claude-via) CLAUDE_VIA="${2:?--claude-via needs native|brew}"; shift ;;
    --approved) USE_APPROVED=1 ;;
    --init-approved) INIT_APPROVED=1 ;;
    --list) echo "${SOFTWARE[*]} ${CONFIGS[*]} ${AGENTS[*]} agents"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    -*) usage; die "Unknown option: $1" ;;
    *) STEPS="$STEPS ${1//,/ }" ;;
  esac
  shift
done
export DRY_RUN ASSUME_YES CLAUDE_VIA

if [[ "$INIT_APPROVED" == "1" ]]; then
  if [[ ! -f "$APPROVED_FILE" ]]; then
    mkdir -p "$(dirname "$APPROVED_FILE")"
    {
      echo "# What this laptop is approved to install. Not in git: approvals depend on the employer."
      echo "# Uncomment a line to approve it, then run: make install"
      echo "#"
      echo "# Programs (each also writes its config):"
      for s in "${SOFTWARE[@]}"; do echo "# $s"; done
      echo "#"
      echo "# Config only, for programs installed another way (for example by IT):"
      for s in "${CONFIGS[@]}"; do echo "# $s"; done
      echo "#"
      echo "# AI agent setup (installs no programs; plugins needs Claude Code):"
      for s in "${AGENTS[@]}"; do echo "# $s"; done
    } > "$APPROVED_FILE"
    info "Created $APPROVED_FILE"
  fi
  info "Approved list: $APPROVED_FILE"
  cat "$APPROVED_FILE"
  exit 0
fi

if [[ "$USE_APPROVED" == "1" ]]; then
  [[ -f "$APPROVED_FILE" ]] || die "No approved list at $APPROVED_FILE. Create one with: make approved"
  STEPS="$STEPS $(sed 's/#.*//' "$APPROVED_FILE" | tr '\n' ' ')"
fi

read -r -a requested <<< "$STEPS"
if [[ ${#requested[@]} -eq 0 ]]; then
  usage
  die "Nothing selected. Name the steps to run (make tmux skills), or approve some (make approved)."
fi

# Space-padded list of what to run, so membership is a substring check.
selected=" "
for item in "${requested[@]}"; do
  case " ${SOFTWARE[*]} ${CONFIGS[*]} ${AGENTS[*]} " in
    *" $item "*) selected="$selected$item " ;;
    *) if [[ "$item" == "agents" ]]; then selected="$selected${AGENTS[*]} "
       else die "Unknown step '$item'. Run ./install.sh --help for the list."; fi ;;
  esac
done

[[ "$DRY_RUN" == "1" ]] && say "DRY RUN: nothing will be changed"

# shellcheck source=lib/preflight.sh
source "$REPO_DIR/lib/preflight.sh"

for step in "${SOFTWARE[@]}"; do
  STEP_DIR="$REPO_DIR/software/$step"; export STEP_DIR
  if [[ "$selected" == *" $step "* ]]; then
    # shellcheck source=/dev/null
    source "$STEP_DIR/install.sh"
  fi
  [[ -f "$STEP_DIR/config.sh" ]] || continue
  if [[ "$selected" == *" $step "* || "$selected" == *" $step-config "* ]]; then
    # shellcheck source=/dev/null
    source "$STEP_DIR/config.sh"
  fi
done

for step in "${AGENTS[@]}"; do
  [[ "$selected" == *" $step "* ]] || continue
  STEP_DIR="$REPO_DIR/agents/$step"; export STEP_DIR
  # shellcheck source=/dev/null
  source "$STEP_DIR/install.sh"
done

say "Done."
