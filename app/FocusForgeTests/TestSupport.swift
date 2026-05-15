import Foundation
import SwiftData
@testable import FocusForge

/// Shared in-memory model container for tests. Wipes between tests because
/// each test instantiates a fresh container.
enum TestSupport {
    /// Builds an isolated in-memory ModelContainer with the full app schema.
    /// Each test should call this in setUp() so state doesn't bleed.
    @MainActor
    static func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            UserProfile.self,
            TimerPreset.self,
            SessionLog.self,
            StreakState.self,
            CharacterLoadout.self,
            InventoryItem.self,
            UnlockEvent.self,
            QuestProgress.self,
            AICoachPreference.self,
            AIInteractionLog.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }

    /// Calendar.current shorthand for tests that need to manipulate dates relative
    /// to "today" without caring about timezone specifics.
    static var calendar: Calendar { Calendar.current }

    /// Returns midnight of N days before today's startOfDay.
    static func daysAgo(_ n: Int) -> Date {
        let today = calendar.startOfDay(for: .now)
        return calendar.date(byAdding: .day, value: -n, to: today)!
    }

    /// Returns a specific time on N days before today (used to test boundary
    /// behavior — e.g. lastCompletedDate set to "yesterday at 9pm").
    static func daysAgo(_ n: Int, atHour hour: Int) -> Date {
        let day = daysAgo(n)
        return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day)!
    }
}
