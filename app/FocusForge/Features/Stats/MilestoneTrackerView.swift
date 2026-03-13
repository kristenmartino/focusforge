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
        List {
            ForEach(MilestoneEngine.milestones, id: \.milestoneID) { milestone in
                MilestoneRowView(
                    milestone: milestone,
                    currentStreak: currentStreak,
                    isEarned: isEarned(milestone)
                )
            }
        }
        .navigationTitle("Milestones")
    }
}

struct MilestoneRowView: View {
    let milestone: MilestoneReward
    let currentStreak: Int
    let isEarned: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isEarned ? "trophy.fill" : "trophy")
                .font(.title2)
                .foregroundStyle(isEarned ? rarityColor : .gray)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(milestone.name)
                        .font(.body.bold())
                    if isEarned {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }

                Text("\(milestone.streakDay)-day streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !isEarned {
                    ProgressView(
                        value: Double(min(currentStreak, milestone.streakDay)),
                        total: Double(milestone.streakDay)
                    )
                    .tint(rarityColor)
                }

                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        Image(systemName: slotIcon)
                        Text(milestone.itemName)
                    }
                    .font(.caption)

                    Text(milestone.itemRarity.rawValue.capitalized)
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(rarityColor.opacity(0.2), in: Capsule())
                        .foregroundStyle(rarityColor)
                }
            }
        }
        .padding(.vertical, 4)
        .opacity(isEarned ? 1.0 : 0.75)
    }

    private var rarityColor: Color {
        switch milestone.itemRarity {
        case .common: .gray
        case .rare: .purple
        case .animatedRare: .orange
        }
    }

    private var slotIcon: String {
        switch milestone.itemSlot {
        case .horns: "crown.fill"
        case .wings: "wind"
        case .weapon: "shield.fill"
        }
    }
}
