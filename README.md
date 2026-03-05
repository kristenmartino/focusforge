# FocusForge

Character-driven Pomodoro app for iPhone and iPad that rewards consistent focus with customizable avatars, outfits, and on-device AI coaching.

## Why FocusForge
Most timer apps are functional but emotionally flat. FocusForge combines deep-work structure with progression mechanics so users return daily, protect streaks, and see visible growth in their character.

## Core Features
- Pomodoro timer with customizable presets (Focus, Short Break, Long Break)
- Daily streaks and milestone rewards
- Character customization (traits, outfits, accessories)
- Inventory and cosmetics economy (non-pay-to-win)
- Stats dashboard (today, 7-day, all-time)
- On-device AI coaching for session framing, reflection, and streak rescue nudges

## Platform
- MVP: iOS + iPadOS (universal app)
- Later: Android and macOS

## Product Principles
- Fast to start: default focus session in <=2 taps
- Offline-first core flow
- AI is assistive, optional, and privacy-first
- Rewards support productivity, not distract from it

## Tech Stack (Planned)
- Swift + SwiftUI
- SwiftData (local persistence)
- CloudKit (sync)
- UNUserNotificationCenter (timer notifications)
- Analytics: Amplitude/Firebase
- Crash reporting: Sentry/Crashlytics

## Documentation
- Product requirements: [`docs/PRD.md`](docs/PRD.md)
- AI addendum: [`docs/focus-forge-ai-prd-addendum.md`](docs/focus-forge-ai-prd-addendum.md)

## Initial Success Metrics
- D1 retention >= 45%
- D30 retention >= 18%
- 7-day streak attainment >= 30%
- Completed focus minutes per DAU >= 50

## Repository Structure
- `docs/` product and engineering specs
- `ops/jira-imports/` CSV templates/import helpers
- `app/` iOS codebase (when scaffolding begins)
