# FocusForge — Design System Reference

## Two-Mode Philosophy

FocusForge has two emotional registers:

- **Focus mode** — Near-black canvas, one accent color (the progress ring), minimal UI. The character is absent. This is a distraction-free tool.
- **Reward mode** — Deep purple atmosphere, layered radial glows, particles, dramatic character lighting. Cinematic "reward moment" with staged reveal animation.

The contrast between restraint and richness IS the dopamine hit.

## Color Tokens (`FFTheme`)

All colors live in `Theme/FFTheme.swift`. Never use raw `Color.blue` etc — use `FFTheme.*` tokens.

| Token | Hex | Usage |
|-------|-----|-------|
| `Background.primary` | #0A0A0F | Focus mode canvas |
| `Background.secondary` | #0E0E1A | Cards, elevated surfaces |
| `Background.tertiary` | #161628 | Dressing room mid-zone |
| `Background.rewardTop/Mid/Bottom` | #0C0820 / #241850 / #0C0820 | Reward gradient |
| `Accent.blue` | #4A7BF7 | Focus ring, primary actions |
| `Accent.purple` | #7B5FD4 | Reward CTAs, rare items |
| `Accent.orange` | #F0A040 | Streak, coins |
| `Accent.gold` | #F0C840 | XP |
| `Accent.cyan` | #60C8FF | Streak freeze |
| `Accent.green` | #4CAF50 | Completed states |
| `Accent.red` | #FF5A5A | Destructive actions |
| `Text.primary` | white 92% | Headings, timer |
| `Text.secondary` | white 50% | Labels |
| `Text.tertiary` | white 30% | Hints, disabled |
| `Border.default` | white 6% | Cards, dividers |
| `Border.emphasis` | white 12% | Selected states |

## Spacing Scale (`FFTheme.Spacing`)

4 / 8 / 12 / 16 / 20 / 24 / 32 / 40 — named xxs through xxxl.

## Corner Radius (`FFTheme.Radius`)

6 / 10 / 16 / 24 — named sm through xl.

## Atmospheric Components (`Theme/AtmosphericViews.swift`)

- `FocusBackground` — Near-black + subtle radial glow
- `RewardBackground` — Deep purple gradient + layered glows
- `CharacterSceneBackground` — Dark gradient + ambient character glow
- `GroundPlane` — Thin light line + underglow beneath character
- `ParticleField` — Deterministic scattered dots for reward mode
- `FrostedCard` — Semi-transparent card with subtle border
- `AccentPillButton` — Gradient-filled CTA (purple or blue)
- `.darkNavigationAppearance()` — View modifier for nav bars
- `.darkTabBarAppearance()` — View modifier for tab bar

## Timer Ring (`GlowProgressRingView`)

Replaces the old `ProgressRingView`. Three layers: subtle track, wide glow aura (15% opacity), thin crisp ring (90% opacity).

## Reward Overlay (`RewardOverlayView`)

Replaces the old sheet-based `SessionCompletionView`. Full-screen in-place overlay with 5-beat cinematic animation:
1. Ring pulse (t=0) → 2. Background crossfade (t=400ms) → 3. Checkmark + headline (t=800ms) → 4. Reward card + count-up (t=1200ms) → 5. CTA button (t=1600ms).
Tap to skip. Respects `accessibilityReduceMotion`. Uses `CountUpText` for animated number counting and `RingPulseView` for the initial pulse.

## Dark Mode Strategy

- App forces `.preferredColorScheme(.dark)` on ContentView
- All backgrounds use custom near-black colors (not system)
- Lists use `.scrollContentBackground(.hidden)` + custom ZStack backgrounds
- Navigation bars use `.darkNavigationAppearance()` modifier

## File Structure

```
FocusForge/
  Theme/
    FFTheme.swift              — Design tokens
    AtmosphericViews.swift     — Reusable background/card components
  Features/
    Timer/
      TimerView.swift          — Focus mode (dark canvas + glow ring)
      Components/
        GlowProgressRingView.swift
        RewardOverlayView.swift      — Full-screen cinematic reward overlay
        RingPulseView.swift          — Ring completion pulse animation
        CountUpText.swift            — Animated number counter
        MilestoneUnlockView.swift    — Reward mode
        StreakBadgeView.swift
        IntentFramingView.swift      — AI Coach pre-session
        PostReflectionCardView.swift — AI Coach post-session
        StreakRescueBannerView.swift  — AI Coach streak nudge
    Character/
      CharacterView.swift
      DressingRoomView.swift   — Dark atmospheric dressing room
    Stats/
      StatsView.swift          — Dark segmented control
      StatCardView.swift       — Dark accent cards
    Quests/
      QuestListView.swift
      QuestRowView.swift
    Settings/
      SettingsView.swift
      AICoachSettingsView.swift
  Navigation/
    ContentView.swift          — Dark tab bar + forced dark mode
```
