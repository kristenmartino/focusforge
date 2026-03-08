import SwiftUI

struct MilestoneUnlockView: View {
    let milestone: MilestoneReward
    let onClaim: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "trophy.fill")
                .font(.system(size: 72))
                .foregroundStyle(rarityColor)
                .accessibilityHidden(true)

            Text("Milestone Unlocked!")
                .font(.title2.bold())

            Text(milestone.name)
                .font(.title3)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: slotIcon)
                    Text(milestone.itemName)
                }
                .font(.headline)

                Text(milestone.itemRarity.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(rarityColor.opacity(0.2), in: Capsule())
                    .foregroundStyle(rarityColor)

                HStack(spacing: 4) {
                    Image(systemName: "snowflake")
                    Text("+1 Streak Freeze")
                }
                .font(.subheadline)
                .foregroundStyle(.cyan)
            }

            Spacer()

            Button("Claim", action: onClaim)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
    }

    private var rarityColor: Color {
        switch milestone.itemRarity {
        case .common: return .gray
        case .rare: return .purple
        case .animatedRare: return .yellow
        }
    }

    private var slotIcon: String {
        switch milestone.itemSlot {
        case .horns: return "crown.fill"
        case .wings: return "wind"
        case .weapon: return "shield.fill"
        }
    }
}

#Preview {
    MilestoneUnlockView(
        milestone: MilestoneReward(
            milestoneID: "streak_3",
            name: "Early Bird",
            streakDay: 3,
            itemID: "horn1",
            itemName: "Imp Points",
            itemSlot: .horns,
            itemRarity: .common,
            freezeGranted: 1
        ),
        onClaim: {}
    )
}
