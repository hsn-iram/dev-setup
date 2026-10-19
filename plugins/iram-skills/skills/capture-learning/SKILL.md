---
name: capture-learning
description: Use when Iram describes code, systems, setup steps, gotchas, terms or open questions at work — files it into the right section of his Codebase Notes instead of a one-off answer.
---

# Capture a learning in Codebase Notes

Codebase Notes: the user's Codebase Notes doc in Claude Docs. Use the link from the current project or conversation; if there isn't one, ask for it. Never store the link in this repo (it's public), and never copy employer details into it.

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

1. Answer his actual question first, briefly, if he asked one.
2. Pick the section(s). A gotcha that answers an open question also ticks that question.
3. If the Claude Docs connector is available, write the note there in that section's existing format, changing only what's needed. If not, output the note formatted for that section so he can paste it.
4. Write for the next hire: concrete commands, paths, names. Never include secrets; say where they live.
5. With 3+ components and their connections known, offer to draw or redraw the architecture sketch.
6. Reply in one line: what was filed where. If the same gotcha has bitten 2+ people, flag it as shared pain worth fixing.
