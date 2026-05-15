import Foundation
import SwiftData
import FocusForgeCoachEngine

/// SwiftData-backed builder for a `BehaviorSignal` — fetches the last 7
/// days of focus sessions, then delegates all the actual math to the
/// package's `BehaviorSignalMath` helpers.
///
/// This is the "host adapter" layer between the app's persistence
/// (SwiftData) and the package's pure-Swift math. The package can't
/// fetch sessions from a SwiftData store; this enum can. The package
/// can compute completion rates; this enum delegates to it.
///
/// **Why factor it this way.** Keeps the package Foundation-only and
/// makes both layers independently testable: package tests cover the
/// math (no SwiftData), app tests cover the fetch logic (no engine).
enum BehaviorSignalComputer {

    static func compute(in context: ModelContext) -> BehaviorSignal {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: .now)!
        let focusType = SessionType.focus

        let descriptor = FetchDescriptor<SessionLog>(
            predicate: #Predicate<SessionLog> {
                $0.startedAt >= sevenDaysAgo && $0.sessionType == focusType
            }
        )
        let sessions = (try? context.fetch(descriptor)) ?? []

        let completedOutcome = SessionOutcome.completed
        let completed = sessions.filter { $0.outcome == completedOutcome }
        let abandoned = sessions.filter { $0.outcome != completedOutcome }

        let totalCount = sessions.count
        let completionRate = BehaviorSignalMath.completionRate(
            completed: completed.count,
            total: totalCount
        )
        let abandonRate = BehaviorSignalMath.abandonRate(
            abandoned: abandoned.count,
            total: totalCount
        )

        let totalFocusSeconds = completed.reduce(0) { $0 + $1.actualDurationSeconds }
        let avgFocusMinutes = BehaviorSignalMath.avgActualFocusMinutes(
            totalCompletedSeconds: totalFocusSeconds,
            completedCount: completed.count
        )

        let streakState = StreakManager.fetchOrCreateStreakState(in: context)
        let riskScore = BehaviorSignalMath.streakRiskScore(
            currentStreakDays: streakState.currentStreakDays,
            lastCompletedDate: streakState.lastCompletedDate,
            freezesAvailable: streakState.freezesAvailable,
            now: .now,
            calendar: calendar
        )

        let keywords = BehaviorSignalMath.extractKeywords(
            from: sessions.map(\.taskName)
        )

        return BehaviorSignal(
            completionRate7d: completionRate,
            abandonRate7d: abandonRate,
            avgActualFocusMinutes: avgFocusMinutes,
            streakRiskScore: riskScore,
            totalSessions7d: totalCount,
            dominantTaskKeywords: keywords
        )
    }
}
