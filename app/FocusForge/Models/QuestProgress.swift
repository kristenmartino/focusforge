import Foundation
import SwiftData

enum QuestType: String, Codable {
    case daily
    case weekly
}

@Model
final class QuestProgress {
    @Attribute(.unique) var questID: String
    var title: String
    var questDescription: String
    var questType: QuestType
    var targetCount: Int
    var currentCount: Int
    var isCompleted: Bool
    var isClaimed: Bool
    var rewardCoins: Int
    var rewardXP: Int
    var rewardItemID: String?
    var createdAt: Date
    var expiresAt: Date

    init(
        questID: String,
        title: String = "",
        questDescription: String = "",
        questType: QuestType = .daily,
        targetCount: Int = 1,
        currentCount: Int = 0,
        isCompleted: Bool = false,
        isClaimed: Bool = false,
        rewardCoins: Int = 0,
        rewardXP: Int = 0,
        rewardItemID: String? = nil,
        createdAt: Date = .now,
        expiresAt: Date = .now
    ) {
        self.questID = questID
        self.title = title
        self.questDescription = questDescription
        self.questType = questType
        self.targetCount = targetCount
        self.currentCount = currentCount
        self.isCompleted = isCompleted
        self.isClaimed = isClaimed
        self.rewardCoins = rewardCoins
        self.rewardXP = rewardXP
        self.rewardItemID = rewardItemID
        self.createdAt = createdAt
        self.expiresAt = expiresAt
    }
}
