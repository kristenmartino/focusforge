import SwiftUI
import SwiftData

struct MilestoneTrackerView: View {
    @Query private var streakStates: [StreakState]
    @Query private var unlockEvents: [UnlockEvent]

    private var currentStreak: Int { streakStates.first?.currentStreakDays ?? 0 }

    private func isEarned(_ milestone: MilestoneReward) -> Bool {
        unlockEvents.contains { $0.itemID == milestone.itemID }
    }

    var body: some View {
        ZStack {
            FFTheme.Background.primary.ignoresSafeArea()

            List {
                ForEach(MilestoneEngine.milestones, id: \.milestoneID) { milestone in
                    MilestoneRowView(
                        milestone: milestone,
                        currentStreak: currentStreak,
                        isEarned: isEarned(milestone)
                    )
                    .listRowBackground(Color.white.opacity(0.04))
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Milestones")
        .darkNavigationAppearance()
    }
}

struct MilestoneRowView: View {
    let milestone: MilestoneReward
    let currentStreak: Int
    let isEarned: Bool

    var body: some View {
        HStack(spacing: FFTheme.Spacing.sm) {
            // Trophy icon
            Image(systemName: isEarned ? "trophy.fill" : "trophy")
                .font(.title2)
                .foregroundStyle(isEarned ? rarityColor : FFTheme.Text.tertiary)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(milestone.name)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(FFTheme.Text.primary)
                    if isEarned {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(FFTheme.Accent.green)
                            .accessibilityLabel("Earned")
                    }
                }

                Text("\(milestone.streakDay)-day streak")
                    .font(.caption)
                    .foregroundStyle(FFTheme.Text.tertiary)

                if !isEarned {
                    ProgressView(
                        value: Double(min(currentStreak, milestone.streakDay)),
                        total: Double(milestone.streakDay)
                    )
                    .tint(rarityColor)
                }

                HStack(spacing: FFTheme.Spacing.xs) {
                    HStack(spacing: 2) {
                        Image(systemName: slotIcon)
                            .font(.caption2)
                            .accessibilityHidden(true)
                        Text(milestone.itemName)
                            .font(.caption)
                    }
                    .foregroundStyle(FFTheme.Text.secondary)

                    Text(milestone.itemRarity.displayName)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(rarityColor.opacity(0.12))
                        )
                        .foregroundStyle(rarityColor)
                }
            }
        }
        .padding(.vertical, 4)
        .opacity(isEarned ? 1.0 : 0.75)
    }

    private var rarityColor: Color { milestone.itemRarity.color }

    private var slotIcon: String {
        switch milestone.itemSlot {
        case .horns: "crown.fill"
        case .wings: "wind"
        case .weapon: "shield.fill"
        }
    }
}
