import Foundation
import SwiftData

// MARK: - Quest Template

struct QuestTemplate {
    let metricType: QuestMetric
    let titleFormat: String
    let descFormat: String
    let targetRange: ClosedRange<Int>
    let baseCoins: Int
    let baseXP: Int
}

// MARK: - Quest Manager

enum QuestManager {

    // MARK: - Template Catalog

    // Quest descriptions: deliberately don't repeat the title's content
    // (which gave us "Complete 3 focus sessions" / "Finish 3 full focus sessions today")
    // — instead they carry the deadline or motivating angle, so the row reads as
    //   "Complete 3 focus sessions / Resets at midnight" (P2-12)
    static let dailyTemplates: [QuestTemplate] = [
        QuestTemplate(
            metricType: .sessionsCompleted,
            titleFormat: "Complete %d focus sessions",
            descFormat: "Resets at midnight",
            targetRange: 2...4,
            baseCoins: 15, baseXP: 20
        ),
        QuestTemplate(
            metricType: .minutesFocused,
            titleFormat: "Focus for %d minutes",
            descFormat: "Resets at midnight",
            targetRange: 25...60,
            baseCoins: 20, baseXP: 25
        ),
        QuestTemplate(
            metricType: .sessionWithoutCancel,
            titleFormat: "No-quit session",
            descFormat: "Stay through to the end",
            targetRange: 1...1,
            baseCoins: 10, baseXP: 10
        ),
    ]

    static let weeklyTemplates: [QuestTemplate] = [
        QuestTemplate(
            metricType: .sessionsCompleted,
            titleFormat: "Complete %d sessions this week",
            descFormat: "Resets Sunday night",
            targetRange: 10...15,
            baseCoins: 50, baseXP: 75
        ),
        QuestTemplate(
            metricType: .minutesFocused,
            titleFormat: "Focus for %d minutes this week",
            descFormat: "Resets Sunday night",
            targetRange: 120...300,
            baseCoins: 60, baseXP: 80
        ),
        QuestTemplate(
            metricType: .maintainStreak,
            titleFormat: "Maintain your streak",
            descFormat: "Don't break the chain",
            targetRange: 1...1,
            baseCoins: 40, baseXP: 50
        ),
    ]

    // MARK: - Quest Generation

    static func ensureActiveQuests(in context: ModelContext) {
        generateDailyQuestsIfNeeded(in: context)
        generateWeeklyQuestsIfNeeded(in: context)
        expireOldQuests(in: context)
        try? context.save()
    }

    private static func generateDailyQuestsIfNeeded(in context: ModelContext) {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: .now)
        let dailyType = QuestType.daily

        let descriptor = FetchDescriptor<QuestProgress>(
            predicate: #Predicate<QuestProgress> {
                $0.questType == dailyType && $0.createdAt >= todayStart
            }
        )
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        let selected = Array(dailyTemplates.shuffled().prefix(3))
        for (index, template) in selected.enumerated() {
            let target = Int.random(in: template.targetRange)
            let quest = QuestProgress(
                questID: "daily_\(Int(todayStart.timeIntervalSince1970))_\(index)",
                title: String(format: template.titleFormat, target),
                questDescription: String(format: template.descFormat, target),
                questType: .daily,
                metricType: template.metricType,
                targetCount: target,
                rewardCoins: template.baseCoins,
                rewardXP: template.baseXP,
                expiresAt: calendar.date(byAdding: .day, value: 1, to: todayStart)!
            )
            context.insert(quest)
        }
    }

    private static func generateWeeklyQuestsIfNeeded(in context: ModelContext) {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        let weeklyType = QuestType.weekly

        let descriptor = FetchDescriptor<QuestProgress>(
            predicate: #Predicate<QuestProgress> {
                $0.questType == weeklyType && $0.createdAt >= weekStart
            }
        )
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart)!
        let selected = Array(weeklyTemplates.shuffled().prefix(2))
        for (index, template) in selected.enumerated() {
            let target = Int.random(in: template.targetRange)
            let quest = QuestProgress(
                questID: "weekly_\(Int(weekStart.timeIntervalSince1970))_\(index)",
                title: String(format: template.titleFormat, target),
                questDescription: String(format: template.descFormat, target),
                questType: .weekly,
                metricType: template.metricType,
                targetCount: target,
                rewardCoins: template.baseCoins,
                rewardXP: template.baseXP,
                expiresAt: nextWeekStart
            )
            context.insert(quest)
        }
    }

    private static func expireOldQuests(in context: ModelContext) {
        let now = Date.now
        let descriptor = FetchDescriptor<QuestProgress>(
            predicate: #Predicate<QuestProgress> { $0.expiresAt < now && !$0.isClaimed }
        )
        let expired = (try? context.fetch(descriptor)) ?? []
        for quest in expired {
            context.delete(quest)
        }
    }

    // MARK: - Progress Tracking

    static func trackSessionCompletion(
        focusMinutes: Int,
        wasAbandoned: Bool,
        streakDays: Int,
        in context: ModelContext
    ) -> [QuestProgress] {
        let now = Date.now
        let descriptor = FetchDescriptor<QuestProgress>(
            predicate: #Predicate<QuestProgress> {
                !$0.isCompleted && $0.expiresAt > now
            }
        )
        let activeQuests = (try? context.fetch(descriptor)) ?? []
        var newlyCompleted: [QuestProgress] = []

        for quest in activeQuests {
            switch quest.metricType {
            case .sessionsCompleted:
                if !wasAbandoned { quest.currentCount += 1 }
            case .minutesFocused:
                if !wasAbandoned { quest.currentCount += focusMinutes }
            case .sessionWithoutCancel:
                if !wasAbandoned { quest.currentCount += 1 }
            case .maintainStreak:
                if streakDays > 0 { quest.currentCount = 1 }
            }

            if quest.currentCount >= quest.targetCount && !quest.isCompleted {
                quest.isCompleted = true
                newlyCompleted.append(quest)
            }
        }

        return newlyCompleted
    }

    // MARK: - Reward Claiming

    @discardableResult
    static func claimReward(questID: String, in context: ModelContext) -> Bool {
        let targetID = questID
        let descriptor = FetchDescriptor<QuestProgress>(
            predicate: #Predicate<QuestProgress> {
                $0.questID == targetID && $0.isCompleted && !$0.isClaimed
            }
        )
        guard let quest = (try? context.fetch(descriptor))?.first else { return false }

        quest.isClaimed = true
        _ = StreakManager.applyRewards(xp: quest.rewardXP, coins: quest.rewardCoins, in: context)

        if let itemID = quest.rewardItemID {
            let event = UnlockEvent(itemID: itemID, source: .questReward)
            context.insert(event)

            let targetItemID = itemID
            let itemDescriptor = FetchDescriptor<InventoryItem>(
                predicate: #Predicate<InventoryItem> { $0.itemID == targetItemID }
            )
            if let item = (try? context.fetch(itemDescriptor))?.first {
                item.ownership = .new
                item.acquiredAt = .now
            }
        }

        try? context.save()
        return true
    }
}
