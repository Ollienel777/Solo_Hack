---
name: build-loop
description: Start the autonomous hackathon build loop that docs/build/ describes. It turns hackathon/DECISION.md into a spec and GitHub-issue backlog, dispatches implementer subagents in parallel worktrees, reviews every PR with fresh subagents, fixes, merges what settles, re-triages what is most valuable for the demo, and prepares the submission. Accepts a mode (build, review-only, plan-only) and an interval. Use when the user asks to start, resume, stop or run the build loop, build the chosen idea autonomously, or work the backlog unattended.
---

# Build loop

Start a `/loop` that follows the build brief in `docs/build/`. This skill starts
and stops the loop. It does not govern it. **Do not restate the brief's rules
here or in the prompt.**

## Starting

Invoke the `loop` skill with the interval and this prompt, with the mode filled
in:

```
Read docs/build/README.md and follow the brief it indexes, per the reading protocol in it. Read the Now block and latest entries of .claude/build-log.md first each iteration so you do not repeat work. Mode: MODE.
```

| the user typed | mode | interval |
|---|---|---|
| `/build-loop` | [you choose](#choosing-the-mode) | `10m` |
| `/build-loop build`, `/build-loop review-only`, `/build-loop plan-only` | as given | `10m` |
| `/build-loop build 5m` | as given | as given |

**Pass `Mode:` every time.** The brief requires the run to record where its mode
came from. Mode is the only setting passed this way. Changing `merge policy`
means editing `docs/build/START.md`, and that edit waits for a human merge like
any harness change. If the user asks for it, say so.

**Before starting, say which mode, and why, in one line.**

## Choosing the mode

Check the actual state:

- **No `hackathon/DECISION.md`:** there is nothing to build. Point the user to
  `/ideate`, and do not start.
- **Before `hacking starts`:** use `plan-only`. The brief keeps it local, in
  `hackathon/draft/`. Convert the start time with `node scripts/toutc.mjs`,
  never with `date`.
- **Many open loop PRs, none settled:** use `review-only`. Count them:

  ```
  gh pr list --state open --label loop --limit 200 --json number,labels --jq '[length, ([.[] | select(any(.labels[]; .name == "review-settled"))] | length)]'
  ```

- **Otherwise:** use `build`.

## Before starting, check and tell the user

Only report what is actually true right now.

- **`main` must exist on the remote** (`git ls-remote --heads origin main`). If
  it does not, the harness has not been pushed, and no PR has a base. Offer to
  commit and push the harness. **Make sure `hackathon/DECISION.md` and
  `hackathon/ideation/` stay out of that commit.** Both are gitignored. Check
  with `git status` before committing.
- **The local checkout must be on `main` and clean.** The orchestrator
  fast-forwards it every lap.
- **Labels.** Run `scripts/setup-labels.sh` if `gh label list` lacks `loop`,
  `loop-ok` or `review-settled`.
- **Permissions.** An unattended run stalls on its first prompt, and background
  subagents may not inherit the session's permission mode. The run checks this
  on its first lap. Tell the user now that the session should be in a mode that
  will not prompt for `git`, `gh`, the package manager, `node` and the test
  tools.
- **Machine.** Keep this session open and the machine awake for the whole
  event.
- **How the loop tells its work apart.** It touches only PRs labelled `loop`.
  The user's own PRs are safe unless they add that label. `hold` is the user's
  veto on anything. The pinned status issue is the dashboard, and replies
  there are read.

## Interval

**Use a fixed interval, never self-pacing.** A fixed interval re-arms itself,
fires only between turns, and fires a missed tick once rather than once per
interval. `10m` is the default. Subagent completions also wake the session, so a
longer interval costs little. Recurring jobs expire seven days after creation,
which is longer than any hackathon.

## Stopping

When the user asks to stop:

1. Stop every background subagent the loop has in flight. They are listed in
   the Now block's registry.
2. Follow the end-of-run steps in `docs/build/REPORTING.md`.
3. Delete the recurring job, and confirm it is gone.
