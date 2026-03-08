import Foundation
import SwiftData

struct MilestoneReward {
    let milestoneID: String
    let name: String
    let streakDay: Int
    let itemID: String
    let itemName: String
    let itemSlot: ItemSlot
    let itemRarity: ItemRarity
    let freezeGranted: Int
}

enum MilestoneEngine {
    static let milestones: [MilestoneReward] = [
        MilestoneReward(
            milestoneID: "streak_3",
            name: "Early Bird",
            streakDay: 3,
            itemID: "milestone_early_bird",
            itemName: "Early Bird Badge",
            itemSlot: .accessory,
            itemRarity: .common,
            freezeGranted: 1
        ),
        MilestoneReward(
            milestoneID: "streak_7",
            name: "Week Warrior",
            streakDay: 7,
            itemID: "milestone_week_warrior",
            itemName: "Warrior Helm",
            itemSlot: .head,
            itemRarity: .common,
            freezeGranted: 1
        ),
        MilestoneReward(
            milestoneID: "streak_14",
            name: "Fortnight",
            streakDay: 14,
            itemID: "milestone_fortnight",
            itemName: "Fortnight Scarf",
            itemSlot: .accessory,
            itemRarity: .rare,
            freezeGranted: 1
        ),
        MilestoneReward(
            milestoneID: "streak_30",
            name: "Monthly Master",
            streakDay: 30,
            itemID: "milestone_monthly_master",
            itemName: "Master Crown",
            itemSlot: .head,
            itemRarity: .rare,
            freezeGranted: 1
        ),
        MilestoneReward(
            milestoneID: "streak_60",
            name: "Iron Will",
            streakDay: 60,
            itemID: "milestone_iron_will",
            itemName: "Iron Will Aura",
            itemSlot: .accessory,
            itemRarity: .animatedRare,
            freezeGranted: 1
        ),
    ]

    /// Checks if the given streak day count has earned a new milestone.
    /// Returns the milestone if newly earned, nil otherwise.
    static func checkMilestone(streakDays: Int, in context: ModelContext) -> MilestoneReward? {
        // Find the highest milestone that matches current streak
        guard let milestone = milestones.last(where: { $0.streakDay <= streakDays }) else {
            return nil
        }

        // Check if already earned
        let milestoneItemID = milestone.itemID
        let descriptor = FetchDescriptor<UnlockEvent>(
            predicate: #Predicate { $0.itemID == milestoneItemID }
        )
        let existing = (try? context.fetch(descriptor)) ?? []
        if !existing.isEmpty {
            return nil
        }

        // Grant the milestone
        grantMilestone(milestone, streakDays: streakDays, in: context)
        return milestone
    }

    private static func grantMilestone(_ milestone: MilestoneReward, streakDays: Int, in context: ModelContext) {
        // Create unlock event
        let event = UnlockEvent(
            itemID: milestone.itemID,
            source: .streakMilestone,
            streakDayAtUnlock: streakDays
        )
        context.insert(event)

        // Create or update inventory item
        let itemID = milestone.itemID
        let itemDescriptor = FetchDescriptor<InventoryItem>(
            predicate: #Predicate { $0.itemID == itemID }
        )
        let existingItems = (try? context.fetch(itemDescriptor)) ?? []

        if let item = existingItems.first {
            item.ownership = .new
            item.acquiredAt = .now
        } else {
            let item = InventoryItem(
                itemID: milestone.itemID,
                name: milestone.itemName,
                slot: milestone.itemSlot,
                rarity: milestone.itemRarity,
                ownership: .new,
                coinCost: 0,
                acquiredAt: .now
            )
            context.insert(item)
        }

        // Grant streak freeze
        if milestone.freezeGranted > 0 {
            let streakState = StreakManager.fetchOrCreateStreakState(in: context)
            streakState.freezesAvailable += milestone.freezeGranted
            streakState.streakFreezeLastEarnedDate = .now
        }
    }
}
