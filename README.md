# dev-setup

My Mac setup. You pick what to install with `make`; nothing installs unless you name it. It backs up files before replacing them, and `dry-run=true` previews every change.

## New laptop

```bash
git clone https://github.com/hsn-iram/dev-setup.git ~/dev-setup && cd ~/dev-setup
make                      # list what you can install
make approved             # create this laptop's approved list, then uncomment what's allowed
make install dry-run=true # preview
make install              # install everything on the list
```

**On a work laptop:** only approve what your company allows. The approved list (`~/.config/dev-setup/approved`) stays on the laptop and isn't committed, because approvals change with the employer.

## Pick and choose

```bash
make tmux node                 # install these programs, plus their config
make tmux-config               # config only, for a program IT installed for you
make skills                    # my skills + pinned public skills, for every agent
make agents-md                 # my rules (AGENTS.md) for every agent, incl. ~/.claude/CLAUDE.md
make claude-code claude-rules  # Claude Code only when you name it
make tmux node dry-run=true    # preview any of these (or: make dry-run tmux node)
```

Options: `dry-run=true`, `yes=true` (answer yes to prompts), `claude-via=brew`.

When you run a target by hand, it asks whether to add it to the approved list, so `make update` keeps it current.

## What's where

| Folder | What's in it |
|---|---|
| [`software/`](software/README.md) | One folder per program: `install.sh` installs it, `config.sh` writes its config |
| [`agents/`](agents/README.md) | Agent setup: `skills` and `agents-md` for every agent, plus `claude-plugins` and `claude-rules` |
| `lib/` | Shared helpers and the preflight checks |
| `tests/` | `make test` runs them against a throwaway home folder |

## Update

```bash
cd ~/dev-setup && make update   # git pull, then install everything on the approved list
```

Update runs only what's approved. Nothing records what's been installed; each step checks the laptop instead ("Already installed", "Up to date"), so re-runs are quick. It installs programs that are missing but doesn't upgrade them; use `brew upgrade` for that.

## Rules for this repo

- Company-managed settings always win. If a step is blocked by policy, leave it.
- Never commit secrets or anything from an employer (code, names, URLs).
- Run `make test` before you push. CI also runs shellcheck, validates the skills, and scans for secrets.
