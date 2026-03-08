import Foundation
import SwiftData

@Model
final class StreakState {
    var currentStreakDays: Int
    var longestStreakDays: Int
    var lastCompletedDate: Date?
    var freezesAvailable: Int
    var freezesUsed: Int
    var totalXP: Int
    var totalCoins: Int
    var currentLevel: Int
    var streakFreezeLastEarnedDate: Date?

    init(
        currentStreakDays: Int = 0,
        longestStreakDays: Int = 0,
        lastCompletedDate: Date? = nil,
        freezesAvailable: Int = 0,
        freezesUsed: Int = 0,
        totalXP: Int = 0,
        totalCoins: Int = 0,
        currentLevel: Int = 1,
        streakFreezeLastEarnedDate: Date? = nil
    ) {
        self.currentStreakDays = currentStreakDays
        self.longestStreakDays = longestStreakDays
        self.lastCompletedDate = lastCompletedDate
        self.freezesAvailable = freezesAvailable
        self.freezesUsed = freezesUsed
        self.totalXP = totalXP
        self.totalCoins = totalCoins
        self.currentLevel = currentLevel
        self.streakFreezeLastEarnedDate = streakFreezeLastEarnedDate
    }
}
