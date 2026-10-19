# shellcheck shell=bash
# Shared helpers. Sourced by install.sh and every step.

REPO_DIR="${REPO_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
DRY_RUN="${DRY_RUN:-0}"
ASSUME_YES="${ASSUME_YES:-0}"
STAMP="$(date +%Y%m%d-%H%M%S)"
RC_FILE="${RC_FILE:-$HOME/.zshrc}"
BLOCK_BEGIN="# >>> mac-setup >>>"
BLOCK_END="# <<< mac-setup <<<"

say()  { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '\033[33m!!  %s\033[0m\n' "$*" >&2; }
die()  { printf '\033[31mxx  %s\033[0m\n' "$*" >&2; exit 1; }

has() { command -v "$1" >/dev/null 2>&1; }

# Run a command, or just print it in dry-run mode.
run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '    [dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

# Ask a yes/no question. Default is No. --yes answers Yes; no TTY answers No.
confirm() {
  [[ "$ASSUME_YES" == "1" ]] && return 0
  [[ -t 0 ]] || { warn "No terminal to ask: '$1' -> skipped (use --yes to accept)"; return 1; }
  local reply
  read -r -p "    $1 [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

# Copy SRC to DEST. If DEST exists and differs, back it up first. Never deletes.
install_file() {
  local src="$1" dest="$2" mode="${3:-644}"
  if [[ -e "$dest" ]] && cmp -s "$src" "$dest"; then
    info "Up to date: $dest"; return 0
  fi
  if [[ -e "$dest" || -L "$dest" ]]; then
    info "Backing up $dest -> $dest.bak.$STAMP"
    run cp -p "$dest" "$dest.bak.$STAMP"
  fi
  run mkdir -p "$(dirname "$dest")"
  run cp "$src" "$dest"
  run chmod "$mode" "$dest"
  [[ "$DRY_RUN" == "1" ]] || info "Installed $dest"
}

# Replace (or append) this tool's marked block in the shell rc file.
# Lines outside the markers are never touched. Backs up the rc file first.
write_rc_block() {
  local body="$1" tmp
  tmp="$(mktemp)"
  if [[ -f "$RC_FILE" ]]; then
    awk -v b="$BLOCK_BEGIN" -v e="$BLOCK_END" '
      $0 == b {skip=1; next} $0 == e {skip=0; next} !skip {print}
    ' "$RC_FILE" > "$tmp"
  fi
  printf '%s\n%s\n%s\n' "$BLOCK_BEGIN" "$body" "$BLOCK_END" >> "$tmp"
  if [[ -f "$RC_FILE" ]] && cmp -s "$tmp" "$RC_FILE"; then
    info "Up to date: $RC_FILE"; rm -f "$tmp"; return 0
  fi
  [[ -f "$RC_FILE" ]] && run cp -p "$RC_FILE" "$RC_FILE.bak.$STAMP"
  if [[ "$DRY_RUN" == "1" ]]; then
    info "[dry-run] would write this block to $RC_FILE:"; printf '      %s\n' "$body"; rm -f "$tmp"
  else
    mv "$tmp" "$RC_FILE"; info "Updated $RC_FILE (backup: $RC_FILE.bak.$STAMP)"
  fi
}
