import Foundation
import SwiftData

enum AICoachPreferenceManager {

    @discardableResult
    static func fetchOrCreate(in context: ModelContext) -> AICoachPreference {
        let descriptor = FetchDescriptor<AICoachPreference>()
        let existing = (try? context.fetch(descriptor)) ?? []
        if let preference = existing.first {
            return preference
        }
        let preference = AICoachPreference()
        context.insert(preference)
        try? context.save()
        return preference
    }
}
