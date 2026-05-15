# FocusForge — App Store Listing Draft

Ready-to-paste copy for App Store Connect, drafted against the locked
positioning (`Your focus grows your character`). All character counts are
under Apple's hard limits — verify on paste because emoji and curly quotes
can swap counts.

---

## App Name (30 char limit)

```
FocusForge
```

*10 chars.* No subtitle squeeze needed.

---

## Subtitle (30 char limit)

```
Your focus grows your character
```

*30 chars exact.* The locked positioning. Don't deviate from this string —
it appears on the App Store card, in search results, and across portfolio
surfaces. Identical copy everywhere.

---

## Promotional Text (170 char limit)

```
Pomodoro that translates focus into character progression. AI Coach runs entirely on-device — your work data never leaves your phone. Solo-built in SwiftUI.
```

*156 chars.* Editable post-launch without resubmission, so iterate based on
which lines hit. Three plays embedded:
- Category re-frame (Pomodoro → character progression)
- Privacy structural claim (on-device AI)
- Founder/craft signal (solo-built)

---

## Keywords (100 char limit)

```
pomodoro,focus,timer,rpg,productivity,character,streaks,ai,private,deep work
```

*77 chars.* Comma-separated with no spaces (saves chars). Ordering matters
for App Store search — high-intent keywords first. Worth A/B testing
post-launch by swapping `rpg` ↔ `habits` or `private` ↔ `offline`.

---

## Description (4000 char limit)

```
Most productivity apps fail at retention. They externalize discipline — adding streaks, badges, social accountability — and expect that friction to translate into focus. The streak metric optimizes itself and decouples from the underlying goal. "I broke my streak so I quit" is not a user behavior — it's a design output.

FocusForge tests the opposite hypothesis: focus tools work better when they translate effort into something you value intrinsically, rather than tracking it as something you have to defend.

THE CHARACTER GROWS WITH THE WORK
Every focus session feeds an RPG-style character progression. Unlock cosmetics at streak milestones — Imp Points at day 3, Shadow Wings at day 14, the Animated Rare Ray Gun at day 60. Coins from sessions buy purely cosmetic upgrades. No pay-to-win. The character is the meaning layer.

ON-DEVICE AI COACH
A coach that uploads your work data to a server is a contradiction in terms. FocusForge's AI Coach is template-based and runs entirely on your iPhone. No cloud LLM. No behavioral data leaves your device. Three coach moments:
• Intent framing before a focus session begins
• A reflective tip after the session completes
• A streak rescue nudge near the loss window

CRAFTED FOR FOCUS
• Background-safe timer that drifts less than 1 second over 30 minutes
• Two-mode design: focus mode (near-black, restrained) and reward mode (deep purple atmosphere, layered glows, cinematic 5-beat reward moment)
• Daily and weekly quests for variety
• Stats dashboard: today, 7-day chart, all-time
• Streak freezes earned at milestones — miss a day, the freeze protects automatically
• Full VoiceOver, Dynamic Type, WCAG AA contrast, Reduce Motion support
• Export your progress as JSON before upgrading your phone

DESIGNED + BUILT SOLO
By Kristen Martino. Built in public — every design decision documented. The AI Coach template engine is open-source on GitHub.

REQUIREMENTS
iPhone with iOS 17 or later. iPad universal support arrives in v1.1.

PRIVACY
Crash reports and basic analytics events run through Firebase. AI Coach inference is fully on-device. No work data, task names, or focus content ever leaves your phone.
```

*~2200 chars.* Plenty of room for expansion. Sections separated by blank
lines render as paragraphs in App Store. ALL-CAPS section headers read as
emphasized headings in the App Store description renderer.

---

## What's New (4000 char limit, per release)

For the v1.0 initial submission:

```
FocusForge v1.0 — the first release.

Build focus habits with a Pomodoro timer that translates each session into RPG-style character progression. Unlock cosmetics on streak milestones. Get on-device AI coaching for intent framing, reflection, and streak rescue — your work data never leaves your phone.

Solo-built in SwiftUI by Kristen Martino. Open-source AI Coach engine on GitHub.
```

For v1.0.1 (TestFlight beta → App Store) the "What's New" pattern is the
specific user-facing changes: "Better contrast in dark mode," "Streak
freeze logic now correctly survives DST," etc.

---

## App Store Privacy Nutrition Labels

Apple requires declarations for every category of data the app collects.
Based on the current Firebase Analytics + Crashlytics integration (no
advertising, no IDFA, no user accounts):

### Data Used to Track You

**NONE.** FocusForge does not engage in tracking as defined by Apple's
App Tracking Transparency. We don't link app data with third-party data
for advertising or measurement across other companies' apps and websites.

### Data Linked to You

**NONE.** FocusForge has no user accounts. No analytics event is linked
to a user identity. The Firebase App Instance ID is per-install and
resets when the user uninstalls.

### Data Not Linked to You

| Data Type | Used For | Source |
|---|---|---|
| **Device ID** | Analytics | Firebase App Instance ID (per-install, anonymous) |
| **Product Interaction** | Analytics, App Functionality | `session_started`, `session_completed`, `cosmetic_equipped`, `ai_prompt_shown`, etc. — declared in `AnalyticsEvent` enum |
| **Crash Data** | App Functionality | Firebase Crashlytics — symbolicated crash reports |
| **Performance Data** | App Functionality | Firebase Crashlytics — diagnostics, breadcrumbs |

### Submission notes

- We do NOT use IDFA. `GoogleAppMeasurementIdentitySupport` is intentionally
  NOT linked. The Firebase build log will warn `IDFA will not be
  accessible` — that's the desired behavior.
- We do NOT use Firebase Remote Config to send user-targeted data; it's
  installed but unused in v1.0.
- We do NOT use FCM (Firebase Cloud Messaging) for push. All notifications
  are local via `UNUserNotificationCenter`.

### Privacy Policy URL (required)

To be hosted before submission. Plain HTML on the portfolio domain works:

- `https://kristenmartino.ai/focusforge/privacy`
- `https://kristenmartino.ai/focusforge/terms`

Draft content for both is owed; cf. the GDPR/CCPA item in the senior
staff review.

---

## App Category

**Primary:** Productivity

**Secondary:** Health & Fitness (because of the habit-formation framing)

---

## Age Rating

12+ likely. Quick filter answers:

- Cartoon Violence: None
- Realistic Violence: None
- Sexual Content: None
- Profanity: None
- Mature Themes: None
- Gambling: None
- Unrestricted Web Access: No
- User-Generated Content: No
- Drug Reference: None

The 12+ rating comes from the cosmetic system theming (some "battle scarred"
naming, weapon items) but it's borderline — could argue 9+. Confirm based
on App Store Review Guidelines §1.4 once submission opens.

---

## Pricing

**Free.** No in-app purchases at v1.0.

v1.1+ optional `FocusForge+` subscription per PRD §13. Not included in
v1.0 submission to keep the initial review path clean.

---

## App Store Screenshots Plan

Apple requires 5-10 screenshots per device size. Recommended 5 to keep
review crisp:

1. **Hero — Timer screen with character** — focus mode active, "Your focus grows your character" overlay caption
2. **Reward moment** — RewardOverlayView mid-sequence (Beat 4) showing "+25 XP / +25 COINS / Day 7 streak!"
3. **Dressing room** — character with Animated Rare horns equipped + inventory grid visible
4. **AI Coach reflection** — PostReflectionCardView with "The hardest part is starting — and you did it"
5. **Stats dashboard** — Weekly chart with 7 days of data + stat cards

All shot at iPhone 16e simulator resolution (currently 1206×2622). The
share-sheet workflow is to take a `xcrun simctl io booted screenshot`,
crop in Preview, batch-resize to required App Store sizes.

App Preview video (optional but recommended): 15-30 seconds of the
reward moment + dressing room flow. Drives conversion meaningfully.

---

## Source Repositories (referenced in description)

- App: `https://github.com/kristenmartino/focusforge`
- AI Coach engine (to publish before submission per moat-building plan): `https://github.com/kristenmartino/focusforge-coach-engine`

---

## Build & Submission Checklist

When submission day arrives, in order:

1. [ ] Apple Developer Program enrollment confirmed
2. [ ] Provisioning profile + distribution signing identity set up
3. [ ] Privacy Policy + Terms hosted, URLs working
4. [ ] App icon (1024×1024) finalized
5. [ ] Screenshots taken at all required device sizes
6. [ ] Privacy nutrition labels submitted in App Store Connect
7. [ ] Bundle ID `com.focusforge.app` registered + matches plist
8. [ ] Beta test feedback addressed (P0/P1 to zero)
9. [ ] Crash-free rate ≥99.5% measured over beta runtime
10. [ ] `What's New` finalized
11. [ ] Submit for review

Estimated review time: 24-48 hours for first submission. Plan for one
rejection-cycle of buffer (~3-5 days total).
