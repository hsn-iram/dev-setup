# agents/

AI agent setup. Nothing here installs a program. `make agents` runs all three steps.

| Target | Does | Undo |
|---|---|---|
| `plugins` | Installs the Claude Code plugins in `plugins/plugins.conf`. Skipped if Claude Code isn't installed | `claude plugin uninstall <name>` |
| `skills` | Symlinks each folder in `skills/` into `~/.claude/skills/` | Delete the links |
| `rules` | Copies `rules/CLAUDE.md` to `~/.claude/rules/dev-setup.md`. Your own `~/.claude/CLAUDE.md` is never touched | Delete that file |

## Plugins

| Plugin | From | Notes |
|---|---|---|
| `document-skills`, `example-skills` | Anthropic | Office and PDF skills, skill-creator |
| `i-have-adhd` | [ayghri/i-have-adhd](https://github.com/ayghri/i-have-adhd) | On for every session. Turn it off with `ADHD_ALWAYS_ON=0` |
| `caveman` | [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) | Off by default. Type `/caveman` to turn it on |

Third-party plugins can run commands, so the installer asks before installing each one, and each is pinned to a reviewed commit in `.claude-plugin/marketplace.json`.

**To add a third-party plugin:**

1. Read its `.claude-plugin/plugin.json` and every hook it runs. Check for network calls.
2. Pin the reviewed commit (all 40 characters) in `.claude-plugin/marketplace.json`.
3. Add a `local | dev-setup | <plugin> | third-party` line to `plugins/plugins.conf`, with a review note.

## Skills

These use the open [Agent Skills](https://agentskills.io) format, so Claude Code, Cursor, Copilot and OpenCode all load them. Because they're symlinks, `git pull` updates every agent.

| Skill | Use it when |
|---|---|
| `learn-codebase` | You're ramping up on a repo. Say "quiz me" to check your understanding |
| `capture-learning` | You want to save something you learned to your Codebase Notes |
| `log-win` | You finished something worth adding to your Brag Doc |
| `iram-tone` | You're polishing a Slack message |

**To add a skill:**

1. Create `skills/<name>/SKILL.md`, with `name` (matching the folder) and `description` in its frontmatter.
2. From the repo root, run `bin/validate-skills agents/skills/<name>`.
3. Run `make skills`, then try the skill in a fresh agent session.

## Rules

`rules/CLAUDE.md` holds my personal Claude Code rules. Edit it, then run `make rules`.
