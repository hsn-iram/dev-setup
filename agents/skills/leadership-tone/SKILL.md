---
name: leadership-tone
description: Rewrites a draft Slack message in the user's voice so it reads like a leader wrote it - point first, impact-focused, concise, professional, not repetitive, and still human. Use when the user pastes a draft and asks to reword, rephrase, fix tone, polish a message, or "make this sound like a leader" (or "more senior"), or is writing a status update, asking for help, pushing back, disagreeing, announcing a decision, reporting bad news, or giving thanks or feedback.
license: MIT
---

# Leadership tone for Slack messages

Rewrite the user's draft so the reader knows the point in one line, sees the impact, knows who owns what, and can act without a follow-up question.

## Voice

Every rewrite must be all four:

- **Concise.** Cut filler words, throat-clearing ("Just wanted to say…", "I hope this finds you well"), and anything the reader already knows. Keep one idea per sentence.
- **Professional.** Stay calm, precise and respectful. Add no slang the draft didn't have, no exclamation-mark stacks, no ALL CAPS.
- **Not repetitive.** Say each point once. Skip restating the ask at the end, skip summarising a three-line message, and start consecutive sentences or bullets with different words.
- **Human.** Write like the user typing, not a press release. Use contractions, plain words and the user's own phrasing where it already works. Vary sentence length. Replace stock AI phrasing ("I hope this helps", "Great question", "Let's dive in", "It's worth noting", "delve", "navigate", em-dash chains, lists of exactly three adjectives) with plain words.

## Output format

1. Give **the rewritten message**, ready to paste. Use Slack markdown only: `*bold*`, bullets, no headers.
2. Add **at most 3 one-line notes** on what changed and why.
3. Offer **one alternative** only if the right tone is ambiguous (for example more direct vs softer), and label it.

Never ask questions; always infer the channel (DM, team channel, upward or exec update), and state the assumption in a note if it changes the wording.

## Structure (pyramid)

1. **Lead** with the point: the ask, decision, or outcome.
2. **Follow with 1-3 supporting points**: impact, risk, what you tried, options.
3. **Put detail last**, or move it to a thread ("Details in thread").

## Leadership moves

Replace each weak pattern with its leadership pattern:

| Weak pattern | Leadership pattern |
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

- **Status or upward update:** state the outcome in one line, then the risk (if any), then the next step and date. Leave out the activity log.
- **Asking for help:** say what you need, from whom, by when. Then what you tried and what you suspect, with one link to context.
- **Pushback or disagreement:** acknowledge the shared goal, name the tradeoff, propose an alternative, and ask what you're missing.
- **Announcing a change or decision:** give the decision, why in one line, who is affected, what they need to do and by when, and where to object.
- **Incident or bad news:** lead with what happened and the current state, then impact, what's being done, and the next update time. Stick to facts, with no blame and no spin.
- **Feedback or thanks:** name the person, the specific thing, and the effect it had. Give praise in public; give constructive feedback in a DM.

## Guardrails

- **Always keep the user's facts, numbers, names and intent.** Never invent facts, metrics, commitments or dates. If a needed fact is missing, insert a `[placeholder]` and say so in a note.
- **Stay warm and human.** Use plain words instead of corporate jargon such as "synergy", "circle back", "leverage", "touch base" or "bandwidth".
- **Show real confidence, not fake confidence.** If unsure, say what you know, what you don't, and when you'll know.
- **Credit others.** Name contributors, so the user never sounds like they're taking credit for someone else's work.
- **Aim shorter than the draft.** Cut filler, not substance.
- **Keep emojis** only if the draft had them.
- **Always check before answering:** reread the rewrite once and remove any word, sentence or idea that repeats or adds nothing.

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
