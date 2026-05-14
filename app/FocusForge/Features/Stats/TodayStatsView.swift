import SwiftUI
import SwiftData

struct TodayStatsView: View {
    @Query private var sessions: [SessionLog]
    @Query private var streakStates: [StreakState]

    private var todayCompleted: [SessionLog] {
        let todayStart = Calendar.current.startOfDay(for: .now)
        return sessions.filter {
            $0.startedAt >= todayStart &&
            $0.sessionType == .focus &&
            $0.outcome == .completed
        }
    }

    private var avgSessionLabel: String {
        guard !todayCompleted.isEmpty else { return "—" }
        let totalSeconds = todayCompleted.reduce(0) { $0 + $1.actualDurationSeconds }
        let avgMinutes = totalSeconds / 60 / todayCompleted.count
        return "\(avgMinutes)m"
    }

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: FFTheme.Spacing.sm) {
                StatCardView(
                    title: "Sessions",
                    value: "\(todayCompleted.count)",
                    icon: "checkmark.circle.fill",
                    color: FFTheme.Accent.green
                )
                StatCardView(
                    title: "Focus Minutes",
                    value: "\(todayCompleted.reduce(0) { $0 + $1.actualDurationSeconds } / 60)",
                    icon: "clock.fill",
                    color: FFTheme.Accent.blue
                )
                StatCardView(
                    title: "Streak",
                    value: (streakStates.first?.currentStreakDays ?? 0).pluralized("day"),
                    icon: "flame.fill",
                    color: FFTheme.Accent.orange
                )
                // Session-scoped XP/coins ONLY — does not include quest claim rewards.
                // Quest XP/coins flow into StreakState.totalXP/totalCoins, which is
                // what "Total XP" and "Total Coins" surface on the All Time view.
                // The "Session" label makes the distinction explicit so the user
                // doesn't see a mismatch between today's "XP Earned" (1) and the
                // All Time "Total XP" (11) and wonder where the gap came from.
                StatCardView(
                    title: "Session XP",
                    value: "\(todayCompleted.reduce(0) { $0 + $1.xpEarned })",
                    icon: "star.fill",
                    color: FFTheme.Accent.gold
                )
                StatCardView(
                    title: "Session Coins",
                    value: "\(todayCompleted.reduce(0) { $0 + $1.coinsEarned })",
                    icon: "circle.fill",
                    color: FFTheme.Accent.orange
                )
                StatCardView(
                    title: "Avg Session",
                    value: avgSessionLabel,
                    icon: "stopwatch.fill",
                    color: FFTheme.Accent.cyan
                )
            }
            .padding()
        }
    }
}
