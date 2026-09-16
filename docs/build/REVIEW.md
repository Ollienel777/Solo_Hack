# Review: selection, state, routing, labels, merging

Read on a lap that **routes a loop PR, reads its state, applies a review label,
handles a human action, or merges**. What to tell a reviewer is in
[`BRIEFS.md`](BRIEFS.md). The fixer, the settle bar and the unfixable cases are
in [`FIX.md`](FIX.md).

Part of the build brief. See [`README.md`](./README.md).

---

## Which PRs get routed

A loop PR is routed this lap when all of these hold:

- it is open and carries the `loop` label
- it has no `hold` label
- **no subagent is in flight on it**, per the registry
- **it is not parked**:
  - it does not carry `unsettled`
  - it is not settled while waiting for a human merge ([`START.md`](START.md#wip-limit))
  - unless a [re-open](#re-opening) or a [human action](#human-actions) has
    fired

**A settled PR that the loop may merge itself is still routed.** Row 0 below
keeps it moving to the merge. A PR with neither review label is unfinished,
whatever its latest marker says.

## What a PR's state is made of

Everything is read from GitHub, so a lap that starts cold can rebuild it.

**Round markers.** Every round posts exactly one PR comment whose first line is
one of these:

```
cold: findings @ SHA7
cold: clean @ SHA7
semi-cold: closes @ SHA7
semi-cold: does not close @ SHA7
```

- **The marker comes first**, with nothing before it. A one-line summary may
  follow on the same line.
- **`SHA7` is the head the round reviewed**, from
  `gh api repos/{owner}/{repo}/pulls/NUM --jq '.head.sha[0:7]'`. Compare SHAs
  in lowercase.
- **The same round submits a review** with `gh pr review NUM --comment`. Its
  body opens with the same marker line and holds the findings. Routing reads
  the comment. Fixers and humans read the review.

**Finding IDs.** Each finding in a round's review has an ID: `R<k>-C<n>`,
`R<k>-M<n>` or `R<k>-N<n>`. **The orchestrator passes `k` to the round**: one
more than the number of round markers already on the PR. A `cold: findings`
review with no parseable Critical or Medium IDs is a **malformed round**. Spawn
a new one.

**Fix replies.** A fixer posts one comment when it finishes. The first line is
`fix: pushed @ SHA7`, `fix: no push @ SHA7` or `fix: hold requested @ SHA7`. The
next lines give one verdict per open finding:

- `R1-M2: fixed`
- `R1-M2: declined, needs a decision`
- `R1-M2: rejected — reason`
- `R1-M2: body edited`
- `R1-M2: not attempted — reason`

**Semi-cold verdicts.** A semi-cold round's review gives one line per open
finding:

- `R1-M2: closed`
- `R1-M2: open`
- `R1-M2: open, needs a decision`
- `R1-M2: withdrawn`

**Record comments** are not rounds:

- `settled: @ SHA7`
- `unsettled: REASON @ SHA7`
- `reopened: SHA7 — WHY`
- `checks: rerun @ SHA7`
- `checks: none @ SHA7`
- `loop: fixer dispatched @ SHA7 — JOB`, which is posted with every fixer
  dispatch and is what the fix caps count

**The open set** is every Critical and Medium ID raised on the PR, minus those
whose latest semi-cold verdict is `closed` or `withdrawn`. Build it from the
round reviews, meaning the reviews whose body starts with a round marker. A
scratch script is fine. **The open set, not the marker type, decides whether
anything is open.**

Read the latest round marker, and its SHA:

```
ROUNDS='^(cold: (findings|clean)|semi-cold: (closes|does not close)) @ ?[0-9a-fA-F]{7}'
LATEST=$(gh api --paginate repos/{owner}/{repo}/issues/NUM/comments \
  --jq ".[] | select(.body | test(\"$ROUNDS\"; \"i\")) | .body | split(\"\n\")[0] | sub(\"\r$\"; \"\")" | tail -1)
printf '%s\n' "$LATEST" | grep -oiE '@ ?[0-9a-f]{7}' | head -1 | grep -oiE '[0-9a-f]{7}' | tr A-F a-f
```

**Check every marker landed.** After each round, read the latest marker back
and confirm its SHA. A malformed marker matches nothing. Re-post it.

## Human input

**A comment is the human's** when all of these hold:

- it has no machine prefix
- its author has `.user.type == "User"`
- its author's `.user.login` is this account

Bots, such as preview-deploy integrations, post without prefixes too, and are
not the human. Human input is read from three places:

- issue comments (`issues/NUM/comments`)
- review bodies (`pulls/NUM/reviews`) with no round marker
- inline review comments (`pulls/NUM/comments`)

**Unanswered** means no `fix:` reply was posted after it.

**A request to wait becomes `hold`.** On lap item 5, the orchestrator reads each
new human comment. If it asks the loop to wait, stop or not merge, apply `hold`
and post a `loop:` comment saying how to release it (remove the label). The
same applies to a fixer's `fix: hold requested` reply.

## Routing

Before routing, apply [re-opening](#re-opening) to any labelled PR whose head
has moved.

Let **L** be the latest round marker, **S** its SHA, and **H** the current
head.
- **"Fixers since L"** means `loop: fixer dispatched … — findings` comments
  newer than both L and the PR's latest `reopened:` marker.
- **A "check fixer at H"** is a `loop: fixer dispatched @ H — check` comment.
- The other fixer jobs are `human` and `conflict`.

**Test the rows in order. The first that matches decides.**

| # | state | next |
|---|---|---|
| 0 | carries `review-settled`, H equals its `settled:` SHA, and it is not parked | an unanswered human comment → row 10's fix. Otherwise, `.mergeable` is `false` → [conflict](#conflicts). Otherwise → wait for [the merge step](#merging). |
| 1 | a `reopened: … — human` marker for a removed `review-settled`, `needs a decision` or `latched` is newer than both L and the latest `fix:` reply | follow [human actions](#human-actions) |
| 2 | no L | **cold round** |
| 3 | open set not empty, and H ≠ S | **semi-cold round**: code has landed |
| 4 | open set not empty, H = S, L is semi-cold, no `fix:` reply newer than L, and every open finding's latest verdict is `open, needs a decision` | `unsettled: needs a decision` ([`FIX.md`](FIX.md#when-a-pr-cannot-be-fixed)) |
| 5 | open set not empty, H = S, and a `fix:` reply newer than L | **semi-cold round**: judge the rejections, body edits and declines |
| 6 | open set not empty, H = S, no `fix:` reply newer than L, and fewer than two fixers since L | **fix** |
| 7 | open set not empty, and two fixers since L with no `fix:` reply | `unsettled: ran out of rounds` |
| 8 | open set empty, and L is `semi-cold: closes` | **cold round**: the settling round |
| 9 | open set empty, L is `cold: clean`, and H ≠ S | **cold round**: new code nobody has read |
| 10 | open set empty, L is `cold: clean`, H = S, and an unanswered human comment | **fix**: the fixer answers the human |
| 11 | open set empty, L is `cold: clean`, H = S | [**checks**](#checks), then the [settle bar](FIX.md#the-settle-bar) |
| 12 | anything else | **cold round** |

**Before any round:**

1. Check the [ceiling](RULES.md#the-round-ceiling).
2. Capture H, and pass H and `k` to the round.
3. When the round finishes, read H again. **If the head moved during the round,
   the round is void.** Spawn a new one against the new head.

## Conflicts

**When `.mergeable` is `false` on a routed PR that would otherwise settle or
merge**, dispatch a fixer to merge `main` in. When it is `null`, GitHub is still
computing it: try again next lap. The fixer's push moves H. On a settled PR,
that is a [re-open](#re-opening), and row 9 then calls a cold round. **Never
merge `main` into a parked PR.**

## Checks

List the head's check runs, and the workflow runs that produced them:

```
SHA=$(gh api repos/{owner}/{repo}/pulls/NUM --jq .head.sha)
gh api repos/{owner}/{repo}/commits/$SHA/check-runs \
  --jq '.check_runs[] | "\(.name) \(.status) \(.conclusion)"'
gh run list --commit "$SHA" --json databaseId,workflowName,conclusion
```

**A red check never blocks reviewing.** It blocks settling and merging. Read the
checks again at settle time and at merge time. Read the conclusion, not a log's
summary line.

**First, the pre-CI exception.** Until `origin/main` has a workflow under
`.github/workflows/`, a PR that changes only documentation (the spec PR) is
treated as having passing checks. It goes straight to the settle bar, and the
merge test accepts it. Every other case below assumes a workflow exists.

At row 11:

- **Every run completed `success`, `neutral` or `skipped`, and at least one
  exists:** go to the settle bar.
- **Anything `queued` or `in_progress`:** wait. Leave the PR unlabelled, and
  list it in the status issue.
- **`main` is red or has no finished run:** take no action on the PR's checks.
  A PR's CI runs against its merge with `main`, so it cannot pass while `main`
  fails. Once `main` is green, re-run the PR's failed runs once.
- **A failure, where the latest review says the diff did not cause it, and no
  `checks: rerun @ H` record exists:**
  1. `gh run rerun RUN_ID --failed`
  2. post `checks: rerun @ SHA7`
- **Any other failure, with no check fixer yet at H:** dispatch one fixer,
  giving it the output of `gh run view RUN_ID --log-failed`.
- **Any other failure, where a check fixer already went at H:** the fixer
  either answered `fix: no push`, or pushed without the head changing. Apply
  `unsettled: ran out of rounds`, and name the check in the status issue.
  **One check fixer per head is the cap.**
- **No check runs on H:**
  1. The first lap to see this posts `checks: none @ SHA7`.
  2. A later lap that still sees none dispatches one fixer to find out why CI
     did not run.
  3. If the fixer finds nothing, apply `unsettled: ran out of rounds`.

**`main` is read the same way every lap**, at `commits/main/check-runs`. Once
a workflow exists, `main` must have at least one completed run. A completed
failure is a P0 ([`RULES.md`](RULES.md#what-a-lap-does)).

## Terminal labels

| label | record comment | means |
|---|---|---|
| `review-settled` | `settled: @ SHA7` | [the settle bar](FIX.md#the-settle-bar) was met at this head |
| `unsettled` | `unsettled: REASON @ SHA7` | findings or checks are open, and the loop cannot close them |

**The reason goes in the comment, never in the label.**

| reason | means |
|---|---|
| `needs a decision` | a finding needs a judgement nobody unattended should make |
| `latched` | a push was refused for a reason other than "not a fast-forward" |
| `ran out of rounds` | the round ceiling, the fix cap, or the check-fixer cap stopped it |

A push refused as "not a fast-forward" means someone else pushed. Fetch again
and re-route.

**When more than one reason applies, `needs a decision` wins, then
`latched`.** Name the losing reason in the comment. **Every label needs a round
from this run behind it.** Notify the human whenever a PR takes `unsettled`
([`REPORTING.md`](REPORTING.md#decisions)). **A PR becoming parked triggers a
triage** ([`PLAN.md`](PLAN.md#re-triage)).

## Re-opening

A labelled PR whose head differs from the SHA in its record comment has new
commits.

1. Post `reopened: SHA7 — commits`.
2. Remove the label.
3. Route the PR. Its round count and fixer count restart from the new marker.

**Act only if no `reopened:` marker is newer than the record comment.**
Otherwise every compaction would re-open the PR again.

## Human actions

**A label removed by a human** shows up as a record comment whose label is
gone, with no `reopened:` marker newer than that record. The second condition
tells the human's removal apart from the loop's own. Post
`reopened: SHA7 — human, was LABEL-OR-REASON`, then:

| removed | next |
|---|---|
| `review-settled` | **cold round**. The human wants another look. |
| `unsettled: needs a decision` | **fix**, handing the fixer every human comment since the record. The human's answer is among them. |
| `unsettled: latched` | **fix**, retrying the push once. If it is refused again, re-apply `latched` and say so in the status issue. |
| `unsettled: ran out of rounds` | route normally, with the counts restarted |
| `hold` | route normally |

## Merging

The merge step runs on lap item 3, and on any notification turn after `main`'s
checks have completed. **It merges at most one PR per lap or turn.** A loop PR
merges under `merge policy: auto` when **all** of these hold, each read fresh:

- **The clock allows it.** Read the clock now. In the submit phase, only P0 and
  `submission` PRs merge. Nothing merges once the phase is over.
- **Nothing has merged since `main`'s checks last completed.**
- **`main` is green.** Its check runs all completed successfully and none is
  pending. Once a workflow exists, at least one run must have completed.
- **The PR is settled at this head.** It carries `loop` and `review-settled`,
  and the SHA in its `settled:` record equals H.
- **No `hold`.**
- **No [harness path](RULES.md#loop-prs-and-loop-comments)** in the diff.
- **Nothing is open.** The open set is empty, and no human comment is
  unanswered.
- **The checks pass.** Every check run on H completed `success`, `neutral` or
  `skipped`, and at least one exists. The pre-CI exception is the only way
  past this.
- **`.mergeable` is `true`.**

Then:

```
gh pr ready NUM
gh pr merge NUM --squash --match-head-commit FULL_SHA
gh api -X DELETE repos/{owner}/{repo}/git/refs/heads/BRANCH
```

`--match-head-commit` refuses the merge if the head moved. The branch is
deleted through the API, because `--delete-branch` also tries to delete a
local branch that a worktree may hold. **Confirm the merge by reading
`.merged` back**, and confirm the linked issue closed. Log it.

**Under `merge policy: human`, and for harness changes,** settled PRs are
parked. They are listed in the status issue as ready to merge, and the loop
goes no further.
