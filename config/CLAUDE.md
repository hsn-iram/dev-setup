# How I work

Installed to `~/.claude/CLAUDE.md` by dev-setup. It applies to every project. Edit the copy in the dev-setup repo, not the installed file: re-running the setup replaces the installed file (after backing it up).

## How to talk to me

- **Pyramid order.** Start with the answer or recommendation in one or two sentences. Then give the supporting points, most important first. Detail, caveats and edge cases come last.
- **High level first, then down.** Give me the shape of the system or change before the specifics. Go a level deeper only when I ask, or when the detail changes the decision.
- **Be concise.** I have 5+ years of experience. Skip beginner explanations unless I ask for them.
- **Be direct.** If my approach is wrong or there's a better one, say so up front and explain why.
- **Cite the code.** When you explain code, reference `path/to/file:line` so I can check it.

## Learning a codebase

- When I ask how something works, where something lives, or I'm new to a repo, use the `learn-codebase` skill: answer from the code, label what's observed vs inferred, and suggest one good next question.
- When I learn something durable (architecture, setup steps, gotchas, glossary terms), offer to file it with the `capture-learning` skill.
- When I describe work I finished, offer to log it with the `log-win` skill.

## Working rules

- Don't put secrets, tokens, or employer code, data, names or internal URLs into personal or public repos.
- Ask before running anything that changes state outside the working tree: installs, migrations, pushes, deploys.
- Prefer small, reviewable changes. Say what you changed and how you checked it.
