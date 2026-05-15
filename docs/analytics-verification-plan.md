# FocusForge — Firebase Analytics Verification Plan

A complete pre-launch verification of every analytics event the app
emits. The retention metrics in PRD §14 (D1 ≥45%, D7 ≥20%, D30 ≥18%)
are only measurable if these events fire correctly with the right
parameters. This doc is the checklist for confirming that before v1.0
submission.

Run this verification end-to-end at least once on a clean simulator
install **after** the Firebase project is configured for DebugView,
**before** the TestFlight beta runs, and again after any major
refactor to AnalyticsService or its callsites.

---

## Tooling setup (one-time)

### Enable Firebase DebugView for the simulator

DebugView shows events in near-real-time, marks them with the
parameters they carried, and skips the normal 24-hour aggregation
delay. The official Firebase docs reflect the right enable steps; the
short version:

```bash
# Edit the running scheme's Run > Arguments > Environment Variables
# (in Xcode) OR pass via launch arguments to simctl:
xcrun simctl launch booted com.focusforge.app -FIRDebugEnabled
```

When the simulator launches with `-FIRDebugEnabled`, the device shows
up in the Firebase Console at:

**Firebase Console → Analytics → DebugView**

(Project: `focusforge-app`, account: `krissi889@gmail.com`)

Events stream into the timeline within ~30 seconds of firing.

### Disable DebugView when done

```bash
xcrun simctl launch booted com.focusforge.app -FIRDebugEnabled NO
```

Or just relaunch without the flag.

---

## The full event catalog

Every event the app emits, with location, trigger, and expected
parameters. Source of truth: `AnalyticsEvent` enum in
[`AnalyticsService.swift`](../app/FocusForge/Services/AnalyticsService.swift).

### Session lifecycle

| Event | Where | Trigger | Parameters |
|---|---|---|---|
| `session_started` | `TimerView.swift:411` | User taps "Start Focus" and the timer begins (after IntentFraming if shown) | `phase` ("focus" / "shortBreak" / "longBreak"), `planned_duration_seconds` |
| `session_completed` | `SessionLogger.swift:67` | A timer reaches its full duration | `phase`, `task_name_length` (no actual task name, just char count), `actual_duration_seconds`, `planned_duration_seconds`, `xp_earned`, `coins_earned` |
| `session_abandoned` | `SessionLogger.swift:111` | User taps Stop before the timer reaches duration | `phase`, `task_name_length`, `actual_duration_seconds`, `planned_duration_seconds` |

### Streak progression

| Event | Where | Trigger | Parameters |
|---|---|---|---|
| `streak_incremented` | `StreakManager.swift:23, 48` | Streak day count increases by 1 (first session of a new day) | `current_streak_days`, `longest_streak_days` |
| `streak_lost` | `StreakManager.swift:40` | User misses a day with no freezes available → streak resets to 0 | `previous_streak_days`, `days_missed` |
| `streak_freeze_used` | `StreakManager.swift:31` | User misses a day but a freeze is consumed to protect the streak | `current_streak_days`, `freezes_remaining` |

### Milestones

| Event | Where | Trigger | Parameters |
|---|---|---|---|
| `milestone_unlocked` | `MilestoneEngine.swift:95` | Streak reaches a milestone day (3, 7, 14, 30, 60) | `streak_day`, `item_id`, `item_rarity`, `freeze_granted` |

### Cosmetics

| Event | Where | Trigger | Parameters |
|---|---|---|---|
| `cosmetic_equipped` | `InventoryGridView.swift:58, 78` | User taps an owned cosmetic to equip it | `item_id`, `slot`, `rarity` |
| `cosmetic_unequipped` | `InventoryGridView.swift:48` | User taps an already-equipped cosmetic to unequip | `item_id`, `slot`, `rarity` |
| `cosmetic_purchased` | `InventoryGridView.swift:72` | User spends coins on a locked cosmetic | `item_id`, `coin_cost`, `rarity` |

### AI Coach (PRD §12 mandatory)

| Event | Where | Trigger | Parameters |
|---|---|---|---|
| `ai_prompt_shown` | `IntentFramingView.swift:46`, `PostReflectionCardView.swift:33`, `StreakRescueBannerView.swift:54` | One of the three AI surfaces appears | `kind` ("intent" / "reflection" / "streak_rescue"), `template_id` (e.g. `frm_code_01`), additional fields per kind |
| `ai_suggestion_accepted` | `IntentFramingView.swift:103, 116` | User taps Accept on intent framing | `kind`, `template_id`, `edited` (bool — did they tap Edit first?) |
| `ai_suggestion_dismissed` | `IntentFramingView.swift:137`, `PostReflectionCardView.swift:60`, `StreakRescueBannerView.swift:36` | User taps Skip on framing, Not Helpful on reflection, or X on the rescue banner | `kind`, `template_id` |
| `ai_recommendation_followed` | `PostReflectionCardView.swift:47` | User taps Helpful on a post-session reflection | `kind` ("reflection"), `category` ("timeManagement" / "consistency" / "selfCare" / "momentum") |
| `ai_nudge_opened` | `StreakRescueBannerView.swift:26` | User taps the Start button on the streak rescue banner | `kind` ("streak_rescue"), `streak_days` |

**18 distinct events.** All wired through `AnalyticsService.track(_:parameters:)` → `FirebaseAnalyticsBackend` → `Analytics.logEvent(…)`.

---

## The verification walkthrough

A single end-to-end run that triggers every event in order. Do this
with DebugView open in a browser tab so you can confirm each one
appears.

**Pre-conditions:** clean simulator install, AI Coach enabled (default
state), focus duration set to 1 minute for quick iteration.

### Walkthrough A: First session with a task

1. **Launch the app.** Check DebugView for app-start events
   (Firebase auto-events like `first_open`, `session_start`,
   `app_clear_data` — these aren't ours; ignore them).
2. **Tap the task field, type "Test session".** No event expected.
3. **Tap Start Focus.**
   - **Expect:** `ai_prompt_shown` (kind=intent, template_id=`frm_*`)
4. **Tap Accept on the IntentFraming sheet.**
   - **Expect:** `ai_suggestion_accepted` (kind=intent, edited=false, template_id=…)
   - **Expect:** `session_started` (session_type=focus, planned_duration_seconds=60)
5. **Wait 60 seconds for the session to complete.**
   - **Expect:** `session_completed` (session_type=focus, actual_duration=60, xp_earned=10ish, coins_earned=10ish)
   - **Expect:** `streak_incremented` (current_streak_days=1)
   - **Expect:** `ai_prompt_shown` (kind=reflection, category=…)
6. **Tap "Helpful" on the reflection card.**
   - **Expect:** `ai_recommendation_followed` (kind=reflection, category=…)
7. **Tap Continue.** No new event expected.

**Verify in DebugView:** all 7 expected events should appear in the
timeline in order. Each should have the right parameter values.

### Walkthrough B: Abandoned session

1. **Tap Start Focus** with a task.
2. **Tap Accept on IntentFraming.**
3. **Tap Stop after ~10 seconds.**
   - **Expect:** `session_abandoned` (session_type=focus, actual_duration_seconds=~10)

### Walkthrough C: Streak rescue nudge

1. **Open Settings → Debug → "Trigger Streak Risk (Yesterday Evening)".**
   Sets `streakRiskScore >= 0.3`.
2. **Tap Timer tab.**
   - **Expect:** `ai_prompt_shown` (kind=streak_rescue, streak_days=N)
3. **Tap the X on the banner.**
   - **Expect:** `ai_suggestion_dismissed` (kind=streak_rescue, streak_days=N)
4. **Force the banner back via Settings → Debug → "Force Streak Rescue Banner" ON.**
5. **Tap the Start button on the banner.**
   - **Expect:** `ai_nudge_opened` (kind=streak_rescue, streak_days=N)

### Walkthrough D: Milestone unlock

1. **Open Settings → Debug → "Set Streak to Day 3 (Early Bird)".**
   - **Expect:** `milestone_unlocked` (streak_day=3, item_id=`horn1`, item_rarity=common, freeze_granted=1)

### Walkthrough E: Cosmetics

1. **Tap Character tab.**
2. **Tap an owned cosmetic that isn't currently equipped.**
   - **Expect:** `cosmetic_equipped` (item_id=…, slot=…, rarity=…)
3. **Tap the same cosmetic again.**
   - **Expect:** `cosmetic_unequipped` (same params)
4. **Tap a locked cosmetic** (one with a coin cost you have coins for, or grant 500 coins via Debug).
   - **Expect:** `cosmetic_purchased` (item_id=…, coin_cost=…, rarity=…)
   - **Expect:** `cosmetic_equipped` (same item, auto-equipped on purchase)

### Walkthrough F: Streak loss

Hardest to trigger because you'd need to advance the clock by 2+ days
without any freezes. Skip in initial verification — confirm via unit
tests in `StreakManagerTests.swift` that the event call site is
reached when conditions match. Can be force-tested by:
1. Using SwiftData inspector to manually clear `freezesAvailable` to 0
2. Setting `lastCompletedDate` to 3 days ago
3. Completing a new session — should fire `streak_lost`

---

## Verification checklist

Tick each event when confirmed in DebugView:

- [ ] `session_started` — focus
- [ ] `session_started` — shortBreak
- [ ] `session_started` — longBreak
- [ ] `session_completed`
- [ ] `session_abandoned`
- [ ] `streak_incremented`
- [ ] `streak_lost`
- [ ] `streak_freeze_used`
- [ ] `milestone_unlocked` — day 3
- [ ] `milestone_unlocked` — day 7
- [ ] `cosmetic_equipped`
- [ ] `cosmetic_unequipped`
- [ ] `cosmetic_purchased`
- [ ] `ai_prompt_shown` — kind=intent
- [ ] `ai_prompt_shown` — kind=reflection
- [ ] `ai_prompt_shown` — kind=streak_rescue
- [ ] `ai_suggestion_accepted` — edited=false
- [ ] `ai_suggestion_accepted` — edited=true
- [ ] `ai_suggestion_dismissed` — kind=intent
- [ ] `ai_suggestion_dismissed` — kind=reflection
- [ ] `ai_suggestion_dismissed` — kind=streak_rescue
- [ ] `ai_recommendation_followed`
- [ ] `ai_nudge_opened`

## What to do if an event doesn't fire

1. Confirm `AnalyticsService.backend = FirebaseAnalyticsBackend()` is
   set in `FocusForgeApp.init()`. If the no-op backend is still wired,
   events log to stdout but don't reach Firebase.
2. Check the relevant call site for a conditional that may have
   short-circuited the call (e.g. `if preference.aiCoachEnabled`).
3. Confirm `GoogleService-Info.plist` is correct and includes a
   `GCM_SENDER_ID` and `BUNDLE_ID` matching `com.focusforge.app`.
4. Confirm the `-FIRDebugEnabled` launch argument is set on the
   scheme/launch you're using.
5. Add a temporary `print("[Analytics call site] firing")` line
   immediately before the `AnalyticsService.track(…)` call to
   distinguish "code path never reached" from "code path reached but
   event lost in transit."

## Parameter naming convention

Events use **snake_case** for the event name (`session_started`).
Parameters use **snake_case** for keys (`phase`,
`planned_duration_seconds`). This matches Google's recommended
convention and makes the BigQuery export schema cleaner if we ever
need to query raw event data.

**Audit complete 2026-05-15.** All parameter keys verified snake_case.
Duration parameters normalized to `_duration_seconds` (was mixed
`_minutes` for completion, `_seconds` for abandonment). Boolean
`task_named` replaced with integer `task_name_length` (char count)
across all three session events — privacy-preserving (never the
string) but more useful for analytics.

Unified shape of duration params across session events:

| Event | `planned_duration_seconds` | `actual_duration_seconds` | `task_name_length` |
|---|---|---|---|
| `session_started` | ✓ | n/a | ✓ |
| `session_completed` | ✓ | ✓ | ✓ |
| `session_abandoned` | ✓ | ✓ | ✓ |

## Privacy guarantees re-checked

While doing this walkthrough, **verify in DebugView that no event
contains the actual task name** the user typed. The `task_name_length`
parameter is the character count — never the string itself. If you
see the task name appear in any event, that is a privacy regression
and must be fixed before any submission.

The privacy policy commits us to this:
> Your task names ("Draft Q3 report," "Study for biology exam," etc.)
> never leave your iPhone under any circumstances.

This is a structural property of the code (the events only carry
character counts, not strings), but the verification walkthrough is
the moment to confirm.

---

## Status as of 2026-05-15

- Firebase SDK integrated ✓
- `FirebaseAnalyticsBackend` wired in `FocusForgeApp.init()` ✓
- Event catalog complete in `AnalyticsService.swift` ✓
- DebugView walkthrough **not yet performed**
- Parameter key naming audit **not yet performed**
- Task-name leak check **not yet performed**

The walkthrough is the gate before TestFlight. Run it once when
focused, with DebugView open in a browser tab and the simulator
visible.
