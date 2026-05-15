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
                    // Subtle rarity-tinted row backgrounds for depth (P2-14).
                    // Common keeps the neutral white-overlay; Rare and Animated
                    // Rare get a faint rarity-color wash so the list reads as a
                    // ladder of tiers rather than five identical rows.
                    .listRowBackground(
                        milestone.itemRarity == .common
                            ? Color.white.opacity(0.04)
                            : milestone.itemRarity.color.opacity(0.06)
                    )
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
                    // Clamp tiny progress to a minimum visible 8% so users with
                    // 1 of 7 days don't see an empty bar — mirrors P1-13 fix
                    // on QuestRowView (P2-13).
                    let actual = min(currentStreak, milestone.streakDay)
                    let fraction = Double(actual) / Double(milestone.streakDay)
                    let visualFraction = actual > 0 ? max(0.08, fraction) : 0
                    ProgressView(value: visualFraction, total: 1.0)
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
