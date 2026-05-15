# FocusForge — Visual Polish Punch List

Captured during the 2026-05-15 visual audit pass. Items below are
ordered by impact-to-effort ratio. Fixed items struck through with a
commit reference.

---

## Fixed

- ~~**Quests list rows had no visible card boundary.**~~ Fixed in
  `23646e0` — replaced flat 4% white fill with FrostedCard-style
  rounded rectangle + subtle border. Each quest now reads as its own
  card.
- ~~**GroundPlane invisible in dressing room.**~~ Fixed in `23646e0`
  — bumped line opacity 0.06→0.12 and glow opacity 0.08→0.18. The
  character now has a stage.
- ~~**P1 — Inventory grid items clipped by tab bar.**~~ Fixed in
  `04a6ea7` — bumped ScrollView bottom padding from `Spacing.lg`
  (20pt) to 60pt. Last row of items now clears the tab bar with
  visible breathing room.
- ~~**P2 — Stats Today view emotionally flat when empty.**~~ Fixed
  in `04a6ea7` — added emptyStateBanner above the zero-stat grid:
  "No focus yet today / Your character is waiting." in a purple-tinted
  card. Pivots screen from observation to invitation.
- ~~**P3 — Stats 7-Day chart empty days invisible.**~~ Fixed in
  `04a6ea7` — empty days now render as faint placeholder bars at 8%
  blue opacity, 0.5min height. Chart structure visible even when
  sparse. Accessibility values still read the real minute count.
- ~~**P4 — Streak rescue banner overlaps navigation title.**~~ Fixed
  in `04a6ea7` — scoped the banner to the Timer tab (`selectedTab == 0`).
  Other tabs no longer have the banner fighting their nav titles. The
  banner's job is to push users to start a session, only contextually
  relevant on Timer.
- ~~**P5 — Tagline weight on AboutView hero.**~~ Fixed in `04a6ea7` —
  "Your focus grows your character." now `.body.weight(.medium)` with
  xxs bottom padding. Lands as claim, not caption.

## Outstanding — actionable

### P6 — Settings form controls inconsistent dark styling

`SettingsView` uses iOS's default Stepper and Toggle styling, which
in dark mode renders as semi-translucent gray (not aligned with the
FFTheme palette). The AI Coach Settings view uses NavigationLink
which adopts dark navigation appearance correctly, but the inline
form controls still feel like system defaults.

Fix: build custom `Stepper` and `Toggle` styles or wrap with
explicit `.tint(FFTheme.Accent.blue)` on every control.

## Outstanding — nice-to-have

### ~~N1 — Character sprite size on Timer~~ Fixed in `<next-commit>`

Bumped from 64pt → 80pt. Character now anchors the Timer screen with
more presence, matching the "your focus grows your character"
positioning. Still small enough to preserve focus-mode restraint.

### ~~N2 — Chart bar gradient~~ Already done

Verified: WeeklyStatsView already uses
`LinearGradient([blue, blue.opacity(0.6)], top, bottom)` on every
real bar. The note was based on a misread of the simulator screenshot.
Empty-day ghost bars use a flat 8% opacity (intentional — they're
placeholders, not data).

### ~~N3 — Coin icon consistency~~ Fixed in `<next-commit>`

Replaced `circle.fill` (read as ornamental dot) with
`bitcoinsign.circle.fill` (reads as currency) in both QuestRowView
and TodayStatsView. Now matches the icon used in RewardOverlayView.

---

## What's NOT in this list

Decisions that are correct as-is, even if they could change:

- **The timer ring's three-layer composition** — pixel-perfect as
  designed (see design-rationale.md §2).
- **The 5-beat reward sequence timings** — hand-tuned, locked.
- **FFTheme color tokens and contrast ratios** — measured, locked.
- **Two-mode design philosophy** — load-bearing for the brand;
  don't touch.

---

## How to use this doc

Pick items in P1-P6 order before launch. N-prefix items are
candidates for v1.1 polish sweep.

If a fix introduces a question ("should the empty state CTA say X
or Y?"), file an issue. Don't burn the audit's clarity on details.
