import Foundation
import SwiftData

struct SessionResult {
    let xp: Int
    let coins: Int
    let streakDays: Int
    let bonusXP: Int
    let newMilestone: MilestoneReward?
    let leveledUp: Bool
    let completedQuests: [QuestProgress]
}

enum SessionLogger {
    static func logCompletion(
        taskName: String,
        sessionType: SessionPhase,
        plannedDuration: TimeInterval,
        startedAt: Date,
        in context: ModelContext
    ) -> SessionResult {
        // 1. Update streak (only for focus sessions)
        let streakDays: Int
        if sessionType == .focus {
            streakDays = StreakManager.recordFocusCompletion(in: context)
        } else {
            streakDays = StreakManager.currentStreakDays(in: context)
        }

        // 2. Calculate rewards with streak bonus
        let base = calculateBaseRewards(for: sessionType, duration: plannedDuration)
        let multiplier = StreakManager.streakBonusMultiplier(for: streakDays)
        let bonusXP = sessionType == .focus ? Int(Double(base.xp) * multiplier) - base.xp : 0
        let totalXP = base.xp + bonusXP

        // 3. Log the session
        let log = SessionLog(
            taskName: taskName,
            sessionType: sessionType.toModelType,
            startedAt: startedAt,
            endedAt: .now,
            plannedDurationSeconds: Int(plannedDuration),
            actualDurationSeconds: Int(Date.now.timeIntervalSince(startedAt)),
            outcome: .completed,
            xpEarned: totalXP,
            coinsEarned: base.coins
        )
        context.insert(log)

        // 4. Apply XP/coins and check level-up
        let leveledUp = StreakManager.applyRewards(xp: totalXP, coins: base.coins, in: context)

        // 5. Check milestones
        let milestone = MilestoneEngine.checkMilestone(streakDays: streakDays, in: context)

        // 6. Track quest progress
        let focusMinutes = sessionType == .focus ? Int(plannedDuration / 60) : 0
        let completedQuests = QuestManager.trackSessionCompletion(
            focusMinutes: focusMinutes,
            wasAbandoned: false,
            streakDays: streakDays,
            in: context
        )

        try? context.save()

        return SessionResult(
            xp: totalXP,
            coins: base.coins,
            streakDays: streakDays,
            bonusXP: bonusXP,
            newMilestone: milestone,
            leveledUp: leveledUp,
            completedQuests: completedQuests
        )
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

    private static func calculateBaseRewards(for type: SessionPhase, duration: TimeInterval) -> (xp: Int, coins: Int) {
        switch type {
        case .focus:
            let minutes = Int(duration / 60)
            return (xp: minutes, coins: minutes)
        case .shortBreak, .longBreak:
            return (xp: 0, coins: 0)
        }
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
