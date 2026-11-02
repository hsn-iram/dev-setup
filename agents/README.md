# agents/

Agent setup. Nothing here installs a program. Pick targets for the agents this laptop is approved for.

| Target | For | Does |
|---|---|---|
| `skills` | Every agent | Links my skills (folders here) and the pinned public skills in `skills/public.conf` into each agent's skills folder |
| `agents-md` | Every agent | Puts my rules, `agents-md/AGENTS.md`, at each agent's global path (table below) |
| `claude-plugins` | Claude Code | Installs the plugins in `claude-plugins/plugins.conf`. Empty for now; it's for things that need Claude Code itself, like hooks |
| `claude-rules` | Claude Code | Turns i-have-adhd on for every session (`ADHD_ALWAYS_ON=0` skips it) |

Run `skills` before `claude-rules`; i-have-adhd's always-on rule comes from the downloaded skill. In one command (`make skills claude-rules`), the order is handled for you.

## Global AGENTS.md

`agents-md/AGENTS.md` holds my rules for every project. Edit it there. `make agents-md` puts it where each agent looks:

| Agent | Path | How |
|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` | Link, always |
| Cursor | `~/.cursor/rules/agents.mdc` | Copy with `alwaysApply: true` added (Cursor has no global AGENTS.md). Re-run after editing |
| Codex | `~/.codex/AGENTS.md` | Link, if Codex is installed |
| Gemini CLI | `~/.gemini/GEMINI.md` | Link, if installed |
| OpenCode | `~/.config/opencode/AGENTS.md` | Link, if installed |

After installing a new agent, run `make agents-md` again. A real `~/.claude/CLAUDE.md` is moved to `~/.dev-setup-backup/` first; copy your own lines from it into `AGENTS.md`.

## Skills

Skills use the open [Agent Skills](https://agentskills.io) format. `~/.claude/skills/` is read by Claude Code, Cursor, Copilot and OpenCode. If Codex or Gemini CLI is installed, skills are also linked into `~/.agents/skills/`.

**Mine:**

| Skill | Use it when |
|---|---|
| `learn-codebase` | You're ramping up on a repo. Say "quiz me" to check your understanding |
| `capture-learning` | You want to save something you learned to your Codebase Notes |
| `log-win` | You finished something worth adding to your Brag Doc |
| `leadership-tone` | You're polishing a Slack message so it reads like a leader wrote it |

**Public** (`skills/public.conf`, each pinned to a commit): `i-have-adhd`, `caveman` (type `/caveman` for terse replies), and Anthropic's `docx`, `xlsx`, `pptx`, `pdf` and `skill-creator`. They're downloaded to `~/.local/share/dev-setup/public-skills/`.

**To add one of mine:**

1. Create `skills/<name>/SKILL.md`, with `name` (matching the folder) and `description` in its frontmatter.
2. Add 3 test prompts to `skills/<name>/evals/evals.json` (format: [evaluating skills](https://agentskills.io/skill-creation/evaluating-skills)).
3. From the repo root, run `bin/validate-skills agents/skills/<name>`.
4. Run `make skills`, then try the skill in a fresh agent session.

**To score a skill:** run `TESSL_WORKSPACE=<name> bin/tessl-review [agents/skills/<name>]`. It's [Tessl](https://docs.tessl.io/improving-your-skills/reviewing-skills)'s quality review (fails below 70) and security scan (fails on high findings). Needs `brew install tesslio/tap/tessl` and `tessl login`. CI runs it on PRs that change skills, once the repo has a `TESSL_TOKEN` secret and a `TESSL_WORKSPACE` variable.

**To test a skill:** ask Claude Code to "run the evals for `<name>` with skill-creator". It runs each prompt with and without the skill and grades the results. Results go in `skills/<name>-workspace/`, which git ignores.

**To add a public skill:**

1. Read its `SKILL.md` and every script in its folder.
2. Add a line to `skills/public.conf`: repo, the full 40-character commit you reviewed, its path, and `official` or `third-party`.
3. Run `make skills`.

## Moving from the old plugins

`i-have-adhd`, `caveman`, `document-skills` and `example-skills` used to be Claude Code plugins. If they're still installed, `make skills` names each one and the `claude plugin uninstall` command that removes it, so skills don't load twice.
