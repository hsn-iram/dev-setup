---
name: capture-learning
description: Files what the user learns at work (code, systems, setup steps, gotchas, terms, open questions) into the right section of their Codebase Notes doc instead of leaving it as a one-off answer. Use when the user describes how something works, hits a gotcha, or asks to note something about a codebase.
license: MIT
---

# Capture a learning in Codebase Notes

Codebase Notes is the user's running notes doc for the codebase they're learning. Use the link or location from the current project or conversation. If there isn't one, ask for it. Never write the link, or any employer details, into the dev-setup repo or any other public repo.

| Section | Goes here |
| --- | --- |
| What the team owns | Service/repo, what it does, who depends on it, point person |
| Architecture sketch | What calls what, where data lives, enters and leaves |
| Local setup | Setup steps in order; mark ones missing from official docs |
| How a change ships | Branching, review, CI, deploy, rollback, approvers |
| Gotchas | Dated: what happened, fix or workaround (newest first) |
| Glossary | Term, meaning, where it shows up (alphabetical) |
| Open questions | Checkbox question + who to ask; tick and move the answer when resolved |

## Steps

1. If the user asked a question, answer it first, briefly.
2. Pick the section(s). A gotcha that answers an open question also ticks that question.
3. If a tool that can edit the notes doc is available, write the note there in that section's existing format, changing only what's needed. If not, output the note formatted for that section so the user can paste it.
4. Write for the next hire: concrete commands, paths, names. Never include secrets; say where they live.
5. With 3+ components and their connections known, offer to draw or redraw the architecture sketch.
6. Reply in one line: what was filed where. If the same gotcha has bitten 2+ people, flag it as shared pain worth fixing.
