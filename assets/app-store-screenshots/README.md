# FocusForge — App Store Screenshots

Two sets of hero screenshots:

## `pro-max-1320x2868/` — **the production set**

Captured 2026-05-17 on iPhone 17 Pro Max simulator (native 1320×2868
resolution). Use these for the actual App Store Connect upload — Pro
Max is the largest current iPhone display and Apple expects screenshots
at this canvas. These also auto-downscale for smaller device-size
listings.

### Onboarding flow (4 screens)

| # | File | What it shows |
|---|---|---|
| 1 | `onboarding-01-welcome.png` | First launch — orange flame icon, "FocusForge", "Your focus grows your character." tagline, "Get Started" CTA |
| 2 | `onboarding-02-character-select.png` | "Choose Your Character" — Spark / Ember / Sage cards with personality tags |
| 3 | `onboarding-03-notifications.png` | "Stay on Track" — notification permission priming with "Enable Notifications" + "Not Now" |
| 4 | `onboarding-04-all-set.png` | "You're All Set!" — Ember (selected) character on stage with "Start Focusing" CTA |

These tell the **first-impression story** — what a fresh user sees in
the first 30 seconds. App Store reviewers will see this exact sequence
if they install. Worth a slot if Apple's flow supports it.

### Main app (7 screens)

| # | File | What it shows | Suggested App Store slot |
|---|---|---|---|
| 01 | `01-timer-hero.png` | Timer idle — Ember + FOCUS + 25:00 glow ring + Start Focus | **Slot 1 (hero)** |
| 02 | `02-ai-coach-intent-framing.png` | AI Coach pre-session prompt — brain icon glow + reframed task + Accept/Edit/Skip | **Slot 2** |
| 03 | `03-character-dressing-room.png` | Character + ground plane underglow + skin/hair/body pickers + inventory grid showing 4 horn options with prices | **Slot 3** |
| 04 | `04-stats-today.png` | Stats Today with empty state — "No focus yet today / Your character is waiting" + zero-stat grid | **Slot 4** |
| 05 | `05-about-craft-narrative.png` | About screen showing the craft narrative inside the app — full FF wordmark + 3 build facts + open-source link + portfolio + privacy/terms | **Slot 5** |
| 06 | `06-reward-moment.png` | Cinematic reward overlay — checkmark + "Focus Complete!" + 1-day streak + XP/Coins pills + PostReflection card | **Slot 6** |
| 07 | `07-active-session.png` | Mid-session focus mode — 00:14 + reframed task + Pause/Cancel | Optional slot 7 |

## `*.png` (root level) — **draft / smaller set**

Captured 2026-05-15 on iPhone 16e simulator at lower resolution. Kept
for reference and as a comparison baseline. Not for production upload.

---

## Caption ideas (App Store overlays)

Apple allows text overlays on each screenshot in the App Store
Connect upload flow. Suggested captions matching the locked
positioning, ordered to tell the story:

- **01-timer-hero:** "Your focus grows your character."
- **02-ai-coach-intent-framing:** "A coach that was written, not generated."
- **03-character-dressing-room:** "Unlock cosmetics at streak milestones."
- **04-stats-today:** "Your character is waiting."
- **05-about-craft-narrative:** "Built solo. Built honestly."
- **06-reward-moment:** "Five hand-tuned beats."
- **07-active-session:** "Quiet by design."

Keep overlay text under 4 words — Apple's App Store search results show
screenshots at thumbnail size where longer text gets illegible.

For the onboarding sequence:
- Welcome → no overlay needed (the in-app text already does the job)
- Character select → "Choose your companion."
- Notifications → "Stay on track."
- All Set → "Your first session awaits."

## Reproducibility

Reproduce the production set:

```bash
# 1. Boot Pro Max sim + install
xcrun simctl boot 385AF76F-8CA1-4D65-87EF-029E956F1C7E
cd app && xcodebuild -project FocusForge.xcodeproj -scheme FocusForge \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build -quiet
xcrun simctl install 385AF76F-8CA1-4D65-87EF-029E956F1C7E \
  /Users/rootk/Library/Developer/Xcode/DerivedData/FocusForge-csosjsgfziwqipcgqgxccydnqcfn/Build/Products/Debug-iphonesimulator/FocusForge.app
xcrun simctl launch 385AF76F-8CA1-4D65-87EF-029E956F1C7E com.focusforge.app

# 2. Walk onboarding (welcome → Ember → Not Now → Start Focusing)

# 3. For each main screen, navigate + capture:
xcrun simctl io 385AF76F-8CA1-4D65-87EF-029E956F1C7E screenshot 01-timer-hero.png
# (Character tab → screenshot)
# (Stats tab → screenshot)
# (Settings → About FocusForge → screenshot)

# 4. For 02 (IntentFraming) + 06 (reward): set focus duration to 1 min
#    in Settings, then type a task, tap Start Focus, capture IntentFraming.
#    Tap Accept, wait 60s, capture the reward overlay.
```

Notes:

- The **streak rescue banner** is gated on debug toggle (Settings →
  Debug → "Force Streak Rescue Banner") + having a streak. Fresh
  install won't show it. Keep OFF for production captures.
- **Focus duration** — set to 25 min for the Timer hero capture (looks
  like a real Pomodoro session). Drop to 1 min only for the reward
  capture, then revert.
- **Character selection** at onboarding affects every screenshot
  after. Ember (the red imp with horns) is the most iconic silhouette
  and reads well at thumbnail sizes.

## When to update

Re-capture this set whenever:

- The visual design changes significantly (new theme tokens, new
  layout)
- A new "headline" feature ships that should replace a slot
- Before each major App Store version submission
- After any rendering bug fix that changes how a key screen looks
