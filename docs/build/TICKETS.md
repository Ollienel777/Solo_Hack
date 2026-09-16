# Tickets: choosing, claiming, implementing

Read on a lap that **dispatches an implementer**.

Part of the build brief. See [`README.md`](./README.md).

---

## Choosing tickets

A ticket is eligible when all of these hold:

- The Now block has `backlog filed:` ([filing](PLAN.md#filing-the-backlog)).
- It is open and labelled `loop-ok`.
- It carries none of `in-progress`, `needs-decision` or `hold`.
- Every dependency named in its Notes is closed as `completed`.
- [The phase](RULES.md#the-clock) allows its type and priority.
- **It passes the M0 gate.** While any M0 ticket is open, only M0 tickets are
  eligible, and only one of them may be in flight at a time.
- **None of its `area:` labels is shared with active work.** Active work means
  a running implementer, an open loop PR that is not
  [parked](START.md#wip-limit), or a settled PR waiting for a human merge. A
  PR's areas are those of the ticket it closes. `area:docs` is exempt.

Take eligible tickets in [priority order](PLAN.md#priority) until the WIP limit
is full. Parallel work in separate areas is how the loop keeps pace.

**Claim before dispatching.**

1. Add the `in-progress` label.
2. Comment `claimed: UTC`.
3. Append the dispatch to the [registry](RULES.md#dispatching-and-the-registry).

## The implementer's brief

The implementer works alone, in its own worktree, and never sees the rest of
the run. Give it generous context: every judgement call it makes goes better if
it knows what the ticket is for.

**Context to give it:**

- what the product is (the one-liner from `SPEC.md`)
- what the hackathon rewards (a three-minute demo)
- the demo beat or prize this ticket serves
- how much time is left
- that a reviewer who knows nothing of its reasoning will read the PR, and that
  the PR may merge unattended

**What to point it at:**

- the ticket
- the `SPEC.md` sections the ticket names, and the gate section
- `hackathon/DESIGN.md` and the `ui-craft` skill, for anything a user sees
- `CLAUDE.md`

**What to ask it for:**

- **A branch named `type/NUM-slug`**, cut from the latest `origin/main`.
- **An implementation that meets the acceptance criteria, and nothing
  more.** It reports anything out of scope it notices, rather than fixing it.
- **A repository that matches `SPEC.md`.** Make the repo's scripts match the
  gate as written. **Never edit `SPEC.md`.** If the spec is wrong, report it.
- **Tests that would fail if an acceptance criterion were not met.**
- **The full gate from `SPEC.md`, passing**, with the summary lines quoted
  verbatim in its report. If a step cannot run in its environment, it says so
  and does not call that step passed.
- **For anything visible:** run the app on its own `PORT`, look at every
  screen it touched, and hold them to the `ui-craft` rubric before opening the
  PR.
- **One push, at the end.** Then open a draft PR, following
  `.github/pull_request_template.md`, that:
  - carries the `loop` label and the line `Opened by the build loop.`
  - has a bare `Closes #NUM` line
  - gives concrete verification steps
  - **says what changed, without arguing that it is right**. An argumentative
    body anchors every reviewer who reads it.
- **When it cannot finish:** a comment on the ticket, starting `released:`,
  giving the reason. For example, the ticket needs a product decision, or it is
  bigger than size M (with a proposed split). No PR in that case.
- **A one-line report**: the PR number, or the reason it stopped.

**Rules to pass explicitly:** the list in [dispatching](RULES.md#dispatching-and-the-registry),
plus "use the adapter's fake when a key is missing", and its `PORT`.

**An M2 ticket verifying a real integration** is also told:

- it may copy the main checkout's `.env.local` (give it the absolute path)
  into its worktree with `cp`, never displaying it
- to make only the few live calls the check needs
- that the gate and the tests stay in fake mode

## When it returns

**Check GitHub, not the report.** The PR should:

- exist and be a draft
- carry the `loop` label
- target `main`
- have `Closes #NUM` in its body

Append `finished:` to the registry. The ticket keeps `in-progress` until its PR
merges or closes. The next lap routes the PR, and its first round is always
cold.

**No PR, and a `released:` comment exists:**

- Remove `in-progress`.
- **Split proposed:** the split becomes new cards per
  [filing](PLAN.md#filing-cards), and the original is closed as not planned,
  with a link to them.
- **Decision needed:** the ticket gets `needs-decision`.
- **Gate could not run in this environment:** apply `hold`, with a `loop:`
  comment naming the missing capability. Put it in the status issue. The human
  removes `hold` once the environment is fixed.

The labels are what keep the ticket from being dispatched again. A reason held
only in memory would not survive a compaction.
