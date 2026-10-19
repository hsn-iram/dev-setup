# shellcheck shell=bash
# Shared helpers. Sourced by install.sh and every step.

REPO_DIR="${REPO_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
DRY_RUN="${DRY_RUN:-0}"
ASSUME_YES="${ASSUME_YES:-0}"
STAMP="$(date +%Y%m%d-%H%M%S)"
RC_FILE="${RC_FILE:-$HOME/.zshrc}"
# Markers keep the old name so existing ~/.zshrc blocks are still found and replaced.
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
# If DEST is a symlink (e.g. managed by a dotfiles repo), leave it alone and say so:
# writing through it would overwrite the file it points to.
install_file() {
  local src="$1" dest="$2" mode="${3:-644}"
  if [[ -L "$dest" ]]; then
    if cmp -s "$src" "$dest"; then info "Up to date: $dest"; return 0; fi
    warn "Skipping $dest: it's a symlink to $(readlink "$dest"), so another tool manages it."
    info "To use this repo's version, merge $src into the file it points to."
    return 0
  fi
  if [[ -e "$dest" ]] && cmp -s "$src" "$dest"; then
    info "Up to date: $dest"; return 0
  fi
  if [[ -e "$dest" ]]; then
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
# Skips a symlinked rc file (dotfiles repo) and stops on a damaged block.
write_rc_block() {
  local body="$1" tmp begins=0 ends=0
  if [[ -L "$RC_FILE" ]]; then
    warn "Skipping $RC_FILE: it's a symlink to $(readlink "$RC_FILE"), so another tool manages it."
    info "Add these lines to it yourself:"; printf '      %s\n' "$body"
    return 0
  fi
  if [[ -f "$RC_FILE" ]]; then
    begins="$(grep -cxF -- "$BLOCK_BEGIN" "$RC_FILE" || true)"
    ends="$(grep -cxF -- "$BLOCK_END" "$RC_FILE" || true)"
    if [[ "$begins" != "$ends" || "$begins" -gt 1 ]] || \
       { [[ "$begins" == 1 ]] && (( $(grep -nxF -- "$BLOCK_BEGIN" "$RC_FILE" | cut -d: -f1) > $(grep -nxF -- "$BLOCK_END" "$RC_FILE" | cut -d: -f1) )); }; then
      die "$RC_FILE has a damaged '$BLOCK_BEGIN' block (markers missing or out of order). Fix it by hand, then re-run."
    fi
  fi
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
    info "[dry-run] would write this block to $RC_FILE:"; printf '      %s\n' "$body"
  else
    # Write in place (not mv) so the file keeps its permissions and owner.
    cat "$tmp" > "$RC_FILE"; info "Updated $RC_FILE (backup: $RC_FILE.bak.$STAMP)"
  fi
  rm -f "$tmp"
}

# Point DEST at SRC with a symlink. If DEST already exists and isn't that link,
# move it to ~/.dev-setup-backup/<timestamp>/ first (outside any folder an agent
# scans, so a backed-up skill can't load twice). Never deletes.
link_path() {
  local src="$1" dest="$2"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    info "Up to date: $dest -> $src"; return 0
  fi
  if [[ -e "$dest" || -L "$dest" ]]; then
    local backup="$HOME/.dev-setup-backup/$STAMP${dest#"$HOME"}"
    info "Backing up $dest -> $backup"
    run mkdir -p "$(dirname "$backup")"
    run mv "$dest" "$backup"
  fi
  run mkdir -p "$(dirname "$dest")"
  run ln -s "$src" "$dest"
  [[ "$DRY_RUN" == "1" ]] || info "Linked $dest -> $src"
}

# Remove symlinks in DIR that point into PREFIX and are broken or not wanted.
# Only touches links this tool made (target under PREFIX); never real files.
#   prune_links DIR PREFIX [keep-name ...]
prune_links() {
  local dir="$1" prefix="$2" link name keep k
  shift 2
  [[ -d "$dir" ]] || return 0
  for link in "$dir"/*; do
    [[ -L "$link" ]] || continue
    [[ "$(readlink "$link")" == "$prefix"/* ]] || continue
    name="$(basename "$link")"; keep=0
    for k in "$@"; do [[ "$k" == "$name" ]] && keep=1; done
    if [[ ! -e "$link" || "$keep" == 0 ]]; then
      info "Removing old link $link"
      run rm "$link"
    fi
  done
}
