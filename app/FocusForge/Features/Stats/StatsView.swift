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
            ZStack {
                FFTheme.Background.primary.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Dark segmented control
                    darkSegmentedPicker
                        .padding(.horizontal)
                        .padding(.top, FFTheme.Spacing.xs)

                    switch selectedPeriod {
                    case .today:
                        TodayStatsView()
                    case .week:
                        WeeklyStatsView()
                    case .allTime:
                        AllTimeStatsView()
                    }
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        MilestoneTrackerView()
                    } label: {
                        Image(systemName: "trophy")
                            .foregroundStyle(FFTheme.Text.secondary)
                    }
                    .accessibilityLabel("Milestones")
                    .accessibilityHint("Shows your streak milestone progress and rewards")
                }
            }
            .darkNavigationAppearance()
        }
    }

    private var darkSegmentedPicker: some View {
        HStack(spacing: 2) {
            ForEach(StatsPeriod.allCases, id: \.self) { period in
                Button {
                    selectedPeriod = period
                } label: {
                    Text(period.rawValue)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(
                            selectedPeriod == period
                                ? FFTheme.Text.primary
                                : FFTheme.Text.tertiary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .frame(minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: FFTheme.Radius.sm)
                                .fill(
                                    selectedPeriod == period
                                        ? Color.white.opacity(0.08)
                                        : Color.clear
                                )
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(period.rawValue) stats")
                .accessibilityAddTraits(selectedPeriod == period ? .isSelected : [])
            }
        }
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: FFTheme.Radius.sm + 2)
                .fill(Color.white.opacity(0.03))
        )
    }
}

#Preview {
    StatsView()
        .modelContainer(
            for: [SessionLog.self, StreakState.self, UnlockEvent.self],
            inMemory: true
        )
}
