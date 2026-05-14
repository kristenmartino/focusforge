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
                StatCardView(
                    title: "XP Earned",
                    value: "\(todayCompleted.reduce(0) { $0 + $1.xpEarned })",
                    icon: "star.fill",
                    color: FFTheme.Accent.gold
                )
                StatCardView(
                    title: "Coins Earned",
                    value: "\(todayCompleted.reduce(0) { $0 + $1.coinsEarned })",
                    icon: "circle.fill",
                    color: FFTheme.Accent.orange
                )
            }
            .padding()
        }
    }
}
