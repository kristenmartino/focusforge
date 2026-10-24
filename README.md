# FocusForge

Character-driven Pomodoro app for iPhone that rewards consistent focus with customizable avatars, outfits, and on-device, template-based coaching.

## Why FocusForge
FocusForge pairs a Pomodoro timer with character progression, streaks, and optional coaching prompts. Whether those mechanics improve retention or completed focus time remains a beta hypothesis.

## Status

**MVP build · entering beta.** Sprints 1–5 are complete on `main`: timer engine, sessions, streaks, milestones, XP economy, character cosmetics, dressing room, daily/weekly quests, stats dashboard, Coach (intent framing, post-session reflection, streak rescue nudge), Firebase Analytics + Crashlytics, and a dark UI with contrast-oriented design tokens and Reduce Motion support. A full accessibility audit has not been completed.

Sprint 6 is the current focus — TestFlight beta runtime, P0/P1 triage, manual VoiceOver flow verification, and App Store submission.

## Core Features
- Pomodoro timer with customizable presets (Focus, Short Break, Long Break)
- Daily streaks and milestone rewards (days 3, 7, 14, 30, 60)
- Character customization across head, hair, eyes, mouth, and three cosmetic slots (horns, wings, weapon)
- Inventory and cosmetics economy with rarity tiers (common, rare, animated rare); animated rare items shimmer at thumbnail size
- Daily and weekly quests with claimable rewards
- Stats dashboard (today, 7-day with chart, all-time, milestone tracker)
- On-device coaching — deterministic template selection, not LLM inference. Coaching selection runs locally; the app separately integrates Firebase Analytics and Crashlytics, so this is not a claim that all app activity stays on-device
- Cinematic reward overlay with five-beat staged reveal and tap-to-skip
- Two-mode design system: focus mode (restraint) and reward mode (richness)

## Platform
- v1.0: iPhone (iOS 17+)
- Planned v1.1: iPad universal layout, CloudKit sync
- Possible later platforms: Android and macOS

## Product Principles
- Fast to start: default focus session in ≤2 taps
- Offline-first core flow
- Coaching is optional; analytics and crash reporting have separate data flows
- Rewards reinforce productivity, not distract from it
- Accessibility is a launch criterion, not a follow-up

## Tech Stack
- Swift + SwiftUI (iOS 17+)
- SwiftData (local persistence)
- Firebase: Analytics, Crashlytics, Remote Config (via Swift Package Manager)
- Swift Charts (weekly stats visualization)
- xcodegen (`project.yml` is the source of truth; `.xcodeproj` is gitignored)
- UNUserNotificationCenter (timer completion notifications)
- Custom design tokens (`FFTheme`) for color, typography, spacing, and rarity

## Project Structure
- `app/` iOS Swift codebase (FocusForge target)
- `app/scripts/sprites/` Python sprite generation pipeline (source for character launch art)
- `docs/` product specs, AI addendum, art-direction style guide, dark-UI migration guide
- `assets/` reference sprite source assets
- `ops/` operational helpers (Jira CSVs, etc.)

## Documentation
- Product requirements: [`docs/PRD.md`](docs/PRD.md)
- AI Coach addendum: [`docs/focus-forge-ai-prd-addendum.md`](docs/focus-forge-ai-prd-addendum.md)
- Art direction: [`docs/art-direction-style-guide.md`](docs/art-direction-style-guide.md)
- Dark UI migration: [`docs/dark-ui-migration.md`](docs/dark-ui-migration.md)
- Design system reference: [`app/CLAUDE.md`](app/CLAUDE.md)

## Build

```sh
cd app
xcodegen generate
xcodebuild -project FocusForge.xcodeproj -scheme FocusForge \
  -destination "platform=iOS Simulator,name=iPhone 16e" build
```

The `.xcodeproj` is gitignored — `xcodegen generate` rebuilds it from `project.yml` and resolves Firebase SPM packages on first run.

## Proposed beta targets

These are product targets, not measured results or demonstrated effects of coaching.

- D1 retention ≥ 45%
- D30 retention ≥ 18%
- 7-day streak attainment ≥ 30%
- Completed focus minutes per DAU ≥ 50
- Coaching suggestion acceptance ≥ 35%
- Crash-free sessions ≥ 99.5% in beta
