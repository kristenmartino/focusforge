# FocusForge+ — v1.0 Subscription Product Decision

**Status:** locked 2026-05-25
**Owner:** Kristen Martino
**Supersedes:** PRD §13 ("FocusForge+ in v1.1+") — sub now ships at v1.0

The decision: ship FocusForge+ subscription on **day one of v1.0**.
The Cuban-review argument carried — training users on free for six
months and then introducing a paywall is the standard indie-app death
spiral. Better to launch with the business model intact.

This doc is the source of truth for what's free, what's paid, what
the paywall says, and where it triggers. Everything downstream
(StoreKit code, App Store Connect, screenshots, Privacy + Terms
updates) flows from this.

---

## 1 · The split philosophy

Two principles guide every row in the matrix below:

1. **Free tier must be a complete, functional, never-degrading
   Pomodoro timer.** The Pomodoro itself is a commodity — there are
   1,000 free Pomodoros on the App Store. If we cripple ours, we lose
   to all of them.

2. **Everything that defines the *FocusForge* brand experience is
   paid.** The AI Coach. The character growth. The cinematic reward
   moment. The advanced stats. These are not "extra" — they are the
   product. Anyone who installs the app and uses it for a week WILL
   encounter our differentiators, will see what FocusForge actually
   is, and will face a real choice.

Free is "Pomodoro you don't hate." Plus is "Pomodoro that *feels like
FocusForge*."

---

## 2 · Feature matrix

| Feature | Free | FocusForge+ | Rationale |
|---|:---:|:---:|---|
| **Pomodoro timer** | ✅ | ✅ | Core utility. Crippling this kills retention. |
| Custom focus / break durations | ✅ | ✅ | Standard table-stakes; not differentiator |
| Background-safe timer (no drift) | ✅ | ✅ | Engineering quality, not feature gating |
| Custom presets | ✅ | ✅ | Same |
| Local notifications on completion | ✅ | ✅ | iOS standard, not differentiator |
| **Streak tracking** | ✅ | ✅ | Free users still get a streak count |
| Streak freezes (auto-protect on missed days) | ❌ | ✅ | Differentiator — protects emotional sunk cost |
| **Stats — Today view** | ✅ | ✅ | Basic accountability, never paywalled |
| Stats — 7-day chart | ❌ | ✅ | Insight-level analysis |
| Stats — All Time / milestones | ❌ | ✅ | Long-term progression view |
| Session history list | ❌ | ✅ | Long-term progression view |
| **Character — base sprite** | ✅ | ✅ | Free users see their character (not crippled) |
| Character — cosmetic unlocks at milestones | ❌ | ✅ | The character meaning layer (brand thesis) |
| Character — dressing room access | ❌ | ✅ | Same |
| Character — inventory grid | ❌ | ✅ | Same |
| **AI Coach — Intent Framing** | ❌ | ✅ | Brand differentiator (hand-written templates) |
| AI Coach — Post-Session Reflection | ❌ | ✅ | Same |
| AI Coach — Streak Rescue Nudge | ❌ | ✅ | Same |
| AI Coach — Tone selection (Encouraging/Direct/Calm) | ❌ | ✅ | Same |
| **Daily quests** | ❌ | ✅ | Engagement layer (gamification) |
| Weekly quests | ❌ | ✅ | Same |
| **Reward moment — basic completion** | ✅ | — | Free gets a simple completion screen |
| Reward moment — 5-beat cinematic with rewards card + reflection | — | ✅ | Brand peak moment |
| **JSON data export** | ✅ | ✅ | **Privacy promise — always free.** Non-negotiable. |
| Settings → Privacy controls (analytics opt-out) | ✅ | ✅ | **Privacy promise — always free.** Non-negotiable. |
| **Future v1.1+: CloudKit sync** | ❌ | ✅ | Belongs in Plus when shipped |

### Things that are NOT in either column

- **Cosmetic micro-purchases** — no. Cosmetics are unlocked through
  streak milestones in FocusForge+. We do not sell individual
  cosmetics for coins or USD. The streak-based unlocking is the
  whole psychological mechanic; selling cosmetics breaks it.
- **Ads** — no. Ever. Brand-incompatible.
- **One-time "pay once, own forever" tier** — no. Recurring is what
  pays for ongoing maintenance, server-side anything (eventually
  CloudKit), and content updates (new templates, new cosmetics).
  One-time pricing is a death sentence for a 3-year roadmap.

---

## 3 · Pricing

| Tier | Price | Notes |
|---|---|---|
| Free | $0 | No expiration, no degradation |
| **FocusForge+ Monthly** | **$4.99 / mo** | Standard month-to-month |
| **FocusForge+ Yearly** | **$39.99 / yr** | 33% discount vs monthly ($4.99 × 12 = $59.88) |
| **Free trial** | **7 days** | Applies to either Monthly or Yearly — captures intent |

### Why these prices

- **$4.99/mo** matches Be Focused Pro and is comfortably under
  Headspace ($12.99/mo) / Calm ($14.99/mo). It positions FocusForge
  as a focused-tool subscription, not a "wellness" platform price.
- **$39.99/yr** at 33% off is the standard SaaS yearly discount
  pattern that maximizes blended LTV (yearly subscribers churn less).
- **7-day trial** lets users experience the full product including
  the AI Coach + reward moment + at least one milestone unlock (Day 3
  is reachable inside a 7-day trial with consistent daily sessions).
  Trial converts at 25-35% in the productivity category benchmark.

### Apple's revenue share

- Year 1 of subscription: Apple takes 30% → $3.49/mo, $27.99/yr net
- Year 2+ of same subscription: Apple takes 15% → $4.24/mo, $33.99/yr
  net
- Small Business Program (under $1M/yr) qualifies for 15% from day 1
  — **apply for this immediately** when revenue exists

### Year-1 ARR scenarios (sanity check)

| Paid users | Mix M/Y | Year 1 net ARR (after Apple 30%) |
|---|---|---|
| 500 paid | 60% M / 40% Y | ~$24K |
| 1,000 paid | 60% M / 40% Y | ~$48K |
| 2,500 paid | 50% M / 50% Y | ~$135K |
| 5,000 paid | 50% M / 50% Y | ~$270K |

Honest read: 500-1,000 paid in year 1 is the realistic outcome from
the current X audience + organic traction. Path A (lifestyle business)
math.

---

## 4 · Paywall trigger points

When does the paywall appear? Five natural moments, in order of how a
new user will encounter them:

### Trigger 1: First Pomodoro session ends (most important)

After the user completes their first focus session, the reward moment
plays. In the free experience the reward moment is the **simple
completion screen** (checkmark, "Focus Complete!", basic +XP / +Coins
display, no streak badge yet, no AI coach reflection).

**At the bottom**, a single line:
> *"Want the full reward moment? Try FocusForge+ free for 7 days."*

Tapping it opens the paywall. NOT a modal that interrupts — a quiet
inline affordance. We earn the upgrade by being soft.

### Trigger 2: First time they'd see the AI Coach (Intent Framing)

After 1-2 sessions where AI Coach intent framing WOULD appear (per
`AICoachPreference.intentFramingEnabled`), instead show a teaser:
> *"FocusForge+ adds a hand-written coach that helps frame your task before you start."*
> [Try Free for 7 Days] [Skip]

This is the conversion moment for users who care about coaching. Most
won't tap on session 1, but by session 3-4 they will if it's worth it.

### Trigger 3: First milestone (Day 3 streak)

When they hit Day 3 streak, instead of the milestone unlock animation
playing in-app, show:
> *"Your character is ready to grow."*
> *"Unlock cosmetics at streak milestones with FocusForge+."*
> [Show Me] → opens paywall with the Day-3 cosmetic preview embedded

This is the highest-converting trigger. They've **already proven they
care** by maintaining 3 days of focus.

### Trigger 4: Stats → 7-Day tab tap

When a free user taps the "7-Day" tab in Stats, the chart area is
blurred with an upgrade card overlay:
> *"See your week. Get the 7-day chart with FocusForge+."*

Soft. Not blocking the rest of the app.

### Trigger 5: Settings → Subscription row

Permanent affordance in Settings → Subscription showing current tier
+ upgrade CTA if free, or manage subscription / billing info if paid.

### What we DON'T do

- **No interrupting modals.** The paywall never blocks the user from
  completing a session.
- **No countdown timers** ("Upgrade now! 24 hours left!"). Manipulation.
- **No "limited offer" pricing.** $4.99 today, $4.99 in six months.
- **No "downgrade penalty."** If a user cancels FocusForge+, their
  character + streak + history are preserved. They just lose access
  to cosmetics + AI coach + advanced stats. If they resubscribe,
  everything comes back instantly.

---

## 5 · Free trial UX

iOS standard: tap "Try FREE for 7 days" → StoreKit modal → user
confirms → instant access to FocusForge+ features.

### During the trial

- All features unlocked
- A subtle "Trial: 5 days left" indicator appears in Settings →
  Subscription (NOT in the main app — would be intrusive)
- Local notification on day 5 of trial: *"3 days left in your
  FocusForge+ trial. Tap to manage."* (helpful, not pushy)

### Trial end

If they don't cancel: charges Monthly or Yearly per their selection.

If they DO cancel inside the 7-day window: trial ends, downgrade to
free tier at trial-expiration timestamp. AI Coach disappears,
character locks at current cosmetics (they keep what they earned
during trial — earned, not redeemable), 7-day chart goes back to
locked-with-upgrade-card.

### Resubscribe path

Any future session, they can resubscribe via Settings → Subscription
or any of the inline paywall triggers. All features come back.
Cosmetics earned during a previous trial are restored. Streak history
is intact (we never delete user data).

---

## 6 · What changes in the code

(High-level — implementation doc to follow)

### New types

- `SubscriptionTier` enum: `.free`, `.plus`, `.plusTrial`
- `SubscriptionManager` (`@Observable`): publishes current tier,
  trial end date, sub product info, restore-purchase status
- `Paywall` view (SwiftUI) — full-screen modal
- `PaywallTriggerKind` enum — first-session-end, ai-coach, milestone,
  stats-7day, settings — for analytics segmentation

### Modified

- `AICoachPreferenceManager` — checks tier before returning preferences
- `IntentFramingView`, `PostReflectionCardView` presentation — wrapped
  in tier check
- `MilestoneEngine.checkMilestone` — for free users, returns nil but
  fires a "milestone-blocked" event for the paywall trigger
- `RewardOverlayView` — branches on tier for simple vs cinematic
- `StatsView` — adds tier-gated blurring on locked tabs
- `SettingsView` — adds Subscription section at top

### App init

`FocusForgeApp.init()` — wire `SubscriptionManager` to App init,
listen for StoreKit transaction updates, hydrate tier from cache on
launch.

### Analytics events to add

- `paywall_shown` (with: trigger kind)
- `paywall_dismissed` (with: trigger kind, dismissal type)
- `trial_started` (with: product id, trigger kind)
- `trial_ended` (with: outcome — converted / cancelled, days_used)
- `subscription_purchased` (with: product id, trial converted bool)
- `subscription_renewed` (with: product id, renewal number)
- `subscription_cancelled` (with: product id, reason if known)

---

## 7 · What changes in the docs / marketing

### Privacy Policy

Add a "Purchase data" section under "What FocusForge collects":
> "When you purchase FocusForge+ via Apple's StoreKit, Apple
> processes the transaction. We receive a transaction ID and product
> identifier from Apple — no payment method, no name, no email. The
> transaction ID lets us validate your subscription status on your
> device. We don't store it on our servers (there are no servers in
> v1.0)."

### Terms of Use

§6 currently says "FocusForge+ in v1.1+". Update to present-tense:
> "FocusForge+ is an optional auto-renewable subscription. Pricing
> and trial details are shown in the in-app purchase flow before any
> charge. Cancel at any time via iOS Settings → Apple ID → Subscriptions.
> Apple's standard refund policy applies."

### App Store description

Add a paragraph (probably near the top):
> *"FocusForge is free to use. FocusForge+ unlocks the AI Coach,
> character progression, cosmetic milestones, advanced stats, and the
> cinematic reward moment for $4.99/month or $39.99/year. Try free
> for 7 days."*

### Screenshots

- Slot 2 (AI Coach) and Slot 6 (Reward Moment) should include a
  small **"FocusForge+"** badge in the corner so reviewers and users
  know what's behind the paywall
- Add an 8th screenshot showing the paywall itself with the trial CTA
  — this is the conversion screenshot and worth a slot

### About screen

Add a row to the Settings → About section:
> Subscription · FocusForge+ Monthly · Renews May 25
(or "Subscription · Free · Try FocusForge+ free for 7 days →")

---

## 8 · Open questions to resolve before code work begins

These haven't been decided yet — flagging for explicit calls:

1. **First-session reward moment for free** — exact visuals. The
   simple version of the reward screen needs to be a clean
   "completion confirmation" not a degraded reward moment. Spec
   needed.

2. **Day-1 paywall timing** — show paywall at end of first session, or
   wait until session 2 or 3? Earlier = higher trial start rate but
   higher complaint rate ("I just wanted to time my work"). My
   default: end of first session, soft inline affordance, no modal.

3. **Streak freeze behavior for free users** — they don't get
   freezes, but what happens when they miss a day? Streak resets to
   0. Should we offer a one-time "free freeze on first miss" as a
   conversion hook? Worth A/B testing post-launch but for v1.0 keep
   it simple: free = no freezes ever.

4. **Family Sharing** — StoreKit 2 supports it by default. Apple
   lets users share auto-renewable subscriptions with family group.
   We allow this (no reason not to). One subscription, up to 5
   family members get FocusForge+. Apple handles billing.

5. **Promotional codes** — Apple lets us issue 100 free
   subscription codes/quarter. Use for: TestFlight beta thank-yous,
   creator partnerships, friends-and-family. Allocate 30 for beta
   testers, 50 for creator outreach, 20 reserved.

6. **Refunds** — Apple's policy applies. We don't process refunds
   directly. If a user emails legal@ asking for one, we point them
   to Apple's "Report a Problem" flow.

---

## 9 · Sequence of work to launch

Now that the split is locked, here's the dependency order:

1. **App Store Connect subscription setup** (~1 hour, can do in
   parallel — only needs Team ID which is in-process)
   - Subscription Group: "FocusForge Plus"
   - Product: FocusForge+ Monthly ($4.99)
   - Product: FocusForge+ Yearly ($39.99)
   - Subscription localizations (English)
   - Tax + banking info confirmation
   - Promotional code allocation

2. **StoreKit 2 + SubscriptionManager** (~2-3 days)
   - `SubscriptionTier` enum, `SubscriptionManager` observable
   - Product fetching, purchase flow, transaction listener
   - Tier persistence + restore-on-launch logic

3. **Paywall view** (~1 day)
   - Full-screen modal with brand-aligned design
   - 4-5 benefit bullets + pricing comparison + CTA
   - Trial trigger via StoreKit

4. **Tier gating** (~2 days)
   - Thread `SubscriptionTier` through `AICoachPreferenceManager`,
     `MilestoneEngine`, `StatsView`, `RewardOverlayView`, etc.
   - Implement each paywall trigger point

5. **Settings → Subscription section** (~half day)
   - Current tier display
   - Manage subscription deep-link to iOS Settings
   - Restore Purchase button
   - Show trial countdown if in trial

6. **Docs + marketing updates** (~half day)
   - Privacy Policy + Terms updates
   - App Store description rewrite
   - Screenshot 8 (paywall) capture
   - About screen subscription row

7. **Testing** (~1-2 days)
   - Sandbox testing all purchase + trial + restore + cancel flows
   - Edge cases: trial expiration mid-session, subscription lapse,
     re-subscribe restores state, family sharing handoff

**Total: ~10 days of focused work.** Realistic 2 weeks including
context switches. Pushes submission from "as soon as Team ID lands"
to "Team ID + 2 weeks" — but the v1.0 that ships has revenue
mechanics from day 1.

---

## 10 · The bet

We're betting that 5-10% of installs convert to paid trial, and 25-35%
of trials convert to paid. Best case at 1,000 installs in month 1:

- 100 trials start
- 30 convert to paid
- ~$1,500 month-1 ARR ($50 × 30 across mixed Monthly/Yearly)

Worst case at 1,000 installs:

- 50 trials start
- 10 convert to paid
- ~$500 month-1 ARR

Either way, the business has revenue mechanics from launch. The Cuban
review's critique — "no business until you charge" — is resolved.

If the conversion math turns out worse than expected (say, 1% paid
conversion), we have data to iterate on. Without subscription on day
1, we'd have no data at all — just feature usage.

This is the right bet.

---

## Appendix: Things deliberately left out of v1.0

- **Annual billing discount beyond 33%** — kept conservative for
  v1.0; revisit at v1.1
- **Quarterly billing** — adds Apple Store Connect complexity for
  marginal value
- **Lifetime tier** — death spiral pricing for SaaS
- **Group / Team plans** — B2B-adjacent, belongs in Path C if pursued
- **Referral discounts** — adds complexity; revisit after first
  3 months of data
- **Tiered subscription** (FocusForge+ Basic, FocusForge+ Pro) —
  unnecessary complexity at v1.0 single-price-point
- **Hardware bundles** (FocusForge+ + Apple Watch app) — Apple Watch
  app itself is a v1.2+ concern
