# Standing rules

Read on **every lap**. These rules apply whatever the lap is doing: what is
forbidden, what each phase of the clock allows, what a lap does and in what
order, how subagents are dispatched and tracked, what counts as evidence, and
what gets logged.

Part of the build brief. See [`README.md`](./README.md).

---

## Hard rules

- **Never push to `main`, never force-push, and never rewrite pushed history.**
  A branch that has fallen behind is updated by merging `main` into it.
- **Merge only under `merge policy: auto`, and only PRs that pass [the merge
  test](REVIEW.md#merging).** Never use an admin override and never bypass a
  protection.
- **Touch only loop PRs.** These are PRs labelled `loop`, opened by this loop.
  See [loop PRs](#loop-prs-and-loop-comments).
- **Never deploy to production, create paid resources, buy anything, or change
  repository settings, branch protection or secrets.** Preview deploys a human
  already wired up are fine, since they happen without the loop acting.
  - **Metered API calls on the human's keys** are allowed in exactly two
    places, and kept to the few calls the check needs: the rehearser, and an
    M2 implementer verifying the real integration.
  - Everything else, the gate and CI included, runs in fake mode.
- **Never read or echo a secret, and never commit one.**
  - `.env.example` lists names only.
  - The one permitted handling is copying `.env.local` into a worktree with
    `cp`, for [the rehearser](SUBMIT.md#rehearsal) or [an M2
    implementer](TICKETS.md#the-implementers-brief). The value is never
    displayed.
- **Never sign up for anything, request a key, accept terms, submit the
  hackathon entry, or post anywhere outside this repository.** Each of these is
  a human action. Name it in the status issue.
- **The orchestrator never writes product code and is never the reviewer.**
  Every loop PR gets its review rounds from subagents that did not write it.
- **Every loop PR opens as a draft, labelled `loop`.**
- **Stay inside `SPEC.md`.** A change to what the product does needs a
  decision. See [`PLAN.md`](PLAN.md#what-needs-a-decision).
- **At most five new cards per lap.** Filing the initial backlog is exempt.
- **No attribution stamps that you write**: no "Generated with…", no
  `Co-Authored-By`, no session links. A subagent inherits no local settings, so
  pass this rule to every one of them.
- **Commands in this brief are written for the Bash tool.** PowerShell parses
  `{owner}` and `date -u` differently.

## Loop PRs and loop comments

The loop and the human post as the same GitHub account, so the account cannot
tell them apart. Two conventions do the job instead.

- **The `loop` label is what makes a PR a loop PR.** The loop applies it, plus
  the informational line `Opened by the build loop.`, to every PR it opens. It
  never reviews, pushes to, labels or merges a PR without the label. A human
  hands their own PR to the loop by adding the label.
  - **If a PR the loop dispatched turns up without the label** (the
    registry's branch matches), add the label.
- **Every comment the loop writes starts with a machine prefix**: `cold:`,
  `semi-cold:`, `fix:`, `checks:`, `settled:`, `unsettled:`, `reopened:`,
  `claimed:`, `released:` or `loop:`.
- **Human input** is defined in [`REVIEW.md`](REVIEW.md#human-input): no
  prefix, and posted by this account as a user, not a bot. Pass it in full to
  the next fixer or triager that touches the thread. **A human request to wait
  or not to merge becomes `hold`.**
- **`hold`, applied by a human, is a veto.** A PR or ticket carrying it is left
  alone until the human removes it.
- **Harness changes wait for a human merge.** A loop PR that changes any of
  the following settles normally, is listed as ready in the status issue, and
  is never merged by the loop, so the loop cannot relax its own rules or its CI:
  - `docs/`
  - `.claude/`
  - `CLAUDE.md`
  - `hackathon/EVENT.md`
  - `scripts/setup-labels.sh` or `scripts/toutc.mjs`
  - anything under `.github/`, except while M0 is still open. Before then,
    the scaffold is still being built.
  - `hackathon/SPEC.md` once the spec PR has merged

## The clock

The start-of-run step ([`START.md`](START.md#the-clock)) converts the event's
times to UTC and writes them into the log's Now block. Every lap computes the
phase from them. **Take "now" from `date -u +%Y-%m-%dT%H:%M:%SZ` in Bash**,
never from a bare `date`.

| phase | from → to | what the loop may start |
|---|---|---|
| **pre-start** | before `hacking starts` | `plan-only`, local only ([`START.md`](START.md#the-clock)) |
| **build** | start → `feature freeze` | everything |
| **polish** | freeze → deadline − `submit window` | P0 bugs, demo-path fixes, `ui` polish, `submission` tickets. No new features. |
| **submit** | the last `submit window` | no new implementers. Only P0 and `submission` PRs advance and merge. Final rehearsal and checklist. |
| **over** | from deadline − 10 minutes | nothing: stop every running subagent, write the end-of-run report, and stop |

**A deadline backstop.** At run start, if the scheduler can create a one-time
job, schedule one for deadline − 10 minutes with the prompt
`Stop the build loop now, per docs/build/RULES.md "Usage limits and stopping".`
A long turn can otherwise delay the tick that would notice the phase is over.

**A lap that sees the phase change** reads [`REPORTING.md`](REPORTING.md) and
updates the status issue first. **Entering polish triggers a triage**
([`PLAN.md`](PLAN.md#re-triage)).

**Deadline margins.**
- In the submit phase, dispatch nothing that is not expected to finish before
  deadline − 10 minutes.
- Read the clock again immediately before every merge.

Many events disqualify commits after the deadline, and a merge that starts at
T−1 minute can land after it.

## What a lap does

Work down this list. Independent dispatches go out together. A lap ends once its
dispatches are made and logged. It does not wait for background subagents:
their completions arrive as notifications, which are handled as described in
[notification turns](#notification-turns).

1. **Reconcile.**
   1. Fetch, and fast-forward the local `main`
      (`git fetch origin && git merge --ff-only origin/main`). This checkout
      stays on `main`. Nothing in it is edited except the gitignored output
      folders (`hackathon/draft/`, `hackathon/rehearsals/`).
   2. Read the log's Now block and the phase.
   3. Match the [registry](#dispatching-and-the-registry) against GitHub, and
      release anything stale.
   4. Remove the worktrees of PRs that have merged or closed.
   5. Release the claim of any ticket whose PR was closed without merging.
2. **A red `main` comes first.** File or find a P0 ticket and dispatch it now.
   This item alone may exceed the WIP limit by one. A broken `main` blocks
   every merge and breaks the demo.
3. **Merge**, under `merge policy: auto`: **at most one PR**, P0 first, then
   oldest first, that passes [the merge test](REVIEW.md#merging). Notification
   turns may merge too, once `main`'s checks have reported on the previous
   merge. Waiting for those checks is what stops one bad merge from being
   buried under the next.
4. **Advance loop PRs.** Route each one ([`REVIEW.md`](REVIEW.md#routing)),
   oldest first, skipping any PR with a subagent still in flight. Spawn the
   rounds and fixers that routing calls for.
5. **Answer the human.** Read the new human comments on loop PRs, tickets and
   the status issue.
   - A request to wait or to stop becomes `hold`.
   - Everything else is routed as input.
   - Act on labels a human removed ([`REVIEW.md`](REVIEW.md#human-actions)).
6. **Plan.** Handle the first of these that applies:
   - no spec on `origin/main` and no spec PR open → the spec lap
   - the spec has merged but the draft backlog has not been filed → file it
   - a [triage trigger](PLAN.md#re-triage) has fired → triage
7. **Start new work** if the mode and the phase allow it and the WIP limit has
   room ([`TICKETS.md`](TICKETS.md#choosing-tickets)).
8. **Nothing to do and nothing in flight:** write an `idle` entry and end the
   lap, keeping the job. The loop runs until the phase is **over** or the
   mode's end condition is met ([`START.md`](START.md#modes)).
   - **A cheap idle lap.** If nothing has changed since the last lap (the same
     open PR heads, no new comments, issues or check results), skip the phase
     files.

## Notification turns

When a background subagent finishes, handle only that result:

1. **Check the phase.** Once it is **over**, only stopping happens.
2. **Check on GitHub what it claims**: the PR, the marker, the push, or the
   reply.
3. **Append a `finished:` line** to the registry.
4. **Start that PR's or ticket's next step**, under the same rules as a lap:
   routing, the ceiling and caps, the M0 gate, the WIP limit, and the phase's
   limits.
5. **Run the merge step**, if `main`'s checks have completed since the last
   merge.

Leave everything else for the next lap. **A subagent's report is not
evidence.** GitHub is.

## Dispatching and the registry

- **Every subagent gets worktree isolation**: implementers, fixers, reviewers,
  the planner, the triager and the rehearser. Parallel reviewers that share the
  orchestrator's checkout switch each other's branches.
- **Work on an existing PR happens on a detached checkout.** The subagent runs
  `git fetch origin BRANCH` and `git checkout --detach FETCH_HEAD`, and a fixer
  pushes with `git push origin HEAD:BRANCH`. That way no worktree holds the
  branch another agent needs.
- **Spawn them from the repository root.** Do not pin a weaker model for
  implementing, reviewing, fixing or planning.
- **Pass the rules that bind them explicitly**, not this file, which tells its
  reader it is never the reviewer:
  - never push to `main`, merge, force-push or deploy
  - never read or echo a secret
  - no attribution stamps
  - every comment starts with its machine prefix
  - stay inside the ticket
  - report a needed decision instead of taking it
- **Never run two subagents against the same PR at once.** This covers
  rounds, fixers, and fixers that only merge `main` in.
- **Give every subagent that runs the app its own `PORT`**, so no two collide.
  Use 3100 plus its slot number, and record it in the registry line.
- **Every fixer dispatch posts
  `loop: fixer dispatched @ SHA7 — findings|human|check|conflict`** on the PR.
  The fix caps count these comments, which survive a lost log.
- **Fixers and implementers push once, at the end of their work.** A push is
  what tells routing that a fix has landed.

**The registry** is a section of the log. Every dispatch appends a line, and
every completion appends another:

```
dispatched: ROLE TARGET AGENT UTC
finished: ROLE TARGET AGENT UTC OUTCOME
```

A `dispatched:` line with no matching `finished:` line is in flight. Claims are
also mirrored on GitHub (the `in-progress` label and a `claimed:` comment), so
a compaction that loses the log does not lose a claim.

**Stale work is stopped, then released.** A subagent that has gone silent past
the limit below is stopped first (`TaskStop`), so it cannot keep pushing after
its work has been handed to someone else.

| role | considered lost after | then |
|---|---|---|
| implementer | 120 min with no PR, timed from the registry line, or from the ticket's `claimed:` comment when the registry was lost | stop it if it is still known; remove `in-progress`; comment `released: UTC — no PR`; the ticket may be selected again |
| reviewer | 45 min with no marker | stop it; spawn a new round against the current head |
| fixer | 60 min with no `fix:` reply | stop it; route the PR again |

If two open PRs close the same issue, keep the older one and close the newer
with a `loop:` comment.

## The round ceiling

**Seven rounds per PR per run, cold and semi-cold counted together.** The
ceiling stops one pathological PR from eating the event. It is high enough for
two cycles of findings plus the UI findings that fresh reviewers keep turning
up. Hitting it means fixing what can be fixed, then applying `unsettled` with
the `ran out of rounds` reason.

**Exception: a PR with nothing open may take the one cold round that settles
it**, past the ceiling. Any new finding in that round ends the exception.

Count rounds from their markers, since memory resets on compaction. Count from
the later of the run start and the PR's latest `reopened:` marker:

```
ROUNDS='^(cold: (findings|clean)|semi-cold: (closes|does not close)) @ ?[0-9a-fA-F]{7}'
SINCE=$(grep '^run start: ' .claude/build-log.md | tail -1 | cut -d' ' -f3)
[ -n "$SINCE" ] || { echo "no run start in log"; exit 1; }
REOPENED=$(gh api --paginate repos/{owner}/{repo}/issues/NUM/comments \
  --jq '.[] | select(.body | test("^reopened:"; "i")) | .created_at' | tail -1)
FROM=$(printf '%s\n%s\n' "$SINCE" "$REOPENED" | sort | tail -1)
gh api --paginate repos/{owner}/{repo}/issues/NUM/comments \
  --jq ".[] | select(.created_at > \"$FROM\") | select(.body | test(\"$ROUNDS\"; \"i\")) | .id" | wc -l
```

Declare `ROUNDS` in every shell that uses it. If it is unset, the filter matches
every comment, and the ceiling reads as already spent. A void round (see
[routing](REVIEW.md#routing)) still counts. The query cannot tell it apart, and
over-counting errs on the safe side.

## Evidence

**Anything you publish as measured must come from a command this run ran for
that purpose.** That covers numbers, line references, SHAs, test counts and
quotes. It never comes from memory, from a subagent's report, or from an
earlier run.

- **Write the claim after reading the result.** A message composed while the
  command runs reports what you expected.
- **Never cut a gate's output off before its summary line.**
- **Rejecting a finding needs sources fetched for that reply.** Accepting one
  may lean on an earlier reading.

## Logging

`.claude/build-log.md` is scratch memory for one run, and it is gitignored.

- **The first acts of a run** are the line `run start: UTC`, written as the
  result of `date -u …`, and the Now block.
- **The Now block sits at the top of the log and is rewritten every lap.** It
  holds:
  - the settings, and where the mode came from
  - the event times in UTC, and the offsets they were converted with
  - the phase
  - the in-flight registry lines
  - the draft-to-issue map
  - the time of the last triage and of the last rehearsal
  - the count of consecutive usage-limit laps
  - anything a human is waiting on

  **Each lap reads the Now block and the most recent entries, not the whole
  log.** Everything else is recoverable from GitHub.
- **Each lap appends a dated entry**: what was dispatched and why, what landed,
  and the round counts (`PR #n, cold, round k/7`).
- **Before a lap ends**, unless the run is stopping, read the schedule back and
  confirm the recurring job still exists. If it is gone, notify the human.
- **Truncate the log only at the end of the run**, after the report is posted
  and confirmed ([`REPORTING.md`](REPORTING.md#end-of-run)).
- **A lesson worth keeping becomes a `docs` card**, filed during the run. The
  fix lands through a PR that waits for a human merge.

## Usage limits and stopping

**A command that fails on a usage limit ends the lap, not the run.** Log it,
count it in the Now block, and let the next tick try again. After three
consecutive such laps, notify the human once.

**Stop the run** when the phase is **over**, when the mode's end condition is
met, or when the human asks. To stop:

1. Stop every subagent still in flight (`TaskStop`), and log each one.
2. Write the end-of-run report ([`REPORTING.md`](REPORTING.md#end-of-run)).
3. Delete the recurring job, list the jobs again, and confirm it is gone.
4. Log the reason, in the words of this section.

## GitHub traps

`gh api` fills in `{owner}` and `{repo}` from the current repository.

- **Windows Git Bash rewrites arguments that start with `/`.** Write API paths
  as `repos/…`.
- **The PR author is `.user.login`.** `.author` is `null` on REST. This loop
  identifies its PRs by the `loop` label anyway.
- **Read comments with `gh api --paginate repos/{owner}/{repo}/issues/NUM/comments`.**
  Never use `gh pr view --json comments`, which returns the first 100. With
  `--paginate`, `--jq` runs once per page, so stream the output and take
  `tail -1`. REST spells the field `created_at`.
- **Strip `\r` from the first line of a body.** Compare SHAs in lowercase.
- **Checks come from `commits/SHA/check-runs`**, never from
  `commits/SHA/status`.
- **Post bodies with `--body-file -` and a quoted heredoc** (`<<'EOF'`).
  Backticks inside `--body "…"` run as commands.
- **Anything shaped like an HTML tag is stripped from what you post.** Use a
  plain word for placeholders.
- **A squash merge carries every commit body onto `main`.** A `Closes #N` in a
  commit body closes that issue.
- **A closed issue is either `completed` or `not_planned`.** Read
  `state_reason`.
- **Search endpoints lag and under-report.** List and filter instead.
- **`gh pr list` returns 30 rows unless given `--limit`.**
- **Use a parser when you parse a standard format.** A second hand-written
  pattern where one has already failed is the sign to change approach.
