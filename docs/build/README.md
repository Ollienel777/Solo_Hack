# Build loop

Instructions for an agent running the build `/loop`. The loop:

- turns `hackathon/DECISION.md` into a spec and a backlog of tickets
- implements the backlog through reviewed PRs
- merges what settles
- keeps re-deciding what is most valuable to build next
- ends the hackathon with submission materials ready for a human to submit

Start it with `/build-loop`, or by hand:

```
/loop 10m Read docs/build/README.md and follow the brief it indexes, per the reading protocol in it. Read the Now block and latest entries of .claude/build-log.md first each iteration so you do not repeat work. Mode: build.
```

**Pass the `Mode:` clause every time.** It overrides the block in
[`START.md`](START.md#this-run). **Use a fixed interval, never self-pacing.** A
fixed interval re-arms itself, while a self-paced loop stops for good the first
time a lap forgets to schedule the next one.

## The shape of it

The session running the loop is an **orchestrator**. It reads state, decides,
dispatches subagents and records what happened. It never writes product code
and never reviews. The work is done by subagents, each in its own worktree:

| subagent | does | brief in |
|---|---|---|
| planner | turns the decision into a spec, a design direction and a draft backlog | [`PLAN.md`](PLAN.md#the-spec-lap) |
| implementer | takes one ticket and opens a draft loop PR | [`TICKETS.md`](TICKETS.md#the-implementers-brief) |
| cold reviewer | reviews a PR it knows nothing about | [`BRIEFS.md`](BRIEFS.md#the-cold-reviewers-brief) |
| semi-cold reviewer | gives a verdict on each open finding | [`BRIEFS.md`](BRIEFS.md#the-semi-cold-reviewers-brief) |
| fixer | acts on findings, human comments, red checks and conflicts | [`FIX.md`](FIX.md#the-fixers-brief) |
| triager | re-ranks the backlog against the demo and the judging criteria | [`PLAN.md`](PLAN.md#re-triage) |
| rehearser | walks the demo script against the running app | [`SUBMIT.md`](SUBMIT.md#rehearsal) |

**The state lives on GitHub**: issues and their labels, loop PRs, marker
comments, `fix:` replies, round reviews with finding IDs, and review labels.
The log's Now block holds the rest. A lap that starts cold after a compaction
rebuilds everything from those two.

## The files, and when to read each

Every rule lives in exactly one file.

| file | when to read it | ~tokens |
|---|---|---|
| [`README.md`](README.md) | every lap: this index | 1.3k |
| [`START.md`](START.md) | once, at the start of a run: settings, capability checks, the clock | 1.5k |
| [`RULES.md`](RULES.md) | **every lap**: hard rules, loop PRs, the clock, the lap order, dispatching, the ceiling, evidence, logging, GitHub traps | 4.3k |
| [`PLAN.md`](PLAN.md) | a lap that writes the spec, files the backlog, re-triages or files a card | 3.1k |
| [`TICKETS.md`](TICKETS.md) | a lap that dispatches an implementer | 1.2k |
| [`REVIEW.md`](REVIEW.md) | a lap that routes, labels, handles human input, checks or merges | 3.4k |
| [`BRIEFS.md`](BRIEFS.md) | a lap that spawns a review round | 1.8k |
| [`FIX.md`](FIX.md) | a lap that dispatches a fixer, settles, or parks a PR | 1.4k |
| [`SUBMIT.md`](SUBMIT.md) | rehearsals, and the polish and submit phases | 1.6k |
| [`REPORTING.md`](REPORTING.md) | phase changes, decisions, status rewrites, the end of the run | 0.9k |

Token figures are bytes ÷ 4, measured when the brief was written. A routing lap
that spawns a round reads about 10.9k tokens of brief: this file, `RULES.md`,
`REVIEW.md` and `BRIEFS.md`. Re-measure when a file changes.

## Reading protocol

- **First lap:** `START.md` and `RULES.md`, in full.
- **Every lap after:** `RULES.md`, plus the phase files the lap uses. A lap that
  spawns a round reads `BRIEFS.md` on top of `REVIEW.md`. Filing a card means
  reading `PLAN.md`'s filing section, whatever else the lap is doing. An idle
  lap where nothing has changed reads nothing more.
- **After any compaction:** re-read `RULES.md` in full, and note that you did.
- **When memory and a file disagree, the file wins.** When the log and GitHub
  disagree, GitHub wins.

## Where things live

| path | what |
|---|---|
| `hackathon/EVENT.md` | the clock, judging criteria and prizes (human-owned) |
| `hackathon/DECISION.md` | the chosen idea. Gitignored until the spec PR adds it. |
| `hackathon/draft/` | the planner's drafts before the start (gitignored) |
| `hackathon/SPEC.md`, `DESIGN.md` | the build spec and the design direction |
| `hackathon/rehearsals/` | rehearsal reports and screenshots (gitignored) |
| `hackathon/submission/` | the submission materials |
| `scripts/toutc.mjs` | the clock's timezone conversion |
| `.claude/build-log.md` | the Now block and the lap entries, for one run (gitignored) |
| GitHub | issues (the backlog), loop PRs, the status issue |

## Changing the brief

Amend a rule where it lives, one concern per PR. Such PRs touch `docs/`, so
they wait for a human merge. A running loop records what it learned as a
`docs` card, and never rewrites the brief it is following.

This brief adapts ClipFarm's `docs/overnight/`. It is lighter where a hackathon
needs speed, and heavier where parallel subagents need their outcomes recorded.
Each departure is explained where it is made.
