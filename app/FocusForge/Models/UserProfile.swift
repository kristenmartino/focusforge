import Foundation
import SwiftData

@Model
final class UserProfile {
    var displayName: String
    var hasCompletedOnboarding: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        displayName: String = "",
        hasCompletedOnboarding: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.displayName = displayName
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
