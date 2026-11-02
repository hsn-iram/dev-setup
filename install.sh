#!/usr/bin/env bash
# dev-setup engine. Usually run through make (run `make` to see targets).
# Installs only the steps you name, or the ones in your approved list. Safe to re-run.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_DIR
# shellcheck source=lib/common.sh
source "$REPO_DIR/lib/common.sh"

# Order matters: Homebrew first (programs need it), software before agents
# (claude-plugins needs Claude Code), and skills before claude-rules (it uses
# the downloaded i-have-adhd skill).
SOFTWARE=(homebrew uv node tenv claude-code tmux wezterm cursor)
AGENTS=(skills claude-plugins claude-rules)
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
  Agent setup (installs no programs):
    skills          my skills + pinned public skills, for every agent on this laptop
    claude-plugins  Claude Code only
    claude-rules    Claude Code only: my rules, and i-have-adhd on for every session

  make tmux node                 install these
  make tmux node dry-run=true    preview, change nothing (or: make dry-run tmux node)
  make approved                  create or show this laptop's approved list
  make install                   install everything on the approved list
  make update                    git pull, then make install
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
    --list) echo "${SOFTWARE[*]} ${CONFIGS[*]} ${AGENTS[*]}"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    -*) usage; die "Unknown option: $1" ;;
    *) STEPS="$STEPS ${1//,/ }" ;;
  esac
  shift
done
export DRY_RUN ASSUME_YES CLAUDE_VIA

# Create the approved list with every step commented out, if it doesn't exist.
init_approved() {
  [[ -f "$APPROVED_FILE" ]] && return 0
  mkdir -p "$(dirname "$APPROVED_FILE")"
  {
    echo "# What this laptop is approved to install. Not in git: approvals depend on the employer."
    echo "# Uncomment a line to approve it. make install and make update run what's approved."
    echo "#"
    echo "# Programs (each also writes its config):"
    for s in "${SOFTWARE[@]}"; do echo "# $s"; done
    echo "#"
    echo "# Config only, for programs installed another way (for example by IT):"
    for s in "${CONFIGS[@]}"; do echo "# $s"; done
    echo "#"
    echo "# Agent setup (installs no programs; claude-* need Claude Code):"
    for s in "${AGENTS[@]}"; do echo "# $s"; done
  } > "$APPROVED_FILE"
  info "Created $APPROVED_FILE"
}
approved_steps() { [[ -f "$APPROVED_FILE" ]] && sed 's/#.*//' "$APPROVED_FILE" | tr -s '[:space:]' ' '; }

if [[ "$INIT_APPROVED" == "1" ]]; then
  init_approved
  info "Approved list: $APPROVED_FILE"
  cat "$APPROVED_FILE"
  exit 0
fi

if [[ "$USE_APPROVED" == "1" ]]; then
  [[ -f "$APPROVED_FILE" ]] || die "No approved list at $APPROVED_FILE. Create one with: make approved"
  STEPS="$STEPS $(approved_steps)"
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
    *) die "Unknown step '$item'. Run make (or ./install.sh --help) for the list." ;;
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

# Steps run by hand aren't refreshed by make update unless they're approved, so offer
# to approve them. Only asks in a terminal; never in a dry run or an approved run.
if [[ "$USE_APPROVED" != "1" && "$DRY_RUN" != "1" ]] && [[ -t 0 || "$ASSUME_YES" == "1" ]]; then
  have=" $(approved_steps || true) "
  for item in "${requested[@]}"; do
    [[ "$have" == *" $item "* ]] && continue
    if confirm "Add $item to this laptop's approved list, so make update keeps it current?"; then
      init_approved
      echo "$item" >> "$APPROVED_FILE"
      have="$have$item "
      info "Approved: $item ($APPROVED_FILE)"
    fi
  done
fi
