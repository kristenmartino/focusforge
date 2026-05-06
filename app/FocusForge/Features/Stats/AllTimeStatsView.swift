import SwiftUI
import SwiftData

struct AllTimeStatsView: View {
    @Query private var sessions: [SessionLog]
    @Query private var streakStates: [StreakState]

    private var completedFocus: [SessionLog] {
        sessions.filter { $0.sessionType == .focus && $0.outcome == .completed }
    }

    private var streak: StreakState? { streakStates.first }

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: FFTheme.Spacing.sm) {
                StatCardView(
                    title: "Total Sessions",
                    value: "\(completedFocus.count)",
                    icon: "checkmark.circle.fill",
                    color: FFTheme.Accent.green
                )
                StatCardView(
                    title: "Total Minutes",
                    value: "\(completedFocus.reduce(0) { $0 + $1.actualDurationSeconds } / 60)",
                    icon: "clock.fill",
                    color: FFTheme.Accent.blue
                )
                StatCardView(
                    title: "Longest Streak",
                    value: "\(streak?.longestStreakDays ?? 0) days",
                    icon: "flame.fill",
                    color: FFTheme.Accent.orange
                )
                StatCardView(
                    title: "Level",
                    value: "\(streak?.currentLevel ?? 1)",
                    icon: "arrow.up.circle.fill",
                    color: FFTheme.Accent.cyan
                )
                StatCardView(
                    title: "Total XP",
                    value: "\(streak?.totalXP ?? 0)",
                    icon: "star.fill",
                    color: FFTheme.Accent.gold
                )
                StatCardView(
                    title: "Total Coins",
                    value: "\(streak?.totalCoins ?? 0)",
                    icon: "circle.fill",
                    color: FFTheme.Accent.orange
                )
            }
            .padding()
        }
    }
}
