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

## Outstanding — actionable

### P1 — Inventory grid items clipped by tab bar (Character tab)

The bottom row of cosmetic items in the dressing room is partially
hidden behind the tab bar. Users have to scroll to see them. Fix is
likely a `safeAreaInset(edge: .bottom, ...)` modifier or extra
padding at the bottom of the scroll view in `DressingRoomView`.

### P2 — Stats Today view is emotionally flat when empty

When no sessions completed today, every card reads "0" — accurate but
not engaging. Two options:

1. Add a friendly empty-state callout above the stat grid: "No
   sessions today — your character is waiting" with a "Start a
   session" CTA that deep-links to the Timer tab.
2. Replace zeros with motivating placeholders ("—" or "Start your
   first") while preserving the layout.

Pick option 1 — keeps the layout consistent while addressing the
empty-state UX.

### P3 — Stats 7-Day chart empty days are invisible

When most days have no data, the chart shows one tall bar and a lot
of empty space. The day labels (Sat / Sun / Mon...) imply structure
that the bars don't reinforce.

Fix: render ghost bars on empty days at very low opacity (e.g.
`FFTheme.Accent.blue.opacity(0.04)`) at a fixed minimal height (~2-3
pt) so the chart's grid structure is visible even when sparse.

### P4 — Streak rescue banner overlaps navigation title

When the streak rescue banner is showing (in production: when
`streakRiskScore > threshold`; in dev: when the debug toggle is on),
it renders at the global ContentView level above the tab content,
which means it covers the navigation title bar on whichever tab the
user is on. The "About" nav title, the "Stats" nav title, etc. are
all hidden behind the banner.

Two architectural fix options:

1. **Push the banner below the navigation bar.** Render it inside
   each tab's NavigationStack as a `safeAreaInset(edge: .top, ...)`
   so it sits below the nav title rather than over it.
2. **Push the tab content down when the banner is showing.**
   ContentView already conditionally shows the banner — also adjust
   the tab content's `.padding(.top, ...)` to account for the
   banner's height.

Option 1 is cleaner architecturally but requires more refactoring
since the banner currently lives at the ContentView level.

### P5 — Tagline weight on AboutView hero

The "Your focus grows your character." tagline on the About hero
block uses `.body` (regular weight). The locked positioning sentence
deserves more weight to land harder.

Fix: change to `.body.weight(.medium)` and bump the bottom padding by
4-8 pt for more breathing room.

### P6 — Settings form controls inconsistent dark styling

`SettingsView` uses iOS's default Stepper and Toggle styling, which
in dark mode renders as semi-translucent gray (not aligned with the
FFTheme palette). The AI Coach Settings view uses NavigationLink
which adopts dark navigation appearance correctly, but the inline
form controls still feel like system defaults.

Fix: build custom `Stepper` and `Toggle` styles or wrap with
explicit `.tint(FFTheme.Accent.blue)` on every control.

## Outstanding — nice-to-have

### N1 — Character sprite slightly small on Timer screen

The character at the top of the Timer view is ~50pt. Given the
"character is the meaning layer" thesis, slightly larger (60-70pt)
might give it more presence without dominating.

### N2 — Stats chart bar styling could use a subtle gradient

Current bars use flat `FFTheme.Accent.blue`. A subtle vertical
gradient (top: full blue, bottom: blue at 0.7 opacity) would echo
the timer ring's atmospheric layering.

### N3 — Quest reward icons (XP star, Coins disc) could be more refined

Currently using SF Symbols `star.fill` and `circle.fill`. The
`circle.fill` for Coins doesn't read as "currency" — it reads as
"dot." Consider `bitcoinsign.circle.fill` (already used in the
reward overlay) or a custom asset.

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
