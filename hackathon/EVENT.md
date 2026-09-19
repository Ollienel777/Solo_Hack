# Event

Fill this in before running `/ideate`. Both loops read it, and nothing here is
a rule. **`TODO` marks a field not filled in yet.** The loops treat it as
unknown, never as a value. Replace it, or write `none`. Every time needs an IANA
timezone, for example `America/Toronto`.

## Basics

- name: Hack the North 2026 (University of Waterloo)
- url: https://hackthenorth2026.devpost.com/
- hacking starts: 2026-09-19 00:00 America/Toronto
- feature freeze: default
- submission deadline: 2026-09-20 08:00 America/Toronto
- submit window: 1h
- team: duo (2 people)

<!-- 32 hours of hacking. The builder confirmed the midnight start on
     2026-09-19, so the Devpost page's "36 hours" is the generic figure and
     these times win.
     Sponsor prizes must be selected on Devpost before
     2026-09-19 14:00 America/Toronto, which is its own deadline and falls
     14 hours after the start.
     feature freeze: `default` means the deadline minus 20% of the hacking
     window, and at least 3h before the deadline. -->

## Judging

- criteria: originality, user experience, technical complexity, and WOW factor.
  Weights are not published; treat the four as equal, with WOW factor the
  tie-breaker, since the judging pitch must be a **live demo, not a slide deck
  or a product pitch**.
- judges: Tom Alterman (GoodLeap, Director of Product); Advait Maybhate (Warp,
  Software Engineer); Nabil Fahel (Communitech, VP); Jen Dewalt (Tokay.io,
  Co-founder and CPO); Mike Kirkup (Elderella, Co-founder); Albert Chen (Two
  Small Fish Ventures, Partner); Alroy Almeida (BDC Capital, Pre-Seed/Seed
  Investor). Partial list, from the Devpost PDF.

## Tracks and prizes

- Main award: **Hack the North 2026 Finalists**, 12 winners, no ranking within
  them. Originality, clever technical work, creative experiences.
- About 30 sponsor prizes. The full list, with each one's requirements and
  judging criteria, is in `hackathon/tracks/prizes.md`.
- Several are worth stacking with a main-award project: OpenAI (API + Codex),
  Rox (Best AI Agent, $10K), Elastic, Cloudflare, Zip, Federato, RBC, Shopify,
  Warp, Sentry, Backboard, Browserbase, GPTZero, Baseten, Tether, Solana, Linq,
  Huawei (two challenges), and the MLH prizes (Gemini, ElevenLabs, MongoDB,
  Snowflake, Tiger Data, Vultr, GoDaddy).
- Hardware or venue-bound: Bracket Bot, LeLamp, QNX, Dominion Dynamics
  WHITEOUT, Dryft (H100 benchmark), CSE (dataset in Discord), Aramco (beginner
  teams only).

## Rules that constrain ideas

- The project must be built during the hackathon, and be substantially the
  team's own work.
- Submit a link to the source code, including all design assets created at the
  event.
- Every team member's badge ID goes in the submission, exactly as shown under
  the QR code on the badge.
- **Sponsor prizes must be selected before 2:00 PM EDT on Saturday.**
- Some prizes carry hard requirements (QNX OS, Cloudflare Workers as the
  runtime, Tether's `hello-pear-qvac-tui` repo as a core part, Huawei OMNI's
  three modalities). Those are in `tracks/prizes.md`.

## Submission requirements

- A project built during the hackathon.
- A source-code link, including design assets.
- Badge IDs for every team member.
- Sponsor prize selections, before the Saturday 2:00 PM EDT cutoff.
- A demo video: optional but recommended.
- The judging pitch itself is a live demo.

## The builder

- skills and interests: "Anything is fine, experienced in all fields." Both
  members are senior generalists, with no preferred stack and no domain they
  need to avoid: web and mobile frontends, backend and infra, data and ML,
  graphics, audio, and systems work are all in reach. Treat this as **no
  skill-based narrowing** — do not rule an idea out, or favour one, on the
  grounds of the language, framework or domain it needs. Judge feasibility only
  on what the event itself constrains: the 32-hour window, two people, the
  hard constraints below, and how reliably the thing can be demoed live.
  Taste still applies: pick the stack that gets a polished, working demo
  fastest, not the one that shows range.
- hard constraints: **none on hardware. Every track is in scope**, including
  **Bracket Bot** and **LeLamp**, whose robots are lent at the venue rather
  than owned. The builder reopened this after research found that a third to
  half of past finalists are embodied demos and that the finalist culture
  favours physical, playful, in-room work. Borrowed venue hardware carries
  real access and reliability risk — a shared robot, a queue, a demo that can
  fail on the floor — and that is for the red team to weigh per idea, not a
  reason to exclude the whole class up front.
  **Also in scope, despite an earlier reading of this line:**
  - **Dominion Dynamics WHITEOUT** — runs on ArduPilot SITL, no hardware. Note
    that it is scored live in their simulation rather than demoed like a normal
    project, so an idea built on it wins that track on its own terms and does
    little for the main award. It suits a second, parallel entry better than
    the main project.
  - **Dryft** — supplies the H100s.
  - **QNX** — only if its free laptop VM path is real. `qnx.com` was blocked
    during research, so **verify that before any idea depends on it**.
  A duo is also ineligible for Aramco's beginner prize unless both members
  have attended one or fewer hackathons.
- accounts and keys already held: none yet. Every sponsor API needs a sign-up
  at or before the event, so ideas are planned against fixture-backed fakes and
  the sign-ups are listed as human actions.

<!-- hard constraints: things the idea must respect, such as no hardware or no
     paid APIs, or `none`.
     accounts and keys: service names only. Never paste a key here. -->

## Ideation settings

- ideation rounds: 3
- ideation budget: 3h
- shortlist size: 4

<!-- If ideating after hacking has started, a quicker pass is rounds 2,
     budget 90m. -->
