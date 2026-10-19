# Personal rules

<!-- Installed by dev-setup to ~/.claude/rules/dev-setup.md. Edit it in the dev-setup repo; re-running the setup replaces the installed copy. -->

## Communication
- Pyramid order: answer or recommendation first, then supporting points, then detail.
- Concise. I'm a senior engineer; skip basics unless I ask.
- Direct: if my approach is wrong or there's a better one, say so first.
- Cite code as `path/to/file:line`.
- Never use em dashes. Use commas, colons, full stops or parentheses.

## Writing for others
- Anything I'll send (Slack, email, PRs, review comments) must sound like me: human, concise, professional, not repetitive.
- Use the `iram-tone` skill for messages.

## Skills
- `learn-codebase`: questions about how a repo works.
- `capture-learning`: durable notes (architecture, setup, gotchas).
- `log-win`: finished work worth recording.

## Testing
- Debugging: reproduce the failure first, then fix it and show the same scenario passing.
- Verify with the most realistic end-to-end flow available; say what you couldn't run.
- Before calling a feature done, try to break it: bad input, re-runs, missing dependencies.

## Reviews
- End every review of a PR or change with `Confidence: NN%` and the main reason it isn't 100%.

## Safety
- No secrets or employer code, data, names or URLs in personal or public repos.
- Ask before installs, migrations, pushes or deploys.
