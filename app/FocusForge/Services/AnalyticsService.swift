import Foundation

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
enum AnalyticsService {
    nonisolated(unsafe) static var backend: AnalyticsBackend = NoOpAnalyticsBackend()

    static func track(_ event: AnalyticsEvent, parameters: [String: Any] = [:]) {
        backend.track(event: event.rawValue, parameters: parameters)
    }

    static func setUserProperty(_ value: String?, forKey key: String) {
        backend.setUserProperty(value, forKey: key)
    }
}
