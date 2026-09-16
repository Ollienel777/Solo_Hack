#!/bin/sh
# Create or update the labels and milestones the build loop relies on.
# Idempotent: safe to re-run. Needs an authenticated `gh` inside this repo.
# Project-specific area labels are created by the build loop when it files the backlog.
set -eu

label() {
  gh label create "$1" --color "$2" --description "$3" --force >/dev/null
  echo "label: $1"
}

# Priority
label P0 b60205 "Demo or main is broken; drop everything"
label P1 d93f0b "A demo beat, the wow moment, or a targeted prize"
label P2 fbca04 "Depth a judge sees when they poke around"
label P3 c2e0c6 "A judge will not see it in three minutes"

# Type
label feat 1d76db "New capability"
label bug d73a4a "Something is broken"
label ui 5319e7 "Visible polish or design work"
label chore bfdadc "Tooling, CI, housekeeping"
label docs 0075ca "Documentation"
label submission 0e8a16 "Submission materials"
label status 000000 "The build loop's status issue"

# Areas: the planner creates one per screen or module from SPEC.md.
# area:docs is the only fixed one, and is exempt from area exclusivity.
label area:docs c5def5 "Docs; exempt from area exclusivity"

# Loop gates and state
label loop 0052cc "Opened by the build loop; the only PRs the loop touches"
label loop-ok 0e8a16 "The loop may build this unattended"
label in-progress fef2c0 "Claimed by a loop implementer"
label needs-decision e99695 "Waiting on a human decision"
label hold cccccc "Parked by a human or a triage"
label review-settled 2ea44f "Review cycle finished clean at the recorded head"
label unsettled e4e669 "Open findings the loop cannot close; see the unsettled comment"

# Milestones (listed with state=all so closed ones are not re-created)
existing=$(gh api --paginate "repos/{owner}/{repo}/milestones?state=all&per_page=100" --jq '.[].title')
milestone() {
  if printf '%s\n' "$existing" | grep -Fxq "$1"; then
    echo "milestone exists: $1"
  else
    gh api "repos/{owner}/{repo}/milestones" -f title="$1" -f description="$2" >/dev/null
    echo "milestone: $1"
  fi
}
milestone "M0 Skeleton" "Scaffold, CI gate, tokens, app shell, fakes, smoke test"
milestone "M1 Demo path" "Every demo beat works end to end on fakes"
milestone "M2 Wow" "The hard part works for real, with fallbacks"
milestone "M3 Prizes" "Every targeted prize requirement visibly met"
milestone "M4 Polish" "Every demo screen passes the ui-craft rubric"
milestone "M5 Submission" "README, demo script, write-up, video plan, gallery"
