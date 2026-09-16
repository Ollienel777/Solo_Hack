# Plan: spec, backlog, and what to build next

Read on a lap that **writes the spec, files the backlog, re-triages, or files a
card**.

Part of the build brief. See [`README.md`](./README.md).

---

## What wins, and so what is valuable

The judged artifact is **a three-minute demo, plus a write-up and a repo a
judge might open.** Value is whatever moves those, weighted by the event's
published judging criteria. A feature a judge never sees is worth close to
nothing. A rough edge on the demo path costs more than a missing feature off
it. Every priority decision in this brief comes back to that.

## The spec lap

Dispatch one planner with worktree isolation. **Give it the absolute paths of
`hackathon/DECISION.md` and, if they exist, the drafts in `hackathon/draft/`.**
Both are gitignored, so they do not exist in its worktree. It also reads
`hackathon/EVENT.md` and the `ui-craft` skill. The human's notes at the top of
`DECISION.md` override everything else.

It produces:

- **`hackathon/SPEC.md`**, with [the contents below](#what-specmd-contains).
- **`hackathon/DESIGN.md`**, per `ui-craft`.
- **`hackathon/backlog-draft.md`**, the backlog in the [ticket
  format](#tickets). It uses local IDs (`D1`, `D2`, …) for tickets and
  dependencies, since no issue numbers exist yet.

**Before `hacking starts`** ([`START.md`](START.md#the-clock)), the planner
writes those three files into the main checkout's `hackathon/draft/` and
stops. No commit, no push, no PR. **Pass this instruction explicitly**: the
planner does not read `START.md`.

**After the start**, it copies `DECISION.md` into its worktree and adds it with
`git add -f`. It starts from the drafts where they exist. It opens one draft
loop PR carrying `DECISION.md`, `SPEC.md`, `DESIGN.md` and the backlog draft.
That PR is reviewed with the spec variant of the cold brief
([`BRIEFS.md`](BRIEFS.md#spec-prs)).

**Open questions do not hold the spec PR.** The spec lists them. Only the
tickets that depend on an answer get `needs-decision`. A spec waiting overnight
for a human stops everything.

### What `SPEC.md` contains

1. **The product.** One-liner, user and story.
2. **The demo script.** Numbered beats with timestamps, the wow beat marked, and
   for each beat the screens and behaviour it needs, plus its fallback. **This
   is the backbone of the backlog**: every P1 ticket maps to a beat.
3. **Prize requirements.** Each targeted prize, its requirement quoted with a
   source, and how it is met visibly.
4. **Architecture.** Components, the data model, where the hard part lives, and
   every external service behind an adapter.
5. **Stack and conventions.** Framework, language, one package manager,
   layout, formatting, testing. **Areas**: the `area:` labels this project
   uses, one per screen or module. With coarse areas like "web", almost every
   ticket collides and parallel work never happens.
6. **The gate.** The exact commands to install, lint, typecheck, test, build
   and smoke-test, behind **one package script** (for example `npm run gate`).
   CI runs that script, and so do implementers. Changing the gate then never
   means touching `.github/`, which waits for a human merge after M0. The CI
   workflow must:
   - run on **every** PR, with no path filters. A PR with no check runs can
     never settle.
   - also run on every push to `main`. The loop reads `main`'s checks before
     each merge.

   The gate itself must:
   - use fake mode, so tests never spend money or need keys
   - take its dev-server port from `PORT`, with no reuse of an existing server
     (`reuseExistingServer: false` in Playwright). Parallel worktrees run
     servers side by side, and a test that attaches to the wrong one tests
     someone else's branch.
   - exclude `.claude/**` from every lint, test, typecheck and style glob,
     because agent worktrees live there
7. **Environment.** Variable names only: which adapter needs which, and how
   fake mode is switched on.
8. **Milestones**, with exit criteria (below).
9. **The cut list.** What to drop first, in order.
10. **Risks and spikes.**
11. **Open questions for the human**, each naming the tickets it blocks.

### Keyless development

**Every external service sits behind an adapter with two implementations: the
real one, and a fake backed by realistic fixtures.** An environment variable
chooses between them.

- **Fake mode is what CI runs**, and what implementers build against before
  keys exist.
- **It is also the demo's fallback** if a live service fails on stage. Judges
  see its data whenever the demo runs on it, so it has to look real.

**Live mode** is used where `.env.local` has the keys: by the rehearser, and by
an M2 implementer verifying the hard part
([`SUBMIT.md`](SUBMIT.md#rehearsal)). Keys are a human action, and the loop
never waits for one.

### Stack defaults

Use what `DECISION.md` names. Otherwise, choose what the loop builds most
reliably and what serves a mature UI:

- TypeScript throughout: Next.js (App Router), Tailwind CSS and shadcn/ui
- Vitest for unit tests; Playwright for the smoke test and screenshots
- one deployable unit
- a database only if the product needs persistence (SQLite first)
- a Python sidecar only if the hard part needs Python libraries

### Milestones

| milestone | exit criterion |
|---|---|
| **M0 Skeleton** | Scaffold, CI running the gate, design tokens, the app shell, fake adapters, and a smoke test that opens the first demo screen. **The first M0 ticket includes the CI workflow and deletes `hackathon/backlog-draft.md`.** |
| **M1 Demo path** | Every beat of the demo script works end to end, on fakes. |
| **M2 Wow** | The hard part works for real wherever keys exist, with a fallback elsewhere. |
| **M3 Prizes** | Every targeted prize requirement is visibly met. |
| **M4 Polish** | Every demo screen passes the `ui-craft` rubric at 1440×900, with real-looking data and every state handled. |
| **M5 Submission** | The materials in [`SUBMIT.md`](SUBMIT.md). |

**M0 runs one ticket at a time.** While any M0 ticket is open, no other
milestone's ticket is eligible, since everything builds on the skeleton.

## Filing the backlog

Once the spec PR has merged, a plan lap files `hackathon/backlog-draft.md` as
issues. This step is exempt from the card cap.

1. **Create the `area:` labels the spec defines** before filing anything:
   `gh label create NAME --color c5def5 --force`.
2. **File the tickets in dependency order.** Record each `Dn → #n` mapping in
   the Now block as you go. Rewrite each ticket's dependencies from `Dn` to
   `#n` before filing it.
3. **Stay idempotent.** Before filing a draft ticket, check whether an open
   issue with the same title exists. If one does, record the mapping and move
   on. A compaction mid-filing then costs nothing.
4. **Apply the labels.** `loop-ok` goes on every ticket except those that
   depend on an open question; those get `needs-decision`.
5. **Write `backlog filed: UTC` into the Now block** once every draft ticket
   is mapped. **No ticket is dispatched before that line exists.** The first M0
   ticket deletes the draft, so filing must finish first.
6. **Post the status issue** ([`REPORTING.md`](REPORTING.md#the-status-issue)).

## Tickets

A ticket is a GitHub issue, titled `type: what`. The body:

```
**Milestone:** M1 · **Demo beat:** 3 · **Size:** S

## What
## Why
The demo beat, prize or risk this serves.
## Acceptance
- [ ] statements a reviewer can check against the running app or the tests
## Notes
SPEC.md sections to read, likely files, and dependencies as #n.
```

**Labels:**

- a type: `feat`, `bug`, `ui`, `chore`, `docs` or `submission`
- a priority: `P0`–`P3`
- one or more `area:` labels
- `loop-ok` where it applies

Its milestone is the GitHub milestone of that name.

**Size S or M only.** An L ticket is split before it is filed. A PR a reviewer
cannot hold in their head gets a worse review.

### Priority

| priority | meaning |
|---|---|
| **P0** | `main` is red; the demo path is broken; a submission requirement is still missing in polish or submit |
| **P1** | a demo beat that does not work yet; the wow beat; a targeted prize requirement; the first impression of a demo screen |
| **P2** | depth a judge sees if they poke around; realistic data; edge states on the demo path; the README |
| **P3** | anything a judge will not see in three minutes. Rarely worth filing. |

**Order:** priority, then milestone, then demo-beat order, then unblocked
before blocked, then smaller before larger.

## Re-triage

The backlog is a hypothesis about what matters, and the build teaches things.
**A triage fires when any of these happens:**

- a milestone's last ticket merges
- four PRs have merged since the last triage
- the phase changes (entering polish always triggers one)
- a human comments on the status issue
- a finding or a rehearsal shows the plan is wrong
- **a PR becomes parked**
- **the WIP limit has room, but no ticket is eligible**, for example because
  everything left depends on a parked PR

**Never triage twice for the same state.** Record `last triage: UTC` in the Now
block, and wait for something to change (a merge, a new issue, a comment, a
phase change) before triaging again.

**Run a rehearsal before the triages that close M1, M2 and M4**
([`SUBMIT.md`](SUBMIT.md#rehearsal)).

**Dispatch one triager.** It gets:

- `SPEC.md` and `DESIGN.md`
- **`EVENT.md`'s judging criteria and weights**
- the open and closed issues
- the open loop PRs, with their labels
- the titles of merged PRs
- the latest rehearsal report
- the clock
- every human comment since the last triage

**It returns:**

- **A demo coverage map**: each beat, marked merged, in progress, ticketed or
  missing.
- **Proposed changes**: re-prioritise, split, close as not planned (with the
  reason), move to the cut list, and new tickets, each with its reason tied to
  the demo and the judging criteria. For each PR parked under `unsettled`,
  whether to re-plan its ticket, close the PR, or ask the human.
- **The biggest risk to the demo right now**, and the ticket that addresses it.

The orchestrator applies the changes, subject to [what needs a
decision](#what-needs-a-decision), the card cap, and the phase. Closing an
issue as not planned is reversible.

## What needs a decision

These go to the human rather than being decided by the loop:

- a change to what the product does, who it is for, or the demo story
- dropping a targeted prize
- adding a service that costs money or needs a sign-up
- changing the stack after M0
- anything irreversible or public

**On an issue:** apply `needs-decision` and remove `loop-ok`. Post a `loop:`
comment with the options, what each costs, and a recommendation. Notify the
human ([`REPORTING.md`](REPORTING.md#decisions)). Then carry on with other work.
**A human removing `needs-decision` counts as approval.** Apply `loop-ok`,
unless the human's comment says otherwise, and pass their comment to the
implementer.

**On a PR**, use `unsettled: needs a decision`
([`REVIEW.md`](REVIEW.md#terminal-labels)), never the `needs-decision` label.

A purely technical choice inside the spec is not a decision for the human. Take
the option that is cheapest to reverse, and record why.

## Filing cards

Cards filed during a run come from work already under way: a review finding
outside the PR's scope, a gate failure, a rehearsal. **Do not go hunting.**

- **Check it is not already filed.** List every issue, open and closed,
  paginated (`gh api --paginate "repos/{owner}/{repo}/issues?state=all&per_page=100"`).
  Filter on the subject of the finding.
  - **An open card covers it:** add your evidence as a comment on that card.
  - **A closed card covers it and the problem is back:** file a new card and
    link the old one as a regression.
- **The card must let someone act without asking you anything.** Use the
  ticket format, with evidence read for this card, acceptance criteria, and
  where it came from.
- **`loop-ok` means the loop may build it unattended.** Apply it only to cards
  that stay inside the spec and need no decision. Everything else gets
  `needs-decision`.
- **At most five per lap.** Put any overflow in the status issue.
- **Open the body with** `Filed by the build loop.`
