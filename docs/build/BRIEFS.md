# Reviewer briefs

Read on a lap that **spawns a review round**, cold or semi-cold. Which round to
spawn is decided by [routing](REVIEW.md#routing).

Part of the build brief. See [`README.md`](./README.md).

---

## Why rounds are subagents

The session that dispatched the code is the most anchored reviewer there is:
once it has judged a file fine, the file stops being visible to it. A fresh
subagent is a *different* reviewer. It runs on the same model with the same
priors, so it finds different things rather than all things, and the cycle
depends on that difference.

- **A cold round** gets the PR number, the head SHA and this brief, and nothing
  about how the diff came to be. The first round on a PR is always cold, and so
  is the round that settles it.
- **A semi-cold round** checks fixes. It gets the open set, the fixer's reply,
  any human comments, and the commits since the latest round. In exchange for
  being anchored, it can answer what a cold round cannot: *is this finding
  closed?*

**Both are cold to this session, not to the PR.** They will read the PR body
and its threads, so those should say what changed and never argue that the
change is right.

## What every round is told

- **Context.** What the product is (the one-liner from `SPEC.md`). That the
  event is judged on a three-minute demo, so defects on the demo path matter
  most.
- **Where to work.** Its own worktree, checked out detached at the SHA you
  captured: `git fetch origin BRANCH`, then `git checkout --detach SHA`. **It
  never fetches its own head.** A push during the round would otherwise go
  unreviewed. It runs the app on its own `PORT`.
- **The current checks.** If one is red, the review says whether the diff
  caused it.
- **How to post.** Both artifacts are posted with a quoted heredoc
  (`--body-file - <<'EOF'`). Backticks inside `--body "…"` run as commands.
  1. **One comment** (`gh pr comment NUM`) whose body starts with the literal
     marker at that SHA ([markers](REVIEW.md#what-a-prs-state-is-made-of)).
  2. **One review** (`gh pr review NUM --comment`) whose body opens with the
     same marker line and then lists the findings, each with its ID
     (`R<k>-C<n>`, `R<k>-M<n>`, `R<k>-N<n>`). Here `k` is this round's position
     among the PR's round markers, counting its own.
  3. **Never** `/code-review --comment`.

  A clean round still submits a review, saying what it checked.
- **The rules that bind it:**
  - never push, merge or deploy
  - never echo a secret
  - no attribution stamps
  - no other comments

**Tiers:**

| tier | meaning |
|---|---|
| **Critical** | wrong behaviour, data loss, a security hole, a demo beat that breaks, or a claim in the diff that is false |
| **Medium** | a real defect someone pays for later: a missed case, a test that passes for the wrong reason, an acceptance criterion not met, or an **objective** visible defect on a demo-path screen at 1440×900 (per the `ui-craft` rubric) |
| **Nit** | style, naming, wording, taste, mobile layout, or polish off the demo path. Never blocks. A nit worth doing is suggested as a polish card. |

**Anchor every finding to `file:line` at the reviewed SHA, and open that
location before citing it.** A path that resolves is not proof that the file
says what the finding claims.

## The cold reviewer's brief

**Run `/code-review high NUM`, naming the PR number.** Left to find a diff by
itself, the review has been seen reviewing `main`'s tip instead.

- **Check what it reviewed.** The files it names must be in the PR's diff.
- **If they are not, or the skill cannot run here,** review by hand and say so
  in the review.
- **Never use `/code-review ultra`.**

The skill's output is a starting point. The round must also cover these:

- **Acceptance.** Read the linked issue, and check every acceptance criterion
  against the code and the tests. An unmet criterion is a Medium.
- **Prose against behaviour.** Check the claims in comments, docstrings, commit
  messages and the PR body against what the code does. A sentence the diff
  makes false is one of the commonest defects a loop produces.
- **Tests that cannot fail.** Where a test looks inadequate, mutate the code it
  covers, and show that the test still passes. Make the mutation carefully: one
  that fails for an unrelated reason proves nothing. A loop assertion over a
  possibly empty list passes vacuously.
- **Claims about things outside the diff** (another PR, `main`, a tool's
  behaviour), checked against their current state.
- **Design.** Whether the change solves the ticket's actual problem, and
  whether there is a simpler shape. Kept separate from the findings.
- **Anything visible.** Run the app, and apply the `ui-craft` rubric to every
  screen the diff touches, from screenshots taken in this round.

**Write a sentence claiming a gap is closed only after running the check that
closes it.**

## The semi-cold reviewer's brief

**It gets:**

- **the open set**: every open Critical and Medium, with its ID and text, taken
  from the round reviews that raised it
- the fixer's latest `fix:` reply
- every human comment since the latest round
- the commit range from the latest round's SHA to the captured head, which may
  be empty

**For every finding in the open set, it gives one verdict line:**

- `closed`: the code, the tests or the PR body now resolve it, checked against
  the code rather than against the reply
- `open`
- `open, needs a decision`: it agrees a human has to decide
- `withdrawn`: it agrees with the fixer's rejection, for a stated reason

**Then it reviews the commit range** for anything new at Critical or Medium,
with new IDs.

**Its marker** is `semi-cold: closes @ SHA7` only if every verdict is `closed`
or `withdrawn` and nothing new was raised. Otherwise it is
`semi-cold: does not close @ SHA7`.

- **An empty commit range is normal** after a `fix: no push` reply. Judge the
  rejections, body edits and declines on their merits. A finding that needed a
  code change stays `open`.
- **A semi-cold round never settles a PR.** It inherited the previous
  reviewer's conclusions, so its silence inherits their blind spots.

## Spec PRs

The spec PR ([`PLAN.md`](PLAN.md#the-spec-lap)) gets a cold round with a
different focus. A document gives the code-review skill little to work with, so
the round reviews by hand.

It checks:

- **Faithfulness.** The spec against `DECISION.md`, especially the human's
  notes at the top.
- **Coverage.** Every demo beat is reachable through the milestones and the
  backlog draft. Every targeted prize requirement has a ticket.
- **Dependencies.** Each external dependency has a source. Each one needing a
  key has a fake. No step silently waits on a human.
- **The gate.** Its commands are concrete, fit the chosen stack, and meet
  [the gate requirements](PLAN.md#what-specmd-contains). They cannot be run
  yet, because no code exists.
- **Tickets.** Every draft ticket is size S or M, with checkable acceptance
  criteria. The first M0 ticket carries CI. The areas are fine-grained enough
  for parallel work.
- **Design.** `DESIGN.md` meets the `ui-craft` standard for a design direction.
- **Open questions** are listed, each with the tickets it blocks, rather than
  left to block the whole spec.

Anything that would make the backlog build the wrong product is Critical.
