import Foundation
import SwiftData

enum UnlockSource: String, Codable {
    case streakMilestone
    case questReward
    case coinPurchase
    case levelUp
}

@Model
final class UnlockEvent {
    var itemID: String
    var source: UnlockSource
    var unlockedAt: Date
    var streakDayAtUnlock: Int?

    init(
        itemID: String,
        source: UnlockSource = .streakMilestone,
        unlockedAt: Date = .now,
        streakDayAtUnlock: Int? = nil
    ) {
        self.itemID = itemID
        self.source = source
        self.unlockedAt = unlockedAt
        self.streakDayAtUnlock = streakDayAtUnlock
    }
}
