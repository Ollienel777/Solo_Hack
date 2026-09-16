# Reporting

Read on a **phase change**, whenever a **human is needed**, when the status
issue is due for a rewrite, and at the **end of the run**.

Part of the build brief. See [`README.md`](./README.md).

---

## The status issue

There is one issue, titled `Build status — EVENT NAME`, labelled `status` and
pinned. It is created on the first lap after `hacking starts`. It is never
created before the start, since this repository is public.

**Its body is rewritten, not appended to.** It is the human's dashboard, and
only the latest state matters there. Rewrite it:

- on every phase change
- on every merge
- whenever a new item needs the human
- at least once an hour while the loop runs

**Order the body by urgency:**

1. **Needs you.**
   - decisions, with links
   - human actions: keys, sign-ups, the checklist items
   - latched PRs, each naming what refused the push
   - PRs ready for a human merge (harness changes, or all settled PRs under
     `merge policy: human`)
   - commands that prompted for permission
2. **The clock.** The phase, time to freeze, time to deadline, the run's
   settings and where the mode came from, and the UTC conversions with their
   source times.
3. **Demo coverage.** Each beat: merged, in progress, ticketed or missing. Take
   this from the latest triage or rehearsal, and include the demo-candidate tag
   once one exists.
4. **In flight.** Open loop PRs with their state (routing row, round count,
   checks), and running implementers.
5. **Recently merged**, with what to try in each.
6. **Held back.**
   - clean PRs waiting on checks
   - parked PRs, with their reasons
7. **Capability gaps**, and any gate step that could not run.
8. **Overflow cards**, one line each.

**Before rewriting, read the current body and any new comments.** A comment
without a machine prefix is the human talking. It is input to the lap
([`RULES.md`](RULES.md#loop-prs-and-loop-comments)), and it triggers a triage
([`PLAN.md`](PLAN.md#re-triage)). The loop's own comments on this issue start
with `loop:`. Confirm each rewrite by reading the body back.

## Decisions

When something needs the human:

1. Put it under **Needs you** in the status issue.
2. On the issue or PR itself, post a `loop:` comment with the options, what each
   costs, and a recommendation.
3. **Send a push notification**, if this environment can: one line saying what
   is needed, with a link.

Then carry on with work that does not depend on the answer.

**Notify only for:**

- decisions and blocking human actions
- phase changes
- the draft and final checklists
- three consecutive usage-limit laps
- a missing recurring job
- the run stopping

A notification that fires on every merge gets muted, and then the one that
matters is missed too.

## End of run

When the run stops, for whatever reason:

1. **Post the run report as a `loop:` comment on the status issue**, then
   rewrite the body one last time. The report covers:
   - the settings
   - the stop reason, in the words of [the stopping
     rule](RULES.md#usage-limits-and-stopping)
   - PRs merged
   - PRs still open, with their states
   - cards filed
   - tickets abandoned, and why
   - subagents stopped mid-work
   - decisions outstanding
   - every error that stopped work, **quoted verbatim**

   Be honest. A report that overstates what landed is worse than a short one.
2. **Confirm the comment exists**, by reading back the URL the API returned.
3. **Only then, truncate `.claude/build-log.md`.** The log is gitignored, so a
   truncation after a failed post would lose the run.
4. Notify the human that the run has stopped, and why.
