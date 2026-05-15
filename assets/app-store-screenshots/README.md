# FocusForge — App Store Screenshots

6 hero screenshots captured at iPhone 16e simulator resolution (1170×2532
or similar — actual dimensions vary by simulator). Captured 2026-05-15
during the v1.0 polish push. Each shows a fully-polished surface (no
debug UI, no placeholder data, no half-baked animations).

## The set

| # | File | What it shows | Where it should go in App Store |
|---|---|---|---|
| 01 | `01-timer-hero.png` | Timer screen at idle — character + Day 5 badge + glow ring at 01:00 + Start Focus | **Slot 1 hero** — most important screenshot, first thing reviewers see |
| 02 | `02-ai-coach-intent-framing.png` | AI Coach pre-session prompt — brain icon glow + reframed task + Accept/Edit/Skip | **Slot 2** — supports the "hand-written coach" claim |
| 03 | `03-character-dressing-room.png` | Character with ground plane underglow + skin/hair/body pickers + inventory grid | **Slot 3** — character meaning layer |
| 04 | `04-stats-weekly.png` | 7-day chart with ghost bars on empty days, real bars on Thu+Fri | **Slot 4** — proves stats exist + the chart's craft (ghost bars) |
| 05 | `05-about-craft-narrative.png` | About screen surfacing craft narrative inside the app | **Slot 5** — backs the brand at the App Store level |
| 06 | `06-reward-moment.png` | Cinematic reward overlay — checkmark, "Focus Complete!", streak badge, XP/Coins, quest completions, PostReflection card | **Slot 6** (optional) — the visual peak |

## How to use these

Apple requires App Store screenshots at specific device-size aspect
ratios:

- **6.7" iPhone display** (Pro Max): 1290×2796
- **6.5" iPhone display** (Plus): 1242×2688 or 1284×2778
- **5.5" iPhone display** (legacy SE / Plus 4.7"): 1242×2208 — only
  needed for older device compat; Apple is phasing this out

The iPhone 16e screenshots here are ~1170×2532, which doesn't exactly
match any of Apple's required canvas sizes. Two options for actual
submission:

1. **Re-capture on a Pro Max simulator** at native 1290×2796. Cleaner
   path, takes 30 min. Boot `iPhone 17 Pro Max` simulator, install
   the app, walk through each capture.
2. **Pad these to 1290×2796** in Preview/Photoshop by adding ~120px
   black bars top + bottom centered on the existing content. Faster
   but the screenshots will have visible letterboxing if the App
   Store renders them at native ratio.

**Recommendation:** re-capture on Pro Max for the actual submission.
These captures are the proof-of-concept that the polished UI works;
the production screenshots should match the canvas Apple expects.

## Caption ideas (App Store overlays)

Apple allows text overlays on screenshots in the App Store Connect
upload flow. Suggested captions matching the locked positioning:

- **01-timer-hero:** "Your focus grows your character."
- **02-ai-coach-intent-framing:** "A coach that was written, not generated."
- **03-character-dressing-room:** "Unlock cosmetics at streak milestones."
- **04-stats-weekly:** "Track every minute of focus."
- **05-about-craft-narrative:** "Built solo. Built honestly."
- **06-reward-moment:** "Five hand-tuned beats."

Keep overlay text very short — Apple's App Store search results show
screenshots at thumbnail size where any text larger than ~3 words gets
illegible.

## When to update

Re-capture this set whenever:

- The visual design changes significantly (new theme tokens, new
  layout)
- A new "headline" feature ships that should replace a slot
- Before each major App Store version submission

## Source recipe

Reproduce these captures:

```bash
# Make sure simulator has booted with the latest build:
cd app && xcodebuild build -scheme FocusForge -destination 'platform=iOS Simulator,name=iPhone 16e' -quiet
xcrun simctl install booted /Users/rootk/Library/Developer/Xcode/DerivedData/FocusForge-csosjsgfziwqipcgqgxccydnqcfn/Build/Products/Debug-iphonesimulator/FocusForge.app
xcrun simctl launch booted com.focusforge.app

# Capture via simctl io booted screenshot — works at full resolution:
xcrun simctl io booted screenshot 01-timer-hero.png
# (navigate to each surface in the simulator manually, repeat)
```

Notes:

- 06 (reward moment) is the trickiest: requires starting a 1-min focus
  session (set focus duration to 1 minute in Settings), waiting for it
  to complete, then capturing during the ~1.9s reward animation. The
  reward overlay sits at final state until "Continue" is tapped, so
  there's a comfortable window to capture after the animation.
- The streak rescue banner is a debug toggle (`Force Streak Rescue
  Banner` in Settings → Debug). Turn OFF before captures to keep the
  screens clean.
- Set focus duration to 25 min for production captures so the 01:00
  doesn't look weird in the marketing context. Change it to 1 min only
  for capturing 06 (reward moment).
