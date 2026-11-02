---
name: learn-codebase
description: Answers questions about an unfamiliar codebase by reading the actual code, and helps the user learn it faster. Use when the user asks how something works, where something lives, what calls what, why code is shaped a certain way, or says they are new to a repo, onboarding, or ramping up.
license: MIT
---

# Learn a codebase

Help the user build an accurate mental model of the repo quickly. Answer from the code, not from guesses.

## Answer shape (pyramid)

1. **Answer first**, in one or two sentences.
2. **Then the supporting detail**, most important first: the path through the code, with `path/to/file.py:123` references for every claim.
3. **Then edge cases, caveats and open questions.**

Stop when the question is answered. Skip anything the user didn't ask for.

## How to answer

1. **Find before you explain.** Search the repo (file names, symbols, call sites, tests, config) before answering. Read the code the answer depends on.
2. **Label confidence.** Mark each claim as *observed* (you read the code), *inferred* (follows from what you read) or *unknown*. Never present an inference as fact.
3. **Follow the data.** For "how does X work", trace entry point → main path → where data is stored or sent → how errors are handled. Name each hop with a file reference.
4. **Use the tests.** Tests show intended behaviour and real inputs. Point to the most useful one.
5. **Stay read-only.** Don't run builds, installs, migrations or anything that changes state unless the user asks. Never open or quote secrets (`.env`, keys, credentials).
6. **Say who to ask.** If the answer depends on history or a decision you can't see in the code, say so. Suggest checking `git log -p` / `git blame` on the relevant lines, or asking the code owner.

## Help them learn, not just know

After answering:

- Suggest **one next question** worth asking that builds on this one. Prefer questions that reveal architecture (boundaries, data flow, ownership) over trivia.
- If the user says "quiz me" or "check my understanding", ask two or three short questions about what was just covered, then correct their answers with file references.
- When an answer is durable (architecture, setup steps, gotchas, glossary terms), offer to save it to the user's codebase notes. Use the `capture-learning` skill if it is available.

## First look at a new repo

If the user asks for an overview or is starting out, give a short map before diving in:

1. What the repo is for, in one sentence (from README, package metadata, entry points).
2. The top-level layout: the 4–6 directories that matter and what each holds.
3. How to run it and how to test it, from the repo's own docs, scripts or CI config.
4. The main entry points and the two or three most important modules.
5. Three questions worth answering next.
