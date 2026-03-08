import Foundation
import SwiftData

enum StreakManager {
    /// Updates streak state after a focus session completion.
    /// Returns the updated streak day count.
    @discardableResult
    static func recordFocusCompletion(in context: ModelContext) -> Int {
        let streakState = fetchOrCreateStreakState(in: context)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        if let lastDate = streakState.lastCompletedDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysBetween = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysBetween == 0 {
                // Same calendar day — already counted
                return streakState.currentStreakDays
            } else if daysBetween == 1 {
                // Yesterday — extend streak
                streakState.currentStreakDays += 1
            } else if daysBetween >= 2 && streakState.freezesAvailable > 0 {
                // Missed day(s) but have freeze — consume one, keep streak
                streakState.freezesAvailable -= 1
                streakState.freezesUsed += 1
                streakState.currentStreakDays += 1
            } else {
                // Streak broken — reset
                streakState.currentStreakDays = 1
            }
        } else {
            // First ever session
            streakState.currentStreakDays = 1
        }

        streakState.lastCompletedDate = .now
        streakState.longestStreakDays = max(streakState.longestStreakDays, streakState.currentStreakDays)

        return streakState.currentStreakDays
    }

    /// Calculates the streak bonus XP multiplier.
    /// +10% per streak day, capped at +50% (5+ day streak).
    static func streakBonusMultiplier(for streakDays: Int) -> Double {
        let bonus = min(Double(streakDays) * 0.10, 0.50)
        return 1.0 + bonus
    }

    /// Applies XP and coins to the streak state, handles level-up.
    /// Returns whether a level-up occurred.
    static func applyRewards(xp: Int, coins: Int, in context: ModelContext) -> Bool {
        let streakState = fetchOrCreateStreakState(in: context)
        let previousLevel = streakState.currentLevel
        streakState.totalXP += xp
        streakState.totalCoins += coins
        // Level up every 100 XP
        streakState.currentLevel = max(1, (streakState.totalXP / 100) + 1)
        return streakState.currentLevel > previousLevel
    }

    /// Fetches current streak day count without modifying state.
    static func currentStreakDays(in context: ModelContext) -> Int {
        fetchOrCreateStreakState(in: context).currentStreakDays
    }

    /// Fetches the current streak state (read-only access).
    static func fetchOrCreateStreakState(in context: ModelContext) -> StreakState {
        let descriptor = FetchDescriptor<StreakState>()
        let states = (try? context.fetch(descriptor)) ?? []
        if let existing = states.first {
            return existing
        }
        let newState = StreakState()
        context.insert(newState)
        return newState
    }
}
