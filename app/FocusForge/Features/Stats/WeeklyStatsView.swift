import SwiftUI
import SwiftData
import Charts

struct DailyFocusData: Identifiable {
    let id = UUID()
    let date: Date
    let minutes: Int

    var dayLabel: String {
        date.formatted(.dateTime.weekday(.abbreviated))
    }
}

struct WeeklyStatsView: View {
    @Query private var sessions: [SessionLog]

    private var last7Days: [DailyFocusData] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return (0..<7).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let nextDate = calendar.date(byAdding: .day, value: 1, to: date)!
            let minutes = sessions
                .filter {
                    $0.sessionType == .focus &&
                    $0.outcome == .completed &&
                    $0.startedAt >= date &&
                    $0.startedAt < nextDate
                }
                .reduce(0) { $0 + $1.actualDurationSeconds } / 60
            return DailyFocusData(date: date, minutes: minutes)
        }
    }

    var body: some View {
        let totalMinutes = last7Days.reduce(0) { $0 + $1.minutes }
        let avgMinutes = last7Days.isEmpty ? 0 : totalMinutes / last7Days.count
        // Show "<1" for fractional averages so first-week users with 1m
        // of focus don't see a discouraging "0 daily avg" stat.
        let avgDisplayLabel = (totalMinutes > 0 && avgMinutes == 0) ? "<1" : "\(avgMinutes)"

        return ScrollView {
            VStack(spacing: FFTheme.Spacing.lg) {
                // Empty-state hint for fresh installs — surfaces what the chart
                // will eventually fill with so day-1 users don't see seven empty
                // bars and conclude the chart is broken (P2-15).
                if totalMinutes == 0 {
                    Text("Your weekly focus minutes will plot here as you go.")
                        .font(.footnote)
                        .foregroundStyle(FFTheme.Text.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.top, FFTheme.Spacing.md)
                        .padding(.horizontal, FFTheme.Spacing.lg)
                }
                Chart(last7Days) { day in
                    // Ghost bar for empty days so the chart's structure is
                    // visible even when sparse. Without this, days with zero
                    // minutes render as nothing — the labels imply structure
                    // the bars don't reinforce. Empty bars use a faint blue
                    // at 8% opacity, just enough to read as "placeholder."
                    BarMark(
                        x: .value("Day", day.dayLabel),
                        y: .value("Minutes", day.minutes > 0 ? Double(day.minutes) : 0.5)
                    )
                    .foregroundStyle(
                        day.minutes > 0
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [
                                        FFTheme.Accent.blue,
                                        FFTheme.Accent.blue.opacity(0.6),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            : AnyShapeStyle(FFTheme.Accent.blue.opacity(0.08))
                    )
                    .cornerRadius(4)
                    .accessibilityLabel(day.dayLabel)
                    .accessibilityValue("\(day.minutes) minutes")
                }
                .chartYAxisLabel("Minutes")
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(FFTheme.Text.tertiary)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                            .foregroundStyle(FFTheme.Border.default)
                        AxisValueLabel()
                            .foregroundStyle(FFTheme.Text.tertiary)
                    }
                }
                .frame(height: 220)
                .padding()
                .accessibilityLabel("Last 7 days of focus minutes")
                .accessibilityValue(
                    "Total \(totalMinutes) minutes, daily average \(avgMinutes) minutes"
                )

                HStack(spacing: FFTheme.Spacing.xxxl) {
                    VStack(spacing: 4) {
                        Text("\(totalMinutes)")
                            .font(.statNumber)
                            .foregroundStyle(FFTheme.Text.primary)
                        Text("Total min")
                            .font(.statLabel)
                            .foregroundStyle(FFTheme.Text.tertiary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Total: \(totalMinutes) minutes this week")
                    VStack(spacing: 4) {
                        Text(avgDisplayLabel)
                            .font(.statNumber)
                            .foregroundStyle(FFTheme.Text.primary)
                        Text("Daily avg")
                            .font(.statLabel)
                            .foregroundStyle(FFTheme.Text.tertiary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(avgMinutes == 0 && totalMinutes > 0
                                        ? "Daily average: less than one minute"
                                        : "Daily average: \(avgMinutes) minutes")
                }
            }
        }
    }
}
