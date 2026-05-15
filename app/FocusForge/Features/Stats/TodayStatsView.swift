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
            // Empty-state callout when there's been no focus today. Without
            // this, the user sees six "0" cards and the screen reads as a
            // dashboard with no story. The callout addresses the user
            // directly — "your character is waiting" — and lets the screen
            // pivot from "nothing happened" to "something is supposed to."
            if todayCompleted.isEmpty {
                emptyStateBanner
                    .padding(.horizontal, FFTheme.Spacing.md)
                    .padding(.top, FFTheme.Spacing.md)
                    .padding(.bottom, FFTheme.Spacing.xs)
            }

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
                    icon: "bitcoinsign.circle.fill",
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

    /// Empty state shown above the zero-stat grid when no focus session has
    /// completed today. Uses the locked character framing — "your character
    /// is waiting" — to keep the tone consistent with the rest of the app.
    private var emptyStateBanner: some View {
        HStack(spacing: FFTheme.Spacing.sm) {
            Image(systemName: "moon.stars.fill")
                .font(.title3)
                .foregroundStyle(FFTheme.Accent.purple)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("No focus yet today")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FFTheme.Text.primary)
                Text("Your character is waiting.")
                    .font(.footnote)
                    .foregroundStyle(FFTheme.Text.secondary)
            }

            Spacer()
        }
        .padding(FFTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: FFTheme.Radius.md)
                .fill(FFTheme.Accent.purple.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: FFTheme.Radius.md)
                        .stroke(FFTheme.Accent.purple.opacity(0.15), lineWidth: 0.5)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No focus yet today. Your character is waiting.")
    }
}
