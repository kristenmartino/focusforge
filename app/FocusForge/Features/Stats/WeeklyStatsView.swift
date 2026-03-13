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
        ScrollView {
            VStack(spacing: 20) {
                Chart(last7Days) { day in
                    BarMark(
                        x: .value("Day", day.dayLabel),
                        y: .value("Minutes", day.minutes)
                    )
                    .foregroundStyle(.blue.gradient)
                    .cornerRadius(4)
                }
                .chartYAxisLabel("Minutes")
                .frame(height: 220)
                .padding()

                let totalMinutes = last7Days.reduce(0) { $0 + $1.minutes }
                let avgMinutes = last7Days.isEmpty ? 0 : totalMinutes / last7Days.count

                HStack(spacing: 32) {
                    VStack {
                        Text("\(totalMinutes)")
                            .font(.title2.bold())
                        Text("Total min")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    VStack {
                        Text("\(avgMinutes)")
                            .font(.title2.bold())
                        Text("Daily avg")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
