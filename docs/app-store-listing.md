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
A hand-built focus tool. Your sessions grow an RPG character. Every coach line written by one person — no AI slop. Solo-built in SwiftUI, on-device, private.
```

*155 chars.* Editable post-launch without resubmission — iterate based on
which lines hit in App Store Search Ads / referral. Four plays embedded:
- Craft signal up front ("hand-built")
- Character/meaning hook ("grow an RPG character")
- Anti-slop framing ("no AI slop") — the differentiating phrase
- Founder + privacy as closing technical proof

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
FocusForge is a hand-built focus tool. Every word the coach says was written by one person. Every animation, every color, every glow — chosen deliberately. No AI generating copy. No stock UI templates. No dark patterns. It's a Pomodoro timer that takes itself seriously as a piece of craft.

YOUR FOCUS GROWS YOUR CHARACTER
Each focus session feeds an RPG-style character that grows with your work. Unlock cosmetics at streak milestones — horns at day 3, shadow wings at day 14, an animated rare ray gun at day 60. Coins from sessions buy purely cosmetic upgrades. No pay-to-win. The character is the meaning layer — your progress made tangible, not just tallied.

A REWARD MOMENT, NOT A POPUP
When a session ends, the screen doesn't slide up a notification card. It transforms. The ring pulses, the background crossfades from near-black focus mode to a deep purple atmosphere, particles drift, the headline lands, your XP counts up, and a CTA fades in. Five hand-tuned beats. Tap to skip if you'd rather not linger.

A COACH THAT WAS WRITTEN, NOT GENERATED
Most "AI coaching" apps wrap a frontier model, and the output reads like it. FocusForge takes the opposite bet. The coach is 33 hand-written templates × 3 tones (encouraging, direct, calm) — about 99 pieces of micro-copy by one writer, routed by your behavior on-device. No cloud LLM. No work data ever leaves your phone. The whole catalog is open-source on GitHub — you can read every line a user might see.

Three coaching moments:
• Intent framing before a session begins
• A reflective tip after it ends
• A streak rescue nudge before you lose your streak

CRAFTED, NOT ASSEMBLED
• Two emotional registers: near-black focus mode (one accent color, the character absent) vs. deep purple reward mode (layered glows, particles, dramatic character lighting). The contrast IS the dopamine hit.
• Timer ring is three composed layers — subtle track, wide glow aura, thin crisp ring. Not a default progress circle.
• Background-safe timer that drifts less than 1 second over 30 minutes
• Daily and weekly quests for variety
• Streak freezes earned at milestones — miss a day, a freeze protects automatically. No shaming.
• Stats that respect you — Today, 7-day chart, all-time. No leaderboards, no comparisons, no social pressure.
• Full VoiceOver, Dynamic Type, WCAG AA contrast measured (not guessed), Reduce Motion variants for every animation
• Export your full progress as JSON anytime, for when you change phones

DESIGNED + BUILT SOLO
By Kristen Martino. Built in public — every design decision documented. The coach engine is MIT-licensed on GitHub.

REQUIREMENTS
iPhone with iOS 17 or later. iPad universal support arrives in v1.1.

PRIVACY
Crash reports and basic analytics events run through Firebase, scoped per-install with no user identity. The AI Coach runs entirely on-device. No work data, task names, or focus content ever leaves your phone.
```

*~2700 chars.* Sections separated by blank lines render as paragraphs in
App Store. ALL-CAPS section headers read as emphasized headings in the
App Store description renderer. Craft-led — every section leads with what
was made by hand, not with feature lists. Privacy claim sits as the
closing technical footnote, not the headline.

---

## What's New (4000 char limit, per release)

For the v1.0 initial submission:

```
FocusForge v1.0 — the first release.

A hand-built focus tool. Your sessions feed an RPG character that grows with your work. Every coach line was written by one person — 33 templates, 3 tones, ~99 pieces of micro-copy. No cloud LLM, no behavioral data leaves your phone. The coach engine is open-source on GitHub.

Five hand-tuned reward beats. Two emotional registers — near-black focus mode and deep purple reward mode. Streak freezes at milestones, no shaming. Full VoiceOver, Dynamic Type, Reduce Motion. Built solo in SwiftUI by Kristen Martino.
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
