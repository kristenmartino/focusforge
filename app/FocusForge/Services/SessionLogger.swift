import Foundation
import SwiftData

struct RewardCalculation {
    let xp: Int
    let coins: Int
}

enum SessionLogger {
    static func logCompletion(
        taskName: String,
        sessionType: SessionPhase,
        plannedDuration: TimeInterval,
        startedAt: Date,
        in context: ModelContext
    ) -> RewardCalculation {
        let rewards = calculateRewards(for: sessionType, duration: plannedDuration)

        let log = SessionLog(
            taskName: taskName,
            sessionType: sessionType.toModelType,
            startedAt: startedAt,
            endedAt: .now,
            plannedDurationSeconds: Int(plannedDuration),
            actualDurationSeconds: Int(Date.now.timeIntervalSince(startedAt)),
            outcome: .completed,
            xpEarned: rewards.xp,
            coinsEarned: rewards.coins
        )
        context.insert(log)
        updateStreakState(xp: rewards.xp, coins: rewards.coins, in: context)
        try? context.save()
        return rewards
    }

    static func logAbandonment(
        taskName: String,
        sessionType: SessionPhase,
        plannedDuration: TimeInterval,
        actualDuration: TimeInterval,
        startedAt: Date,
        in context: ModelContext
    ) {
        let log = SessionLog(
            taskName: taskName,
            sessionType: sessionType.toModelType,
            startedAt: startedAt,
            endedAt: .now,
            plannedDurationSeconds: Int(plannedDuration),
            actualDurationSeconds: Int(actualDuration),
            outcome: .abandoned,
            xpEarned: 0,
            coinsEarned: 0
        )
        context.insert(log)
        try? context.save()
    }

    private static func calculateRewards(for type: SessionPhase, duration: TimeInterval) -> RewardCalculation {
        switch type {
        case .focus:
            let minutes = Int(duration / 60)
            return RewardCalculation(xp: minutes, coins: minutes)
        case .shortBreak, .longBreak:
            return RewardCalculation(xp: 0, coins: 0)
        }
    }

    private static func updateStreakState(xp: Int, coins: Int, in context: ModelContext) {
        let descriptor = FetchDescriptor<StreakState>()
        let states = (try? context.fetch(descriptor)) ?? []
        let streakState: StreakState
        if let existing = states.first {
            streakState = existing
        } else {
            streakState = StreakState()
            context.insert(streakState)
        }
        streakState.totalXP += xp
        streakState.totalCoins += coins
    }
}

extension SessionPhase {
    var toModelType: SessionType {
        switch self {
        case .focus: return .focus
        case .shortBreak: return .shortBreak
        case .longBreak: return .longBreak
        }
    }
}
