import Foundation
import SwiftData

@Model
final class UserProfile {
    var displayName: String
    var hasCompletedOnboarding: Bool
    var selectedCharacterID: String
    var notificationPermissionRequested: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        displayName: String = "",
        hasCompletedOnboarding: Bool = false,
        selectedCharacterID: String = "",
        notificationPermissionRequested: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.displayName = displayName
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.selectedCharacterID = selectedCharacterID
        self.notificationPermissionRequested = notificationPermissionRequested
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
