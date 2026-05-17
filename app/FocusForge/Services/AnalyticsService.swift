import Foundation
import FirebaseAnalytics

/// Type-safe event names for product analytics.
///
/// PRD §12 mandates the AI events. Core events extend that to cover
/// the success metrics in PRD §14 (D1/D30 retention, focus minutes per
/// DAU, AI suggestion acceptance).
enum AnalyticsEvent: String {
    // Session lifecycle
    case sessionStarted = "session_started"
    case sessionCompleted = "session_completed"
    case sessionAbandoned = "session_abandoned"

    // Streak progression
    case streakIncremented = "streak_incremented"
    case streakLost = "streak_lost"
    case streakFreezeUsed = "streak_freeze_used"

    // Milestones
    case milestoneUnlocked = "milestone_unlocked"

    // Cosmetics
    case cosmeticEquipped = "cosmetic_equipped"
    case cosmeticUnequipped = "cosmetic_unequipped"
    case cosmeticPurchased = "cosmetic_purchased"

    // AI Coach (PRD §12)
    case aiPromptShown = "ai_prompt_shown"
    case aiSuggestionAccepted = "ai_suggestion_accepted"
    case aiSuggestionDismissed = "ai_suggestion_dismissed"
    case aiRecommendationFollowed = "ai_recommendation_followed"
    case aiNudgeOpened = "ai_nudge_opened"
}

/// Backend implementations track events to a real provider (Firebase,
/// PostHog, etc.) or to nothing in the no-op case. Swap by setting
/// `AnalyticsService.backend` once at app launch.
protocol AnalyticsBackend {
    func track(event: String, parameters: [String: Any])
    func setUserProperty(_ value: String?, forKey key: String)
}

/// Default backend used until a real one is configured. Logs to stdout
/// in DEBUG builds so wiring is visible during development.
struct NoOpAnalyticsBackend: AnalyticsBackend {
    func track(event: String, parameters: [String: Any]) {
        #if DEBUG
        if parameters.isEmpty {
            print("[Analytics] \(event)")
        } else {
            print("[Analytics] \(event) \(parameters)")
        }
        #endif
    }

    func setUserProperty(_ value: String?, forKey key: String) {
        #if DEBUG
        print("[Analytics] userProperty \(key)=\(value ?? "nil")")
        #endif
    }
}

/// App-wide analytics entry point. Call sites use the type-safe
/// `track(_:parameters:)` overload.
///
/// Backend is swappable: `AnalyticsService.backend = FirebaseBackend()`
/// in App init() once the Firebase SDK is integrated.
///
/// User-controllable opt-out: gated on the `analytics.enabled` AppStorage
/// key. When the user toggles "Send anonymous analytics" off in
/// Settings → Privacy, this key flips to false and `track(_:parameters:)`
/// early-returns without forwarding to the backend. The Privacy Policy
/// commits to this control existing at v1.0.
enum AnalyticsService {
    nonisolated(unsafe) static var backend: AnalyticsBackend = NoOpAnalyticsBackend()

    /// AppStorage key for the user's analytics opt-in preference.
    /// Defaults to `true` (events flow) unless explicitly toggled off.
    /// Same key consumed by `SettingsView`'s privacy toggle and by
    /// `FocusForgeApp.init()`'s SDK-level Firebase collection control.
    static let analyticsEnabledKey = "analytics.enabled"

    /// Reads the current user preference. Defaults to `true` if never
    /// set (preserves the original-spec behavior for fresh installs;
    /// the toggle explicitly opts out, not opts in).
    static var isAnalyticsEnabled: Bool {
        // AppStorage uses UserDefaults under the hood. If the key has
        // never been written, `object(forKey:)` returns nil and we
        // treat that as "enabled by default" so the analytics events
        // flow for users who haven't visited the privacy toggle.
        if let value = UserDefaults.standard.object(forKey: analyticsEnabledKey) as? Bool {
            return value
        }
        return true
    }

    static func track(_ event: AnalyticsEvent, parameters: [String: Any] = [:]) {
        // User opt-out gate — Privacy Policy commits to this control.
        // Early-return before reaching the backend means no event is
        // forwarded to Firebase or any future backend, even if the
        // SDK's own collection flag isn't honored (defense in depth).
        guard isAnalyticsEnabled else { return }
        backend.track(event: event.rawValue, parameters: parameters)
    }

    static func setUserProperty(_ value: String?, forKey key: String) {
        guard isAnalyticsEnabled else { return }
        backend.setUserProperty(value, forKey: key)
    }

    /// Flips the Firebase SDK's collection flag. Called from the
    /// Settings → Privacy toggle (via `.onChange`) so the SDK itself
    /// stops collecting when the user opts out — not just our wrapper.
    /// Defense in depth.
    static func setSDKCollectionEnabled(_ enabled: Bool) {
        Analytics.setAnalyticsCollectionEnabled(enabled)
    }
}
