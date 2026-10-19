---
name: iram-tone
description: Rewrites a draft Slack message in the user's voice so it reads like a senior engineer wrote it - point first, impact-focused, concise, professional, not repetitive, and still human. Use when the user pastes a draft and asks to reword, rephrase, fix tone, polish a message, or "make this sound senior", or is writing a status update, asking for help, pushing back, disagreeing, announcing a decision, reporting bad news, or giving thanks or feedback.
license: MIT
---

# Iram tone for Slack messages

Rewrite the user's draft so the reader knows the point in one line, sees the impact, knows who owns what, and can act without a follow-up question.

## Voice

Every rewrite must be all four:

- **Concise.** Cut filler words, throat-clearing ("Just wanted to say…", "I hope this finds you well"), and anything the reader already knows. One idea per sentence.
- **Professional.** Calm, precise and respectful. No slang the draft didn't have, no exclamation-mark stacks, no ALL CAPS.
- **Not repetitive.** Say each point once. Don't restate the ask at the end, don't summarise a three-line message, and don't open consecutive sentences or bullets with the same word.
- **Human.** It should sound like the user typing, not a press release. Use contractions, plain words and the user's own phrasing where it already works. Vary sentence length. Avoid stock AI phrasing: "I hope this helps", "Great question", "Let's dive in", "It's worth noting", "delve", "navigate", em-dash chains, and lists of exactly three adjectives.

## Output format

1. **The rewritten message**, ready to paste. Slack markdown only: `*bold*`, bullets, no headers.
2. **At most 3 one-line notes** on what changed and why.
3. **One alternative**, only if the right tone is ambiguous (e.g. more direct vs softer). Label it.

Do not ask questions. Infer the channel (DM, team channel, upward or exec update) and state the assumption in a note if it changes the wording.

## Structure (pyramid)

1. **Lead** with the point: the ask, decision, or outcome.
2. **1-3 supporting points**: impact, risk, what you tried, options.
3. **Detail last**, or move it to a thread ("Details in thread").

## Senior moves

| Weak pattern | Senior pattern |
|---|---|
| Hedging, over-apologising ("sorry to bother", "just wondering", "I think maybe") | Direct and polite: "Could you review X by Thu?" |
| Problem with no proposal | Problem + recommendation + what you need from them |
| "Can someone help?" | Specific ask, specific person or owner, by when, what you already tried |
| Status as an activity list | Outcome, risk, next step |
| Blame ("they broke it") | Neutral facts + the fix + how to prevent a repeat |
| Vague "soon" | A date, or the next checkpoint when you'll know |
| "This is wrong" | Name the tradeoff, propose an alternative, invite a counterpoint. "Disagree and commit" is fine once decided |
| "Thanks!" | Specific thanks naming the impact, in a place others see it |
| Wall of text | TL;DR line first, details in thread |
| Asking permission for things in your remit | State intent, invite objections: "Plan: X. Shout by Thu if concerns." |

## Message recipes

- **Status / upward update**: outcome in one line, then risk (if any), then next step and date. No activity log.
- **Asking for help**: what you need, from whom, by when. Then what you tried and what you suspect. One link to context.
- **Pushback / disagreement**: acknowledge the goal you share, name the tradeoff, propose an alternative, ask what you're missing.
- **Announcing a change or decision**: the decision, why in one line, who is affected, what they need to do and by when, where to object.
- **Incident / bad news**: what happened and current state first, then impact, what's being done, next update time. Facts, no blame, no spin.
- **Feedback / thanks**: name the person, the specific thing, and the effect it had. Public for praise; constructive feedback goes in a DM.

## Guardrails

- **Keep the user's facts, numbers, names and intent.** Never invent facts, metrics, commitments or dates. If a needed fact is missing, insert a `[placeholder]` and say so in a note.
- **Stay warm and human.** No corporate jargon. Banned: "synergy", "circle back", "leverage", "touch base", "bandwidth".
- **No fake confidence.** If unsure, say what you know, what you don't, and when you'll know.
- **Credit others.** Don't make the user sound like they're taking credit for someone else's work. Name contributors.
- **Shorter than the draft**, usually. Cut filler, not substance.
- **Final check before answering:** reread the rewrite once and remove any word, sentence or idea that repeats or adds nothing.
- **Emojis**: keep only if the draft had them.

## Examples

**Before** (ask for help, team channel)
> Hey, sorry to bother everyone, I was just wondering if someone could maybe help me with the deploy thing? It's been failing and I think it might be the config but I'm not sure. I've been looking at it all day.

**After**
> *Need a second pair of eyes on the staging deploy: it's been failing all day.*
> Suspect the config change in [PR link], but not confirmed. I've ruled out [what you tried].
> @[owner of deploy tooling], could you take a look by [when]? I'm blocked on [feature] until it's fixed.

- Led with the ask, named an owner, left the deadline as a placeholder.
- Replaced apologies with what you tried; `[placeholders]` need your details.

**Before** (disagreement, DM to lead)
> I don't think the new caching approach is right. It's going to cause problems and we'll regret it.

**After**
> I'm worried the new caching approach trades speed for stale data on [which flows]. Alternative: [shorter TTL / invalidate on write]. That costs [tradeoff]. What am I missing on the staleness side? Happy to go with your call either way.

- Named the tradeoff instead of a verdict, proposed an option, invited a counterpoint.
- Assumed DM to a lead, so kept it conversational.
