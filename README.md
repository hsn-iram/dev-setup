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
make agents                    # skills, rules and plugins; installs no programs
make claude-code               # Claude Code installs only when you name it
make tmux node dry-run=true    # preview any of these (or: make dry-run tmux node)
```

Options: `dry-run=true`, `yes=true` (answer yes to prompts), `claude-via=brew`.

## What's where

| Folder | What's in it |
|---|---|
| [`software/`](software/README.md) | One folder per program: `install.sh` installs it, `config.sh` writes its config |
| [`agents/`](agents/README.md) | AI agent setup: plugins, skills, rules |
| `lib/` | Shared helpers and the preflight checks |
| `tests/` | `make test` runs them against a throwaway home folder |

## Update

```bash
cd ~/dev-setup && git pull && make install
```

## Rules for this repo

- Company-managed settings always win. If a step is blocked by policy, leave it.
- Never commit secrets or anything from an employer (code, names, URLs).
- Run `make test` before you push. CI also runs shellcheck, validates the skills, and scans for secrets.
