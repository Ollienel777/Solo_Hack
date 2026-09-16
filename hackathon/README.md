# This event

Everything in this folder belongs to one hackathon. It is rewritten for each
event, so nothing in it may carry a rule. Rules live in `docs/`.

| path | written by | committed |
|---|---|---|
| `EVENT.md` | you, before ideation | yes |
| `tracks/` | you, or `/ideate` from what you paste | yes |
| `ideation/` | the ideation loop | **never**: gitignored, and the repo is public |
| `DECISION.md` | `/ideate decide` | gitignored. The build loop's spec PR adds it once hacking starts. |
| `draft/` | the build planner, before hacking starts | **never** |
| `SPEC.md`, `DESIGN.md` | the build planner | yes, through the spec PR |
| `backlog-draft.md` | the build planner | yes, then deleted by the first M0 ticket |
| `rehearsals/` | the build loop's rehearser | **never** |
| `submission/` | the build loop, in the polish phase | yes |

**For the next event**, clear everything here except `README.md`,
`tracks/README.md` and `EVENT.md`, and reset `EVENT.md`'s fields to `TODO`.
