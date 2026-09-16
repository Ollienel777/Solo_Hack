---
name: review-pr
description: Review a pull request by hand, with findings tiered critical / medium / nit, design challenges where warranted, and a plain merge verdict. Use when the user asks to review a PR, asks whether a PR is good to merge, or names a PR number and wants it looked at.
---

# Review a PR

Run a tiered review of a pull request and answer the merge question outright.
This is a review for the human in front of you. The build loop's review rounds
are a different mechanism, described in `docs/build/BRIEFS.md`.

## What to do

Invoke the `code-review` skill against the PR the user named:

```
/code-review high PR #NUM with flags on critical, medium, and nit tiers and challenges on design where appropriate. Is it good to merge?
```

If the user gave no PR number, ask for one. Reviewing the working tree instead
answers a different question.

**Post nothing to the PR unless the user asks.** If they do, never begin a
comment with a loop prefix (the list is in `CLAUDE.md`). The build loop routes
on those, and a hand review wearing one would move a PR through its cycle. A
comment without a prefix on a loop PR is read by the loop as the human's
request, and it will act on it. Say that before posting.

## What the answer has to contain

**Tier every finding**, and make the tiers mean what they say. They match the
build loop's tiers:

- **Critical.** Wrong behaviour, data loss, a security hole, a broken demo
  path, or a claim in the diff that is false. Blocks merge.
- **Medium.** A real defect that will cost someone later: a missed case, a test
  that passes for the wrong reason, an acceptance criterion not met, or an
  objective UI defect on a demo-path screen at 1440×900. Blocks merge unless
  the author says why not.
- **Nit.** Style, naming, wording, or polish off the demo path. Never blocks
  merge.

**Anchor every finding to `file:line`**, and quote the line. A finding without
a location is not yet a finding.

**Review anything visible from screenshots**, using the `ui-craft` skill's
rubric. Run the app and capture the screens the diff touches.

**Challenge the design where it deserves it**, separately from the findings.
Ask whether the change solves the right problem, whether a simpler shape
exists, and whether it contradicts something already in the repo, including
`hackathon/SPEC.md`.

**End with the merge verdict in one line**: good to merge or not, and what
would change it.

## Verify before reporting

**Check every finding against the code on the PR's head**, not against memory
of an earlier look. A finding that does not reproduce is withdrawn, not
softened.

**Where a finding says a test is inadequate, mutate the code it covers and
show that the test still passes.** Make the mutation carefully. One that fails
for an unrelated reason proves nothing. If a mutation turns many tests red, you
broke something other than what you meant to.

**Quote only what you fetched in this round.** Line numbers, SHAs and counts go
stale between rounds.

## On re-review

When the user says changes were made, **read the new head before responding**.
If the head SHA has not moved, say so plainly and show that the findings still
reproduce.
