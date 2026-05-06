# FocusForge

Character-driven Pomodoro app for iPhone that rewards consistent focus with customizable avatars, outfits, and on-device AI coaching.

## Why FocusForge
Most timer apps are functional but emotionally flat. FocusForge combines deep-work structure with progression mechanics so users return daily, protect streaks, and see visible growth in their character.

## Status

**MVP build · entering beta.** Sprints 1–5 are complete on `main`: timer engine, sessions, streaks, milestones, XP economy, character cosmetics, dressing room, daily/weekly quests, stats dashboard, AI Coach (intent framing, post-session reflection, streak rescue nudge), Firebase Analytics + Crashlytics, and a dark atmospheric UI redesign with WCAG AA contrast and Reduce Motion support.

Sprint 6 is the current focus — TestFlight beta runtime, P0/P1 triage, manual VoiceOver flow verification, and App Store submission.

## Core Features
- Pomodoro timer with customizable presets (Focus, Short Break, Long Break)
- Daily streaks and milestone rewards (days 3, 7, 14, 30, 60)
- Character customization across head, hair, eyes, mouth, and three cosmetic slots (horns, wings, weapon)
- Inventory and cosmetics economy with rarity tiers (common, rare, animated rare); animated rare items shimmer at thumbnail size
- Daily and weekly quests with claimable rewards
- Stats dashboard (today, 7-day with chart, all-time, milestone tracker)
- On-device AI coaching — template-based, deterministic, no behavioral data leaves the device
- Cinematic reward overlay with five-beat staged reveal and tap-to-skip
- Two-mode design system: focus mode (restraint) and reward mode (richness)

## Platform
- v1.0: iPhone (iOS 17+)
- v1.1: iPad universal layout, CloudKit sync
- Later: Android and macOS

## Product Principles
- Fast to start: default focus session in ≤2 taps
- Offline-first core flow
- AI is assistive, optional, and privacy-first
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

## Initial Success Metrics
- D1 retention ≥ 45%
- D30 retention ≥ 18%
- 7-day streak attainment ≥ 30%
- Completed focus minutes per DAU ≥ 50
- AI suggestion acceptance ≥ 35%
- Crash-free sessions ≥ 99.5% in beta
