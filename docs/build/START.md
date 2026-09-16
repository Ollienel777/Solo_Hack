# Run start

Read **once, at the start of a run**: the run's settings, the capability
checks, and the clock. None of it changes mid-run.

Part of the build brief. See [`README.md`](./README.md).

---

## This run

The operator rewrites this block for each run. It holds settings, never rules.

```
mode: build            # build | review-only | plan-only
merge policy: auto     # auto | human
wip limit: 3
```

**If the block is missing, or a value is one you do not recognise, stop and
ask.**

**A `Mode:` passed in the starting instruction overrides `mode:` here.** Mode is
the only setting that may arrive that way. `merge policy` decides whether the
run merges into `main` unattended, and that takes an operator writing it down.

**Write the settings you are operating under, and where the mode came from,
into the log's Now block now.** Put them in the status issue once it exists.

### Modes

| mode | spec, backlog, triage | implement tickets | review, fix | merge |
|---|---|---|---|---|
| `build` | yes | yes | yes | per merge policy |
| `review-only` | filing cards only | **no** | yes | per merge policy |
| `plan-only` | yes | **no** | the spec PR only | the spec PR only |

**How each mode ends:**

- **`build`** runs until the phase is over.
- **`review-only`** ends when no loop PR needs a round, a fix or a merge.
- **`plan-only`** ends once the backlog is filed. Before the start, it ends
  once the local drafts are written ([below](#the-clock)).

### Merge policy

- **`auto`**: the run squash-merges loop PRs that pass [the merge
  test](REVIEW.md#merging). In a solo hackathon, ticket N+1 usually builds on
  ticket N, and a queue of unmerged drafts stacks up conflicts.
- **`human`**: the run settles PRs and lists them in the status issue. A human
  merges them.

Harness changes always wait for a human
([`RULES.md`](RULES.md#loop-prs-and-loop-comments)).

### WIP limit

The most work the loop keeps in progress at once. It counts two things:

- implementers that have not yet opened a PR
- open loop PRs that are **not** parked

A PR is **parked** while it carries `unsettled` or `hold`, or while it is
settled and waiting for a human merge. That happens under `merge policy:
human`, and for harness changes. Parked PRs do not count toward the WIP limit,
since otherwise a few PRs waiting on the human would stop all work.

- **Settled PRs waiting for a merge still hold their areas.** They are about to
  land, and new work in the same area would conflict with them.
- **Other parked PRs release their areas.** A conflict one of them develops is
  dealt with once it is unparked.

Parallel work is the loop's main lever on speed, and conflicts are its main
cost. Three is a sensible default for a solo repo.

## First: establish what you can actually do

Check each item, and log the results in one block. **Name every gap in the
status issue.**

- **Identity and repository.**
  - `gh api user --jq .login` answers.
  - `gh repo view --json nameWithOwner,visibility` answers.
  - `git ls-remote --heads origin main` shows a `main` branch. **If it does
    not, stop and ask the human to push the harness.** A PR needs a base.
  - The local checkout is on `main` and clean, apart from ignored files.
- **Labels and milestones.** Run [`scripts/setup-labels.sh`](../../scripts/setup-labels.sh).
  It is idempotent.
- **CI.** Whether `origin/main` carries a workflow under `.github/workflows/`.
- **Toolchain.** The versions of `node`, the package manager, `python` and
  `docker`, and, once the scaffold has installed it, `npx playwright --version`.
- **Subagents.** Dispatch one throwaway background subagent with worktree
  isolation. It runs `git status`, `gh api user --jq .login`, and the package
  manager's `--version`, then reports whether anything prompted for permission
  and whether it got its own worktree. Subagents do not reliably inherit the
  session's permission mode.
  - **Permission prompts:** an unattended run stalls on the first one. Stop and
    tell the human which commands prompted.
  - **No worktree:** run with the WIP limit at 1, one subagent at a time, and
    say so.
- **Notifications.** Whether this environment can send the human a push
  notification.
- **Secrets, by name only.**
  - Record the keys `SPEC.md` needs, whether `.env.local` exists (`test -f`),
    and the names listed by `gh secret list`.
  - **Never read, print or copy a value here.** A missing key means the fake
    adapter stays in use ([keyless development](PLAN.md#keyless-development)).

## The clock

Read `hacking starts`, `feature freeze`, `submission deadline` and
`submit window` from `hackathon/EVENT.md`. Convert each time with:

```
node scripts/toutc.mjs 2026-10-03 18:00 America/Toronto
```

**Never convert with `date`.** Git Bash on Windows has no timezone data, and
treats every zone as UTC without an error. Write each converted time into the
Now block, together with its local form and zone, so a wrong conversion is
visible.

- **`feature freeze: default`:** use the deadline minus 20% of the hacking
  window, and never less than 3 hours before the deadline.
- **Any of the three times is `TODO`, or the script exits non-zero:** stop and
  ask. Every phase depends on them.

**Before `hacking starts`, only `plan-only` runs, and nothing that could reveal
the idea reaches GitHub.** The generic labels from `setup-labels.sh` are fine.
The planner writes its drafts into `hackathon/draft/`, which is gitignored:
`SPEC.md`, `DESIGN.md` and `backlog-draft.md`. It opens no PR, pushes nothing
and files nothing. Many events forbid code written before the start, and this
repository is public. A `build` or `review-only` run started early says why it
cannot start yet, and stops. After the start, [the spec
lap](PLAN.md#the-spec-lap) begins from those drafts.
