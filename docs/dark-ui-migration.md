# Dark Atmospheric UI — Migration Guide

## Overview

This update transforms FocusForge from default SwiftUI styling to a dark atmospheric
UI with two emotional registers: restrained focus mode and rich reward mode.

## New Files (ADD these)

| File | Purpose |
|------|---------|
| `Theme/FFTheme.swift` | Design system tokens — colors, spacing, typography, radius |
| `Theme/AtmosphericViews.swift` | Reusable backgrounds (FocusBackground, RewardBackground, CharacterSceneBackground), GroundPlane, ParticleField, FrostedCard, AccentPillButton, dark navigation helpers |
| `Features/Timer/Components/GlowProgressRingView.swift` | Enhanced progress ring with glow aura (replaces ProgressRingView) |

## Replaced Files (OVERWRITE these)

| File | What changed |
|------|-------------|
| `Features/Timer/TimerView.swift` | Full redesign — dark canvas, glow ring, inline controls, atmospheric background. Removes dependency on TimerControlsView and TaskNameInputView (both inlined). |
| `Features/Timer/Components/SessionCompletionView.swift` | Cinematic reward mode — RewardBackground, ParticleField, staged reveal animation, FrostedCard rewards |
| `Features/Timer/Components/MilestoneUnlockView.swift` | Same reward atmosphere — RewardBackground, ParticleField, FrostedCard |
| `Features/Timer/Components/StreakBadgeView.swift` | Dark-themed capsule with orange accent on dark background |
| `Features/Stats/StatCardView.swift` | Dark card with low-opacity colored fill + border |
| `Features/Stats/StatsView.swift` | Dark background, custom dark segmented control (replaces system Picker) |
| `Features/Character/CharacterView.swift` | Dark nav bar treatment |
| `Features/Character/DressingRoomView.swift` | Full redesign — CharacterSceneBackground, GroundPlane, dark color pickers, dark slot picker, dark inventory |
| `Features/Quests/QuestListView.swift` | Dark background, dark list rows |
| `Features/Quests/QuestRowView.swift` | Dark-themed text colors, purple claim button |
| `Features/Settings/SettingsView.swift` | Dark background, hidden scroll background, dark list rows |
| `Navigation/ContentView.swift` | Dark tab bar, forced dark color scheme, blue tint |

## Files You Can DELETE

| File | Reason |
|------|--------|
| `Features/Timer/Components/ProgressRingView.swift` | Replaced by GlowProgressRingView |
| `Features/Timer/Components/TimerControlsView.swift` | Controls are now inlined in TimerView |
| `Features/Timer/Components/TaskNameInputView.swift` | Task input is now inlined in TimerView |
| `Features/Character/ColorPickerRowView.swift` | Color picker is now inlined in DressingRoomView with dark styling |

## Key Architectural Changes

### Design System
All hardcoded colors are replaced with `FFTheme.*` tokens. This means:
- `Color.blue` → `FFTheme.Accent.blue`
- `Color.secondary` → `FFTheme.Text.secondary`
- `.background(color.opacity(0.1))` → `FFTheme.Background.secondary` or explicit low-opacity fills

### Dark Mode Strategy
The app forces dark mode via `.preferredColorScheme(.dark)` on ContentView.
All backgrounds use custom near-black colors rather than system backgrounds.
Lists use `.scrollContentBackground(.hidden)` + custom ZStack backgrounds.
Navigation bars use `.darkNavigationAppearance()` modifier.

### Reward Mode Architecture
SessionCompletionView and MilestoneUnlockView now use:
- `RewardBackground` (deep purple gradient atmosphere)
- `ParticleField` (scattered dot particles)
- `FrostedCard` (semi-transparent card container)
- `AccentPillButton` (gradient CTA button)
- `.presentationBackground(Color.clear)` to let the custom background show through sheets

### Animation Sequence
SessionCompletionView uses a staged reveal:
1. Content fades in (0.5s)
2. Rewards card slides up (0.4s delay)
3. CTA button appears (0.3s delay)

This creates the cinematic "reward moment" rather than showing everything at once.

## What Still Uses System Styling

- **Onboarding flow** — intentionally left as-is for now (it runs once)
- **SessionHistoryView** — standard list, low priority for dark treatment
- **WeeklyStatsView Charts** — Swift Charts auto-adapt to dark mode fairly well
- **TodayStatsView / AllTimeStatsView** — these use StatCardView which is updated, but the container ScrollView may need a dark background pass

## Testing Checklist

- [ ] Timer screen: near-black background, glowing ring, white timer text
- [ ] Start session: ring animates, controls appear with proper styling
- [ ] Complete session: reward sheet has purple atmospheric background + particles
- [ ] Milestone unlock: trophy + frosted card + purple atmosphere
- [ ] Character tab: atmospheric background behind character, ground plane glow
- [ ] Color pickers: white selection rings on dark background
- [ ] Inventory grid: rarity-colored borders visible against dark cells
- [ ] Stats: stat cards show colored accent fills at low opacity
- [ ] Settings: list rows have subtle dark elevated backgrounds
- [ ] Quests: dark list rows, purple "Claim" buttons
- [ ] Tab bar: dark background, blue tint for selected tab
- [ ] Navigation bars: dark background across all tabs
