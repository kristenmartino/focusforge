# FocusForge PRD

## 1. Product Overview
FocusForge is a character-driven Pomodoro productivity app for iPhone and iPad. Users complete focus sessions to build streaks, earn currency, and unlock character customization items (traits, outfits, accessories). The product combines productivity structure with progression loops to improve retention and habit strength.

## 2. Goals
- Increase daily focus consistency through short, repeatable sessions.
- Improve retention via streak and reward loops.
- Provide premium-ready cosmetic monetization without productivity pay-to-win.
- Add on-device AI coaching to increase streak protection and re-engagement.

## 3. Non-Goals (MVP)
- Team collaboration features.
- Social feed or multiplayer systems.
- Android launch in MVP.
- Randomized real-money loot box mechanics.

## 4. Target Users
- Students and solo professionals.
- Users with distraction-heavy workflows who need structured sessions.
- Existing Pomodoro users who churn from low-engagement timer apps.

## 5. Platform Strategy
- MVP: iOS + iPadOS universal app.
- Phase 2: Android.
- Phase 3: macOS companion.

## 6. Core User Loop
1. User selects/enters a task and starts a focus session.
2. User completes the session and logs outcome.
3. App grants XP/coins and streak progression.
4. User unlocks/equips cosmetics.
5. Character progression reinforces next-session motivation.

## 7. Feature Requirements

### 7.1 Timer System
- Session types: Focus, Short Break, Long Break.
- Presets: default 25/5 with long break after 4 focus sessions.
- Customizable durations (validated input).
- Background-safe timer and completion notifications.

### 7.2 Streaks and Rewards
- Daily streak tracking with local calendar logic.
- Milestone unlocks (days 3, 7, 14, 30, 60).
- Coins + XP for completed sessions.
- Controlled streak freeze policy.

### 7.3 Character Customization
- Base character selection.
- Trait customization (face/expression/appearance).
- Equipment slots: head, top, bottom/full-body, accessory.
- Inventory states: owned, locked, new.

### 7.4 AI Features (On-Device First)
- Intent framing before focus start.
- Post-session reflective tip.
- Streak rescue nudge near loss window.
- Adaptive duration/break recommendations (wave 2).

### 7.5 Progress and Insights
- Today, 7-day, all-time focus metrics.
- Session history and trend view.
- Quest and milestone progress.

## 8. UX Requirements
- Start default session in <=2 taps.
- Reward reveal <=2.5 seconds and skippable.
- Offline-first core timer flow.
- Accessibility: VoiceOver, Dynamic Type, WCAG AA contrast.

## 9. Visual / Graphics Requirements
- Style: playful, clean, warm.
- Layered 2D sprite system for traits and outfits.
- Required animations: idle, celebrate, focus, rest.
- Cosmetic rarity tiers (common, rare, animated rare).

## 10. Data Contracts
- `UserProfile`
- `TimerPreset`
- `SessionLog`
- `StreakState`
- `CharacterLoadout`
- `InventoryItem`
- `UnlockEvent`
- `QuestProgress`
- `AICoachPreference`
- `AIInteractionLog`
- `BehaviorSignal`

## 11. AI Interface Contracts
- `generate_focus_intent(input_task, recent_behavior) -> intent_text`
- `generate_post_session_tip(session_outcome, recent_behavior) -> tip_text`
- `recommend_next_session(recent_behavior) -> {duration, break_type, rationale}`

## 12. Analytics Events
- `ai_prompt_shown`
- `ai_suggestion_accepted`
- `ai_suggestion_dismissed`
- `ai_recommendation_followed`
- `ai_nudge_opened`

## 13. Monetization
- Free core timer + progression.
- Optional subscription (`FocusForge+`) for advanced stats and premium cosmetic tracks.
- Optional non-randomized cosmetic bundles.
- No ads during focus sessions.

## 14. Success Metrics
- D1 retention >= 45%
- D30 retention >= 18%
- 7-day streak attainment >= 30%
- Completed focus minutes per DAU >= 50
- AI suggestion acceptance >= 35%

## 15. Risks and Mitigations
- Gamification overshadowing productivity.
  - Mitigation: keep timer flow primary and rewards lightweight.
- AI responses feel repetitive.
  - Mitigation: templated variety + behavior conditioning + deterministic fallback.
- Notification fatigue.
  - Mitigation: frequency caps, quiet hours, quick mute.
- Content pipeline bottlenecks.
  - Mitigation: constrained launch catalog + seasonal drops.

## 16. MVP Timeline (12 Weeks)
- Sprint 1-2: timer core, session logging, streaks, rewards.
- Sprint 3-4: character system, inventory, quests, stats.
- Sprint 5: AI Coach Core, iPad optimization, sync hardening.
- Sprint 6: accessibility, QA, release prep, App Store submission.

## 17. Launch Criteria
- No open P0/P1 defects.
- Crash-free sessions >= 99.5% in beta.
- Timer drift <1 second over 30-minute session.
- End-to-end flow verified: start -> complete -> reward -> re-engage.

