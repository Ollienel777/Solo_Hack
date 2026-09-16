# Working in this repo

This repository is a harness for solo hackathons. One loop generates and tests
ideas, a second loop builds the chosen idea through reviewed PRs, and the
product itself is built here during the event. This file is loaded into every
session, so it covers only what is easy to get wrong.

| question | read |
|---|---|
| How the harness fits together, and how to run an event with it | `docs/HARNESS.md` |
| Running the ideation loop | `docs/ideation/README.md`, or `/ideate` |
| Running the build loop | `docs/build/README.md`, or `/build-loop` |
| What we are building, and its gate commands | `hackathon/SPEC.md` (exists once the build starts) |
| The design direction | `hackathon/DESIGN.md`, and the `ui-craft` skill |
| The event: clock, judging, prizes | `hackathon/EVENT.md` |

## Branches and PRs

- **Never commit to `main` once the harness is pushed.** All work goes through
  PRs, which are squash-merged.
- **Name branches `type/NUM-slug`**, for example `feat/12-live-transcript`.
- **Title PRs `type(area): what`.**
- **Put a bare `Closes #NUM` in the PR body.** A squash merge carries commit
  bodies onto `main`, so a wrong `Closes` in a commit message closes the wrong
  issue.
- **Never rebase or force-push a pushed branch.** Merge `main` into it instead.
- **The gate is the one in `hackathon/SPEC.md`**, and CI runs the same
  commands. Run all of them before opening a PR. Never report a step as passing
  when it could not run.

## Working alongside the build loop

The loop and you post as the same GitHub account, so it relies on conventions to
tell its work from yours.

- **It touches only PRs labelled `loop`.** Your own PRs are left alone unless
  you add that label.
- **`hold` is your veto.** On a PR or an issue, it stops the loop acting on it
  until you remove the label.
- **Its comments start with a machine prefix**: `cold:`, `semi-cold:`, `fix:`,
  `checks:`, `settled:`, `unsettled:`, `reopened:`, `claimed:`, `released:` or
  `loop:`. **A comment without one is read as yours, and acted on.** Never start
  a comment of your own with one of those prefixes.
- **To answer a decision**, comment, then remove `needs-decision` from the
  issue, or `unsettled` from the PR.
- **Changes to the harness wait for your merge**: `docs/`, `.claude/`, this
  file, `.github/`, `hackathon/EVENT.md`, and the loop's scripts. The loop
  cannot relax its own rules.

## Things that bite

- **No product code before `hacking starts`** (see `hackathon/EVENT.md`). Many
  events disqualify pre-written code. The harness itself is tooling.
- **The repository is public.** `hackathon/ideation/`, `hackathon/DECISION.md`
  and `hackathon/draft/` are gitignored so that nothing publishes the idea
  early. The build loop's spec PR adds `DECISION.md` deliberately, once hacking
  has started. From then on, the tracked copy is the real one: the next pull
  silently replaces your local file with it. Change the decision through a
  comment on the status issue, not by editing the local file.
- **Secrets never enter the repo.** `.env.local` is gitignored, and
  `.env.example` holds names only. Every external service sits behind an
  adapter with a fixture-backed fake, so the app, CI and the demo fallback all
  run without keys.
- **Convert event times with `node scripts/toutc.mjs`.** Git Bash's `date` on
  Windows has no timezone data and silently treats every zone as UTC. In
  PowerShell, a bare `date` prints local time.
- **No attribution stamps.** No "Generated with…", `Co-Authored-By` or session
  links in commits, PRs, reviews, comments or issues.
- **On Windows Git Bash, write `gh api` paths without a leading slash**
  (`repos/{owner}/{repo}/…`).

## Changing the loops' briefs

`docs/ideation/` and `docs/build/` steer unattended agents. Load the
`prompt-writing` skill before editing them.

- **Every rule lives in exactly one file.** Amend it where it lives, rather
  than adding a summary elsewhere. The copy nobody amends is the one someone
  reads.
- **One concern per PR.**
- **Running loops never edit their own brief.** They record lessons as `docs`
  cards (build) or in `hackathon/ideation/LESSONS.md` (ideation) for you to
  apply.
