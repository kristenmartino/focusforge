# Focus Forge AI Addendum (On-Device, Retention-First)

## 1. Objective
Ship AI features that improve daily return and streak completion without requiring cloud processing of raw task text.

Primary outcomes:
- +8-12% 7-day streak attainment
- +4-6% D30 retention
- +10% completed sessions per DAU

## 2. Scope by Wave

### Wave 1: AI Coach Core (MVP)
- Intent Framing Prompt before focus sessions
- Post-Session Reflection with one actionable tweak
- Streak Rescue Nudge near streak-loss window

### Wave 2: Adaptive Focus Engine
- Session length recommendation (15/25/40)
- Break type recommendation (movement/breathing/hydration/reset)
- Fatigue detection and easier-target recommendations

### Wave 3: Character Intelligence Layer
- Character voice responses based on behavioral patterns
- Weekly journey recap narrative
- Smart reward message timing by effort pattern

## 3. Data Contracts

### AICoachPreference
- tone: `encouraging | direct | calm`
- nudge_frequency: `low | medium | high`
- privacy_mode: `on_device_only | hybrid_opt_in`

### AIInteractionLog
- session_id: string
- feature_type: `framing | reflection | nudge | recommendation`
- accepted: bool
- dismissed: bool
- latency_ms: int
- created_at: datetime

### BehaviorSignal
- completion_rate_7d: float
- abandon_rate_7d: float
- avg_actual_focus_minutes: float
- streak_risk_score: float (0..1)

## 4. Inference Interfaces
- `generate_focus_intent(input_task, recent_behavior) -> intent_text`
- `generate_post_session_tip(session_outcome, recent_behavior) -> tip_text`
- `recommend_next_session(recent_behavior) -> {duration, break_type, rationale}`

## 5. Guardrails
- Default privacy mode is `on_device_only`.
- AI features are optional and never block timer flow.
- If model confidence is low or inference fails, fall back to deterministic rules.
- Nudge frequency cap and quiet-hours support required.

## 6. Analytics Events
- ai_prompt_shown
- ai_suggestion_accepted
- ai_suggestion_dismissed
- ai_recommendation_followed
- ai_nudge_opened

## 7. Rollout
1. Internal dogfood (1 week)
2. 10% A/B rollout (2 weeks)
3. 50% rollout with guardrails
4. 100% rollout after KPI pass; begin Wave 2

## 8. Acceptance Tests
- Vague task is reframed into one concrete action.
- Near streak-loss state triggers at most one rescue nudge per configured window.
- Low completion trend decreases suggested duration.
- Wave 1 features run offline.
- Tone and frequency preferences are respected.
- Safety filter prevents shaming or harmful output.
