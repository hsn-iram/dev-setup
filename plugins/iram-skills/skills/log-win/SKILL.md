---
name: log-win
description: Use when Iram describes something he did at work (shipped, fixed, unblocked, wrote, influenced) or says 'log this win' — phrases it as impact and adds a row to his Brag Doc.
---

# Log a win to the Brag Doc

Brag Doc: the user's Brag Doc in Claude Docs. Use the link from the current project or conversation; if there isn't one, ask for it. Never store the link in this repo (it's public). It has a "Wins" table: Date | What I did | Impact (who benefited, measured how) | Senior signal.

## Steps

1. Draft one row from what Iram said:
   - **What I did**: one line, active verb, the specific system or doc.
   - **Impact**: what changed, for whom, measured how. Use his numbers only; never invent a metric.
   - **Senior signal**: the single best fit of: Owns a problem end to end · Unblocks others · Improves how the team works · Communicates clearly upward · Raises the bar on quality · Influences outside the team.
2. If impact is missing or vague, ask ONE question ("Who noticed, and what number moved?"). If he doesn't know yet, log "Impact: TBD, check by <date>".
3. Show the row in one line and confirm, unless he said to just log it.
4. If the Claude Docs connector is available, insert the row directly under the Wins header (newest first). If not, output the row as a markdown table line for him to paste.
5. Thanks received or decisions influenced also go under "Also log", with the quote and who said it.

## Flag busy work

If the work won't show up in a review (invisible ticket churn), say so briefly and suggest how to make it visible: a short write-up, a demo, or a post to the people affected.
