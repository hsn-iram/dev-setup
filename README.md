# dev-setup

My Mac dev setup, in one re-runnable script. It installs Claude Code and a set of plugins, links my own agent skills (usable from any agent that supports [Agent Skills](https://agentskills.io)), installs my personal Claude Code rules (`config/CLAUDE.md`), configures tmux for Claude Code, and installs Cursor with the Claude Code extension.

It's built to be safe on a work laptop:

- `--dry-run` shows every change before anything happens.
- Files are backed up before they're replaced.
- Nothing uses `sudo`.
- Any Claude Code policy your company sets always takes priority.

## Installation

### 0. Before you start (work Mac)

Answer these first. The script stays within company policy, but it can't know your company's rules.

1. **Is Claude Code approved?** Check your company's AI tool policy, and ask IT or security if you can't find one.
2. **Which account?** If your company provides a Claude Team or Enterprise account, log in with that account, not a personal one.
3. **Is Homebrew allowed?** The script never installs Homebrew. Without it, tmux and Cursor aren't installed; get them from your company's software portal instead.
4. **Is Cursor approved?** The script asks before installing it.

### 1. Make sure `git` works

```bash
git --version
```

If it prints a version, go to step 2. If a window pops up offering to install the "command line developer tools", click **Install**. You can also start that install yourself with `xcode-select --install`.

This isn't the Xcode app; you don't need Xcode or any iOS tooling. The command line tools are a smaller package with `git`, `make` and a C compiler. Homebrew and many Python packages need them too. On a company Mac, IT has often installed them already.

### 2. Install Homebrew (optional, only if your company allows it)

Follow the instructions at [brew.sh](https://brew.sh). Then, if the installer tells you to, run the `eval "$(/opt/homebrew/bin/brew shellenv)"` line it prints.

### 3. Download this repo

The repo is public, so you don't need to sign in to GitHub to download it. Keep it at `~/dev-setup`, because your personal skills are linked straight from this folder.

```bash
git clone https://github.com/hsn-iram/dev-setup.git ~/dev-setup
cd ~/dev-setup
```

Read `install.sh` and the files in `steps/` before you run anything. It's good practice with any setup script, and they're short.

### 4. Sign in to GitHub (only to push changes)

You need this only if you'll edit this repo from this Mac. Installing doesn't need it.

On a work Mac, ask IT which GitHub account to use. Companies usually set it up one of two ways:

- **Your own account, added to the company's GitHub organization** (the most common setup). Sign in with it, and you can push to this repo too.
- **A company-managed account** (for example `iram_company`). It can't push to personal repos, so make changes to this repo from your personal Mac instead.

```bash
brew install gh && gh auth login     # choose GitHub.com, HTTPS, and "Login with a web browser"
```

### 5. Preview the changes

This changes nothing:

```bash
./install.sh --dry-run
```

Read the output. Every line marked `[dry-run]` is something the real run would do.

### 6. Install

```bash
./install.sh
```

It asks before installing anything third-party (i-have-adhd, caveman, Cursor). Answer `y` or `n` for each.

**Options:**

| Command | What it does |
|---|---|
| `./install.sh --only claude,tmux` | Run only these steps |
| `./install.sh --skip cursor` | Run everything except these steps |
| `./install.sh --claude-via brew` | Install Claude Code with Homebrew instead of Anthropic's installer |
| `./install.sh --yes` | Say yes to every prompt |
| `ADHD_ALWAYS_ON=0 ./install.sh` | Install i-have-adhd but don't turn it on for every session |
| `CAVEMAN_ALWAYS_ON=1 ./install.sh` | Leave caveman on for every session |
| `./install.sh --help` | Show all options |

### 7. Log in to Claude Code

The script installs Claude Code but deliberately doesn't log you in. Login happens in your browser, and your credentials go into the macOS Keychain, so they never pass through this script.

Open a **new** terminal window so the PATH change applies, then run:

```bash
claude
```

A browser opens for login. On a work Mac, use the account your company approved. To switch accounts later, use `/logout`, then `/login`.

### 8. Check it worked

```bash
claude --version          # Claude Code is installed
claude plugin list        # the plugins from config/plugins.conf
tmux -V                   # tmux is installed
ls -l ~/.claude/skills    # links to this repo's skills/
tclaude ~/dev-setup       # tmux session: Claude Code left, shell right (Ctrl+b then d to leave)
```

In Cursor, open the Extensions view (Cmd+Shift+X) and check that **Claude Code** (by Anthropic) is installed. Then run `claude` in Cursor's terminal. If it doesn't connect to the editor, run `/ide`.

### Troubleshooting

| Problem | Fix |
|---|---|
| `claude: command not found` | Open a new terminal, or run `source ~/.zshrc` |
| `Permission denied` running `./install.sh` | Run `chmod +x install.sh`, or use `bash install.sh` |
| "Homebrew not found" | Expected if your company doesn't allow it. Install tmux and Cursor another way |
| A plugin step says "blocked by policy?" | Your company's managed settings don't allow it. Leave it and check with IT |
| Shift+Enter sends the message inside tmux | Run `/terminal-setup` in Claude Code once, from your terminal app outside tmux |
| Claude Code is billing an API key | Remove `ANTHROPIC_API_KEY` from your shell config, then `/login` again |

## What it changes

| Step | Changes | Undo |
|---|---|---|
| `preflight` | Nothing. Checks you're on macOS and not running as root, finds Homebrew, and flags company-managed settings or a stray `ANTHROPIC_API_KEY` | Nothing to undo |
| `claude` | Installs Claude Code with [Anthropic's official installer](https://code.claude.com/docs/en/setup) to `~/.local/bin`. Adds a marked PATH block to `~/.zshrc` | Delete the block between the `mac-setup` markers in `~/.zshrc` |
| `plugins` | Installs the plugins in `config/plugins.conf` for your user. Turns i-have-adhd on for every session and sets caveman to off by default | `claude plugin uninstall <name>`; `rm ~/.claude/.i-have-adhd-always ~/.config/caveman/config.json` |
| `skills` | Symlinks each folder in `skills/` into `~/.claude/skills/` (and `~/.agents/skills/` if Codex or Gemini CLI is installed), removes links it made earlier that are broken or no longer wanted, and copies `config/CLAUDE.md` to `~/.claude/rules/dev-setup.md`. Anything already at a link's path is moved to `~/.dev-setup-backup/<timestamp>/` first. Never touches your own `~/.claude/CLAUDE.md` | Delete the symlinks and `~/.claude/rules/dev-setup.md`; restore from `~/.dev-setup-backup/` |
| `tmux` | Runs `brew install tmux`, writes `~/.tmux.conf`, and installs the `tclaude` helper to `~/.local/bin` | Restore `~/.tmux.conf.bak.<timestamp>` |
| `cursor` | After asking, runs `brew install --cask cursor`, then adds the Claude Code extension (`anthropic.claude-code`). Doesn't touch Cursor's settings | Uninstall it from Cursor's Extensions view |

Before replacing any file, the script saves the old version as `<file>.bak.<timestamp>`.

## Safety and company policy

- **Company-managed settings win.** If IT has deployed Claude Code settings (`/Library/Application Support/ClaudeCode/managed-settings.json`), the script says so, and those settings override anything it configures. If a step is blocked, that's the policy working; don't work around it.
- **Third-party plugins.** Anything not from Anthropic or this repo is labeled `third-party` in `config/plugins.conf`, and the script asks before installing it. Plugins can run commands (hooks), so each one is **pinned** to the exact commit that was reviewed, in `.claude-plugin/marketplace.json`. Re-running the setup never moves a pin. To update a plugin, review the new commit, then change its `sha` there.
- **Dotfiles managers.** If `~/.zshrc` or `~/.tmux.conf` is a symlink (for example into a dotfiles repo), the script leaves it alone and tells you what to add yourself.
- **No secrets in this repo.** Never commit API keys, tokens, or anything from an employer (code, data, internal names or URLs). `.gitignore` covers the common cases. This repo goes with me between jobs.

## tmux

The config is a standard set plus the three lines from [Claude Code's tmux guide](https://code.claude.com/docs/en/terminal-config), which make Shift+Enter insert a newline and let notifications through.

- `tclaude` in a project folder opens a tmux session named after the folder, with Claude Code on the left and a shell on the right. Running it again reattaches to the same session.
- The prefix is the default, `Ctrl+b`.
  - `prefix |` splits the window side by side, and `prefix -` splits it top and bottom.
  - `prefix r` reloads the config.
  - In copy mode, `v` starts a selection and `y` copies it to the macOS clipboard.
- Put your own tweaks in `~/.tmux.local.conf`. It's loaded last, and re-running the setup never overwrites it.

## Plugins

`config/plugins.conf` lists the Claude Code plugins that get installed:

- **`document-skills`, `example-skills`** (Anthropic): Word, Excel, PowerPoint and PDF skills, skill-creator, and more.
- **`i-have-adhd`** ([ayghri/i-have-adhd](https://github.com/ayghri/i-have-adhd), third-party, MIT): shapes Claude's replies to lead with the next action. It's on for every session and needs Node for that.
- **`caveman`** ([JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman), third-party, Apache-2.0): makes Claude's replies terse. Type `/caveman` (or `/caveman ultra`) to turn it on in a session. It's off by default so it doesn't clash with i-have-adhd. Its hooks need Node.

**Adding someone else's plugin:** first read its `.claude-plugin/plugin.json` and every hook it runs, and check for network calls. Then pin the commit you reviewed (all 40 characters) as an entry in `.claude-plugin/marketplace.json`, add a `local | dev-setup | <plugin> | third-party` line to `config/plugins.conf` with a review note above it, and check the result with `claude plugin validate .`

## My skills

My own skills live in `skills/` and follow the open [Agent Skills](https://agentskills.io/specification) format, so they aren't tied to one tool. The `skills` step links them into `~/.claude/skills/`, which Claude Code, Cursor, Copilot in VS Code and OpenCode all read. Codex and Gemini CLI read `~/.agents/skills/` instead, so the step links there too when either is installed. (Cursor then lists each skill twice, which is why it isn't the default.) To choose the folders yourself, set `SKILL_DIRS`, for example `SKILL_DIRS="$HOME/.agents/skills" ./install.sh --only skills`. Because they're symlinks, `git pull` updates every agent at once.

| Skill | Use it when |
|---|---|
| `learn-codebase` | Asking how a codebase works, or ramping up on a new repo. Answers from the code with `file:line` references, labels what's observed vs inferred, and suggests the next question to ask. Say "quiz me" to check your understanding |
| `capture-learning` | Something you learned (architecture, setup steps, gotchas, terms) should go into your Codebase Notes |
| `log-win` | You finished something worth putting in your Brag Doc |
| `iram-tone` | Polishing a Slack message (status update, ask for help, pushback, announcement, bad news, thanks). Rewrites it point-first and impact-focused, keeps your facts, and marks anything missing as a `[placeholder]` |

The skills don't name a specific agent or tool. When one needs to write somewhere (notes, Brag Doc), it uses whatever tool the agent has, or prints the text for you to paste.

**Adding a skill:**

1. Create `skills/<name>/SKILL.md`. Its frontmatter needs `name` (matching the folder) and `description` (what it does and when to use it).
2. Run `bin/validate-skills`. It checks every skill against the spec with [skills-ref](https://pypi.org/project/skills-ref/), the spec's reference validator. It runs through `uvx` or `pipx` if you have either, so nothing is installed globally.
3. Re-run `./install.sh --only skills` to link the new skill, then commit and push. CI runs the same validation.

**The edit loop.** For each change to a skill:

1. **Validate:** `bin/validate-skills skills/<name>` catches format mistakes (name, description, frontmatter).
2. **Try it:** start a fresh session in any agent and ask something that should trigger the skill. Check that it loads, and that it doesn't load for prompts it shouldn't.
3. **Evaluate:** for skills you rely on, use the `skill-creator` skill (installed with `example-skills`) to write a few test prompts, compare runs with and without the skill, and tune the description so it triggers reliably.
4. Repeat until it passes, then commit.

**Want a heavier tool for learning a codebase?** [OthmanAdi/codebase-knowledge-builder](https://github.com/OthmanAdi/codebase-knowledge-builder) (third-party, MIT) is a portable Agent Skill that writes a full, source-cited architecture report for a repo. It isn't installed by default. Review it first, then copy its `skills/codebase-knowledge-builder/` folder into `skills/` if you want it.

## CLAUDE.md

`config/CLAUDE.md` holds my personal rules for Claude Code: pyramid-ordered answers, no em dashes, sounding human in anything I send, reproduce-first debugging, realistic end-to-end verification, and a `Confidence: NN%` line at the end of every review. It's deliberately short.

It's installed as `~/.claude/rules/dev-setup.md`. Claude Code loads every file in `~/.claude/rules/` in every project, next to `~/.claude/CLAUDE.md`, so your own `~/.claude/CLAUDE.md` stays yours: re-running the setup never overwrites it. Edit the rules here and re-run `./install.sh --only skills`.

It's the one Claude-specific file. Other agents read their own instruction files (for example, Codex reads `~/.codex/AGENTS.md`). Copy it there if you want the same rules in those tools.

## Updating

```bash
cd ~/dev-setup && git pull && ./install.sh
```

Claude Code installed with Anthropic's installer updates itself. If you installed it with Homebrew, run `brew upgrade claude-code`.

## CI

On every push, `.github/workflows/ci.yml`:

- Lints every script with shellcheck, and checks that the tmux config loads with no errors.
- Validates every skill in `skills/` against the Agent Skills spec (`bin/validate-skills`).
- Runs `tests/run.sh` on Ubuntu and macOS (macOS still ships bash 3.2). The tests use a throwaway home folder and cover dry runs, real installs, re-runs, symlinked dotfiles, damaged `~/.zshrc` blocks, stale links and the plugin pins. Run them yourself with `tests/run.sh`.
- Scans the full git history for committed secrets with gitleaks.

Every GitHub Action is pinned to a full commit SHA.
