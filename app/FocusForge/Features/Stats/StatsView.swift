import SwiftUI
import SwiftData

enum StatsPeriod: String, CaseIterable {
    case today = "Today"
    case week = "7-Day"
    case allTime = "All Time"
}

struct StatsView: View {
    @State private var selectedPeriod: StatsPeriod = .today

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(StatsPeriod.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                switch selectedPeriod {
                case .today:
                    TodayStatsView()
                case .week:
                    WeeklyStatsView()
                case .allTime:
                    AllTimeStatsView()
                }
            }
            .navigationTitle("Stats")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        MilestoneTrackerView()
                    } label: {
                        Image(systemName: "trophy")
                    }
                }
            }
        }
    }
}

#Preview {
    StatsView()
        .modelContainer(for: [SessionLog.self, StreakState.self, UnlockEvent.self], inMemory: true)
}
