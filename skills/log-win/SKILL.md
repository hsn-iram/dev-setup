---
name: log-win
description: Phrases something the user did at work (shipped, fixed, unblocked, wrote, influenced) as impact and adds a row to their Brag Doc. Use when the user describes a piece of work they finished or says "log this win".
license: MIT
---

# Log a win to the Brag Doc

The Brag Doc is the user's running record of their work for reviews. Use the link or location from the current project or conversation. If there isn't one, ask for it. Never write the link into the dev-setup repo or any other public repo. It has a "Wins" table: Date | What I did | Impact (who benefited, measured how) | Senior signal.

## Steps

1. Draft one row from what the user said:
   - **What I did**: one line, active verb, the specific system or doc.
   - **Impact**: what changed, for whom, measured how. Use the user's numbers only; never invent a metric.
   - **Senior signal**: the single best fit of: Owns a problem end to end · Unblocks others · Improves how the team works · Communicates clearly upward · Raises the bar on quality · Influences outside the team.
2. If impact is missing or vague, ask ONE question ("Who noticed, and what number moved?"). If the user doesn't know yet, log "Impact: TBD, check by <date>".
3. Show the row in one line and confirm, unless the user said to just log it.
4. If a tool that can edit the Brag Doc is available, insert the row directly under the Wins header (newest first). If not, output the row as a markdown table line for the user to paste.
5. Thanks received or decisions influenced also go under "Also log", with the quote and who said it.

## Flag busy work

If the work won't show up in a review (invisible ticket churn), say so briefly and suggest how to make it visible: a short write-up, a demo, or a post to the people affected.
