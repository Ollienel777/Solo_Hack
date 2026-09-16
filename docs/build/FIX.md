# Fix: the fixer, the settle bar, and unfixable PRs

Read on a lap that **dispatches a fixer, settles a PR, or decides a PR cannot
be fixed**.

Part of the build brief. See [`README.md`](./README.md).

---

## The cycle

1. A **cold** round reviews the PR.
2. A **fixer** acts on the findings and posts a `fix:` reply.
3. A **semi-cold** round gives a verdict on every open finding.
4. Once the open set is empty, a fresh **cold** round decides whether the PR
   settles.

**Never describe a fix inside the review that found it.** No independent
reviewer would then check the fix.

## The fixer's brief

A fixer is dispatched for one of four jobs:

- findings (routing rows 6 and 7)
- an unanswered human comment (row 10)
- a failing check
- a merge conflict

**Its setup:**

- its own worktree, checked out detached at the PR's head
  (`git fetch origin BRANCH`, then `git checkout --detach FETCH_HEAD`)
- the linked ticket, and the context an implementer gets
  ([`TICKETS.md`](TICKETS.md#the-implementers-brief))

**What to hand it for each job:**

- **Findings.** The open set, taken from the round reviews. For the latest
  round, use the review whose first line **equals** the latest marker line. If
  no review matches, that round's review never landed. Treat the round as
  void, and spawn a new one instead of a fixer.

  ```
  ROUNDS='^(cold: (findings|clean)|semi-cold: (closes|does not close)) @ ?[0-9a-fA-F]{7}'
  gh api --paginate repos/{owner}/{repo}/pulls/NUM/reviews \
    --jq ".[] | select(.body | test(\"$ROUNDS\"; \"i\")) | \"\(.id) \(.body | split(\"\n\")[0] | sub(\"\r$\"; \"\"))\""
  gh api repos/{owner}/{repo}/pulls/NUM/reviews/REVIEW_ID --jq .body
  ```

  Also hand it every human comment since the latest round. A human's answer to
  a decision is among them.
- **A human comment.** The comment, verbatim. The fixer answers it: a change
  if one is asked for, otherwise a reply.
- **A failing check.** The failing job's log, from
  `gh run view RUN_ID --log-failed`.
- **A conflict.** The instruction to merge `origin/main` into the branch and
  resolve the conflict. **Never rebase.**

**What it does:**

- **Fix every Critical and Medium that needs no decision.** When fixing a wrong
  claim, grep for every copy of it.
- **Decline anything that needs a product decision.** Say why.
- **Reject a finding only with evidence** read for the rejection.
- **Fix a finding about the PR body by editing the body**, then read it back to
  confirm the edit took.
- **Run the full gate.**
- **Push once, at the end**, with `git push origin HEAD:BRANCH`.
- **Post exactly one reply**, with the per-finding lines described in
  [fix replies](REVIEW.md#what-a-prs-state-is-made-of). It starts
  `fix: pushed @ SHA7` if it pushed, and `fix: no push @ SHA7` otherwise. It
  says what changed, without arguing that it is right.

**Rules to pass explicitly:** the list in [dispatching](RULES.md#dispatching-and-the-registry).

Before routing the PR again, confirm on GitHub that the reply exists, and that
the push exists if the reply claims one.

## The settle bar

Apply `review-settled`, and post `settled: @ SHA7`, only when **all** of these
hold at the current head:

- **The latest round is a cold round at this head**, and it raised no
  Critical and no Medium.
- **The open set is empty.** Every Critical and Medium ever raised has been
  closed or withdrawn by a semi-cold verdict.
- **The checks pass** ([checks](REVIEW.md#checks)): every run completed green,
  and at least one exists.
  - **Pre-CI exception:** while `origin/main` has no workflow and the PR
    changes only documentation, zero check runs does not block. That covers
    the spec PR.
- **No human comment is unanswered.**
- **Only a cold reviewer's verdict earns the label.** Never this session's,
  and never a semi-cold round's.

**One clean cold round is enough here.** ClipFarm requires two in a row for a
PR that never had a finding. This brief trades that certainty for hours, and
leans on the gate's demo-path smoke test and on the rehearsals
([`SUBMIT.md`](SUBMIT.md#rehearsal)).

## Freeze the head once nothing is open

**Once the open set is empty, only a new Critical or Medium, a failing check, a
conflict, or a human request may change the head.** A nit fix would earn
another cold round, which can find another nit. A converged PR can cycle that
way until the ceiling stops it. Nits wait for a polish card, or are left alone.

## When a PR cannot be fixed

Push everything that can be fixed first. Then apply `unsettled` with the
[reason](REVIEW.md#terminal-labels) that fits, and post its record comment:

- **`needs a decision`**, when the only open findings are ones a semi-cold round
  agreed need a human. The comment gives:
  - each open finding, with its options and a recommendation
  - what the human does next: answer in a comment, then remove the label
- **`latched`**, when a push was refused by something other than a
  fast-forward check. The comment names what refused it, and what was being
  pushed. The status issue names it too.
- **`ran out of rounds`**, when the round ceiling, the findings-fixer cap or
  the check-fixer cap was hit. The comment names which one, and for a check,
  which check and its conclusion.

**An `unsettled` PR is parked**
([`START.md`](START.md#wip-limit)): no rounds, no fixers, no merges from
`main`, until a human acts or new commits arrive. The triager decides whether
to re-plan its ticket or close the PR. The ticket keeps `in-progress` in the
meantime.
