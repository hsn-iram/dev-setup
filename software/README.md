# software/

One folder per program. `make <program>` runs its `install.sh`, then its `config.sh`. `make <program>-config` runs only `config.sh`. Every program installs with Homebrew, so run `make homebrew` first.

| Target | Installs | Config it writes |
|---|---|---|
| `homebrew` | [Homebrew](https://brew.sh). Asks for your Mac password | Puts `brew` on PATH in `~/.zshrc` |
| `uv` | uv, the Python tool runner | Nothing |
| `node` | fnm, then Node LTS as the default (npm and npx come with it) | Loads fnm in `~/.zshrc`, so Node switches to each repo's version on `cd` |
| `tenv` | tenv, which provides `terraform` and `tofu` | `TENV_AUTO_INSTALL=true`: each repo's pinned version installs on first use |
| `claude-code` | Claude Code, with [Anthropic's installer](https://code.claude.com/docs/en/setup) | Puts `~/.local/bin` on PATH |
| `tmux` | tmux | `~/.tmux.conf`, the `tclaude` helper and the cheat sheet (`Ctrl+b ?`) |
| `wezterm` | WezTerm and JetBrains Mono Nerd Font | Links `~/.config/wezterm/wezterm.lua` to this repo. Opens straight into tmux |
| `cursor` | Cursor | The Claude Code extension, if Claude Code is installed |

Every change to `~/.zshrc` goes in a marked block (`# >>> dev-setup <name> >>>`). To undo one, delete its block. Replaced files are saved as `<file>.bak.<timestamp>`.

## tmux

The prefix is `Ctrl+b`: press it, let go, then the key.

| Keys | Does |
|---|---|
| `prefix \|` / `prefix -` | Split side by side / top and bottom |
| `prefix ?` | Cheat sheet (`q` closes it) |
| `prefix r` | Reload the config |
| `v` then `y` in copy mode | Select, then copy |
| `tclaude` in a project folder | Claude Code on the left, a shell on the right |

Put personal tweaks in `~/.tmux.local.conf`. Re-running the setup never touches it.

## WezTerm

WezTerm opens into the tmux session `main`, creating it if needed, so closing the window loses nothing. Its config is a symlink to `software/wezterm/wezterm.lua`: edit either one, WezTerm reloads on save, and the change shows in `git diff`. Put tweaks for one laptop in `~/.config/wezterm/local.lua`.

| Keys | Does |
|---|---|
| `Cmd+Shift+T` | A plain shell outside tmux |
| `Cmd+Shift+P` | Search every WezTerm action |
| `Shift+click` | Open a link (tmux takes plain clicks) |

## Adding a program

1. Create `software/<name>/install.sh`. Install with `brew_install <name>` from `lib/common.sh`.
2. If it needs config, add `config.sh`. Wrap file changes in `run`, `install_file` or `write_rc_block` so `dry-run=true` works.
3. Add `<name>` to `SOFTWARE` in `install.sh`, then add a row to the table above.
