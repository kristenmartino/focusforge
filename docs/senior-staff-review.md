# FocusForge v1.0 — Senior Staff Cross-Functional Review

**Date:** 2026-05-17
**Reviewer roles:** Engineering, Design, UX, Product, Marketing,
Legal/Compliance, Operations, Data/Analytics, Brand, QA
**Posture:** Critique. Find what's broken, missing, or risky. No flattery.

---

## 0 · Verdict in one paragraph

The app is technically ready for TestFlight but not for the App Store
review queue yet. **Three issues are submission-blocking** and need
fixing before archive. **Five issues are launch-quality** and should
ship before the beta opens. The rest are post-launch backlog. The
craft thesis is strong on engineering surfaces (open-source engine,
on-device AI, code-as-design icon) but underbuilt on the
onboarding/positioning surfaces that determine whether anyone actually
discovers what we built.

---

## 🚨 SUBMISSION BLOCKERS — fix before archive

### B1 · iPad device family will get the build rejected

`app/project.yml:22` sets `TARGETED_DEVICE_FAMILY: "1,2"` — iPhone +
iPad. Apple validates that iPad builds have iPad-optimized layouts.
Submitting with iPad in the family while only shipping iPhone UI is a
common rejection reason ("UI does not adapt to iPad").

**Fix:** change to `TARGETED_DEVICE_FAMILY: "1"` (iPhone-only) until
v1.1 actually ships iPad layouts. One-line change, regenerate Xcode
project. Strategic decision was already made (PRD §iPad deferred), the
project file just didn't get updated.

**Owner:** Engineering. **Effort:** 5 minutes. **Risk if skipped:** ~70%
chance of submission rejection on first try.

### B2 · Firebase analytics walkthrough never executed

The verification plan in `docs/analytics-verification-plan.md`
documents 18 events with expected parameters. **It was never run.** We
don't actually know if the events fire correctly when triggered. If
even one event doesn't fire (e.g. `session_completed` blocked by a
condition we didn't catch), the retention metrics that define
"FocusForge succeeded" (D1/D7/D30) are uninterpretable from day one of
TestFlight.

**Fix:** Run the walkthrough. Open Firebase DebugView in browser,
launch sim with `-FIRDebugEnabled`, walk Scripts A–E from the doc, tick
every checkbox. ~45 min focused.

**Owner:** Engineering. **Effort:** 45 minutes. **Risk if skipped:**
high — we ship blind on the metrics that define success.

### B3 · COPPA / age-rating mismatch

Privacy Policy says "we do not knowingly collect any data from children
under 13." App Store listing draft says age rating **12+**. A 12-year-old
can install per Apple's 12+ rating, but if they do, we're now subject
to COPPA's "actual knowledge of child" provisions and our "we don't
collect from under 13" claim becomes harder to defend.

**Fix:** raise age rating to **13+** (or 17+ if we want belt-and-suspenders).
This matches the COPPA threshold the Privacy Policy already commits to.
Update `docs/app-store-listing.md` §"Age Rating" and answer Apple's age
questionnaire accordingly.

**Owner:** Legal/Product. **Effort:** 10 minutes. **Risk if skipped:**
real regulatory exposure if a child user is identified later.

---

## ⚠️ LAUNCH-QUALITY — fix before TestFlight opens to externals

### L1 · Onboarding teaches almost nothing

The 4-screen onboarding (Welcome → Character Select → Notifications →
All Set) is 30 seconds of brand-soak. It does NOT teach:

- What the streak system does (or that it exists)
- That cosmetics unlock at day 3/7/14/30/60
- What the AI Coach is or when it appears
- The on-device privacy thesis (the brand's structural differentiator)
- How a focus session actually works (no walkthrough)

A user reaches the Timer tab having selected a character, then sees a
01:00 timer + "Start Focus" button with no context for why this app is
different from the 1,000 other Pomodoro timers. **First-impression
collapse to "Pomodoro w/ avatar".**

**Fix:** add 1–2 onboarding cards between "All Set" and the Timer tab
that show:
- (a) A character growing across milestone unlocks ("Day 3 = first
  cosmetic. Day 7 = freeze. Day 14 = wings. Day 60 = the rare one.")
- (b) The AI Coach as a single sample card ("Before each session, your
  coach reframes the task. It's hand-written and runs on your phone.")

**Owner:** Product/Design. **Effort:** 4-6 hours including copy
+ visual. **Risk if skipped:** D1 retention takes the hit. The
character/coach thesis can't pay off if users never learn it exists.

### L2 · Hero screenshot doesn't tell the brand's story

`assets/app-store-screenshots/pro-max-1320x2868/01-timer-hero.png` is
the Timer tab at idle. The character is ~80pt at the top — small
relative to the 25:00 timer. App Store thumbnails downscale to ~150pt
wide. At thumbnail size, the character disappears and the screenshot
reads as **"a Pomodoro timer."** First glance impression: this is a
focus-timer app. Not "your focus grows your character."

**Fix:** either (a) re-stage the hero to show the character larger
+ visible cosmetics + Day N badge prominently, OR (b) make the
**reward moment** the hero (screenshot 06 — visually richest, story
telling). The reward moment is unique to FocusForge. The Timer hero
is not.

**Owner:** Design/Marketing. **Effort:** 30 minutes to re-shoot and
test thumbnails. **Risk if skipped:** App Store conversion craters
because the hero looks like a category-default.

### L3 · "No AI slop" lands defensive

App Store promotional text uses "no AI slop" as the differentiating
phrase. It's punchy on Twitter/HN but on the App Store card it reads
**negative** — defining the product by what it ISN'T. Most App Store
shoppers don't have a strong prior about AI slop; they don't recognize
themselves in the contrast.

**Positive reframe options:**
- "Every coach line was written by a human."
- "33 hand-written templates. Zero generated text."
- "A coach that respects your focus."

Pick one. Keep "no AI slop" for X where the audience already feels
the irritant.

**Owner:** Marketing/Brand. **Effort:** 15 minutes. **Risk if skipped:**
App Store conversion below what it could be — first-time visitors
miss the value the contrast was meant to convey.

### L4 · Analytics opt-out default = ON. Is this defensible?

We default `analytics.enabled = true` in the new toggle because we
need D1/D7/D30 measurement. **But our brand promise is privacy-first.**
Users who care most about privacy will be over-represented in the
"opt out" cohort, which means our retention metrics will be **biased
toward less privacy-conscious users**. The very users who'd validate
the brand thesis are invisible in the data.

Two paths:
1. **Keep opt-in default** (analytics ON) and accept the bias. Add a
   `cohort_opted_out_of_analytics` event so we can at least count
   how many users opted out (which itself is privacy-respecting —
   the count event has no other parameters).
2. **Flip default to opt-OUT** (analytics OFF) and accept that the
   D1/D7/D30 sample size will be smaller. Honest about the tradeoff.

Option 1 is what we shipped. Option 2 is more brand-aligned. Worth a
deliberate call rather than the current default-by-omission.

**Owner:** Product/Brand. **Effort:** decision + 30 min if we flip.
**Risk if skipped:** metrics tell us only about the less-privacy-
conscious subset; brand thesis goes unvalidated.

### L5 · No customer support workflow

Privacy Policy + Terms commit to a **7-business-day SLA** for replies
to `privacy@` and `legal@`. There's no plan for:
- Who triages incoming mail to these aliases
- Where bug reports go from App Store reviews
- How a P0 issue in a TestFlight build gets escalated
- Whether the user (Kristen) will actually check the inbox daily

The aliases now forward to a real inbox — but if Kristen takes a 3-day
trip and a CCPA "delete my data" request lands, we've technically
breached our own published SLA. Indie apps don't get sued over this,
but the brand-as-craft thesis takes damage.

**Fix:** simple support runbook in `docs/operations/support-workflow.md`
covering (1) inbox monitoring cadence, (2) escalation tree for
different request types, (3) auto-reply template confirming receipt
and setting expectation. Drafted in 30 minutes.

**Owner:** Operations. **Effort:** 30 minutes. **Risk if skipped:**
slow response to a real CCPA/GDPR request that becomes a public
embarrassment.

---

## 🟡 IMPORTANT — backlog for v1.0.1 or earlier

### I1 · Onboarding Day 0 first-launch unverified

A truly fresh install lands on Timer with `currentStreakDays = 0`. No
Day badge to show. What does the screen look like? Has it been
visually verified? The Day N badge code probably hides when N=0, but
the empty space around the FOCUS label might read as broken.

**Fix:** boot a clean simulator, complete onboarding, screenshot the
Day-0 Timer state. Verify nothing looks broken.

### I2 · Streak rescue banner UX call is debatable

We scoped the banner to Timer-tab-only to fix the nav-bar overlap.
But a user who taps Settings to check their streak count is in
exactly the moment they need to be nudged — and the banner won't
show. **We fixed an aesthetics bug by removing a contextually-relevant
intervention.**

**Alternative fix:** keep the banner global but render it as a
`safeAreaInset(edge: .top)` below the nav bar instead of above it.
More work but better UX.

### I3 · Quest claim friction

Reward overlay shows completed quests with "Claim in the Quests tab."
User must remember to go claim. Many will forget. Two options:
- **Auto-claim** completed quests at session end and show "+50 XP /
  +40 Coins claimed from Maintain your streak" in the reward overlay
- **Badge the Quests tab** with a count of unclaimed-but-completed
  quests so the affordance is visible

Currently the Quests tab badge counts ALL active quests including
in-progress. Should count only claimable.

### I4 · The 99-pieces-of-micro-copy metric doesn't sell the value

The metric is engineering-true and craft-proud but user-irrelevant.
**Users don't care how many templates we wrote — they care that the
coach won't sound creepy.** Reframe everywhere it appears:

- App Store description: "A coach that won't tell you to 'crush it'
  or 'hustle harder.'"
- About screen: keep the metric as evidence; lead with the user value
- README: same — lead with what the user gets, not what we counted

### I5 · The character-meaning gap between days 7 and 14

Milestones at day 3, 7, 14, 30, 60. The gap from day 7 → day 14 is 7
days of no new unlocks. This is the cliff where habit-formation
research says most users drop. The character system doesn't
intervene exactly when intervention is most needed.

**Possible fix:** add an interstitial visual milestone — not a cosmetic
unlock, but a visible "Week 2 — your character is leveling up"
celebration at day 10 or 11. Cheap to add. Could meaningfully change
the D14 → D30 cliff.

### I6 · Test coverage gap on the AI Coach flow

Sprint 6 added 46 tests across StreakManager, MilestoneEngine,
SessionLogger, DataExport. **Zero tests** on:
- QuestManager.claimReward
- BehaviorSignalComputer.compute (the host adapter — package math is
  tested but the SwiftData fetch path isn't)
- AICoachPreferenceManager
- StreakNudgeScheduler.evaluateAndScheduleIfNeeded
- SwiftDataTemplateUsageHistory (the new adapter)

The new adapter especially deserves tests because it's the seam
between SwiftData and the package. A bug here is invisible until users
see the same coach template twice.

### I7 · Reward overlay PostReflection card visually unverified

The rewrite of `PostReflectionCardView` shipped but was only seen
briefly in the final reward-moment screenshot. It uses FrostedCard,
the new feedback button pills, etc. — but we never verified the
"Thanks for the feedback" post-tap state, the dark-mode contrast on
the feedback pills, or whether the layout breaks at small device sizes
(iPhone SE).

### I8 · iPhone SE device support unverified

The PRD targets iOS 17+, which includes iPhone SE 3rd gen (4.7"
display). All visual verification this session was on iPhone 16e and
17 Pro Max. The 4.7" display will compress everything ~25%. Vertical
overflows are likely on:
- IntentFramingView (medium-detent sheet barely fits content at Pro
  Max — at SE it will overflow)
- Reward overlay (has reflection card + quests + stats — could push
  Continue button off-screen)
- Dressing room (was already crowded; SE will be worse)

---

## 🔵 BACKLOG — v1.1 or post-launch

### V1 · No A/B testing infrastructure

Can't test coach tone defaults, onboarding variants, or icon
alternatives once live. Firebase Remote Config is in the SDK but
unused. Worth wiring up before we want to actually test something.

### V2 · No in-app feedback collection

User feedback flows are: App Store review, OR email to privacy@/legal@.
That's thin. A modest in-app "Was this session helpful?" prompt or a
1x-per-30-days NPS-style ask would 10x our signal volume.

### V3 · App Store SEO for "FocusForge" unverified

The name "FocusForge" — has the user searched for it in App Store
yet? If "Focus" or "Forge" as standalone terms already have apps
dominating, our search ranking might be brutal. Should also verify
the keyword string `pomodoro,focus,timer,rpg,productivity,...` and
plan a 30-day post-launch keyword swap test.

### V4 · No mechanism for "we built X new thing — go look" announcements

When v1.1 adds CloudKit sync or v1.2 adds new cosmetics, how do
existing users find out? In-app changelog modal? Notification? Right
now: nothing. Worth a "What's new" mechanism before the first feature
push.

### V5 · The coach engine is dogfooded but the host app could exercise more of it

The package's `BehaviorSignalMath` exposes helpers we don't all use
yet (e.g. there's a `streakRiskScore` we use, but also exposes
keyword extraction we could use to suggest task categories at typing
time). Untapped craft opportunity.

### V6 · CoachTemplateCatalog could benefit from a personality contributor program

The catalog is 33 templates × 3 tones. As an open-source project we
could accept community PRs that add tones (e.g. "minimalist",
"poetic", "drill sergeant" with a clear tag that it's a community
tone, not the bundled three). Increases the catalog's appeal as an
artifact without increasing our maintenance burden.

---

## 🟢 WHAT'S ACTUALLY GOOD — worth acknowledging

This list is short on purpose.

- **Open-source coach engine actually shipped + dogfooded.** Not just a
  marketing artifact — the app consumes it. Privacy claim becomes
  structurally provable.
- **Privacy + Terms hosted with proper jurisdiction + email aliases
  active.** Most indie apps ship with placeholder legal docs.
- **App icon generated programmatically.** Reproducible, version-
  controlled, on-brand. Better than 90% of indie icons.
- **46 critical-path tests with SwiftData VersionedSchema.** Migration
  path won't catastrophically break user data.
- **The cinematic reward moment.** Five hand-tuned beats actually pay
  off the "two emotional registers" thesis. Genuine craft.

---

## Cross-functional risk matrix

| Risk | Owner | Likelihood | Impact | Status |
|---|---|---|---|---|
| iPad device family rejection | Engineering | High | Blocks launch | Blocker |
| Analytics events broken in prod | Engineering | Medium | Metrics lost | Blocker |
| COPPA exposure from 12+ rating | Legal | Low | Regulatory | Blocker |
| Onboarding doesn't teach systems | Product | High | D1 retention | Launch-quality |
| Hero screenshot reads as Pomodoro | Marketing | High | Conversion | Launch-quality |
| Privacy SLA not actually monitored | Ops | Medium | Brand damage | Launch-quality |
| Analytics opt-in default biases data | Data | Medium | Metrics unreliable | Launch-quality |
| "No AI slop" lands negative | Brand | Medium | Conversion | Launch-quality |
| Day-7 → Day-14 cliff unaddressed | Product | High | D14 retention | v1.0.1 |
| Quest claim friction loses XP | UX | Medium | Engagement | v1.0.1 |
| iPhone SE layout broken | Engineering | Medium | User experience | v1.0.1 |
| Test coverage gap on coach + quests | Engineering | Low | Bug risk | v1.0.1 |
| 99-templates metric doesn't sell value | Brand | Low | Conversion | v1.0.1 |
| No A/B test infrastructure | Engineering | n/a | Future iteration | v1.1 |
| No in-app feedback collection | Product | n/a | Signal poverty | v1.1 |
| App Store SEO unverified | Marketing | Medium | Discovery | v1.1 |

---

## Suggested sequence to address

**Today / this session (30 min):**
1. B1 — fix iPad device family
2. B3 — bump age rating to 13+

**Before TestFlight upload (~3 hours):**
3. B2 — run Firebase analytics walkthrough
4. L4 — make a real call on analytics opt-in default
5. L5 — write 30-minute support workflow runbook

**Before external TestFlight (~half a day):**
6. L1 — add 1-2 onboarding cards teaching streak + coach
7. L2 — re-stage hero screenshot
8. L3 — reframe "no AI slop"
9. I1 — verify Day-0 first-launch state

**Before App Store submission (~half a day):**
10. I7 — verify reward overlay reflection card
11. I8 — verify iPhone SE layouts on smallest target device
12. Touch-up screenshots if SE verification surfaces issues

**Post-launch backlog:**
- I2-I6, V1-V6 — file as GitHub issues, sequence by D-metric impact

---

## One thing I'd say to the founder

The craft thesis is real and the surfaces that prove it (open-source
engine, code-as-design icon, privacy controls) are unusually rigorous
for an indie app. The work that's been done this week is genuinely
good. But the **discovery layer** — the 4 seconds a user spends on
the App Store screenshot before swiping past — doesn't yet carry the
craft thesis. The hero looks like a Pomodoro timer. The price of an
unconverted impression is much higher than the price of polishing one
more screenshot.

Spend an extra half-day on the onboarding + hero before submitting.
Everything downstream of those two surfaces benefits.

Don't ship until B1, B2, B3 are resolved. The rest can be argued.
Those three are not negotiable.
