import Foundation
import SwiftData

enum PresetManager {
    static func ensureDefaultPreset(in context: ModelContext) {
        let descriptor = FetchDescriptor<TimerPreset>(
            predicate: #Predicate { $0.isDefault == true }
        )
        let existing = (try? context.fetch(descriptor)) ?? []
        if existing.isEmpty {
            context.insert(TimerPreset())
            try? context.save()
        }
    }

    static func clampFocusMinutes(_ value: Int) -> Int {
        max(1, min(120, value))
    }

    static func clampBreakMinutes(_ value: Int) -> Int {
        max(1, min(30, value))
    }

    static func clampSessionsBeforeLongBreak(_ value: Int) -> Int {
        max(1, min(10, value))
    }
}
