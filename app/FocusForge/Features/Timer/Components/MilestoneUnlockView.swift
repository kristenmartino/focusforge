import SwiftUI

struct MilestoneUnlockView: View {
    let milestone: MilestoneReward
    let onClaim: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            RewardBackground()

            if showContent {
                ParticleField(count: 18)
                    .transition(.opacity)
            }

            VStack(spacing: FFTheme.Spacing.lg) {
                Spacer()

                if showContent {
                    // Trophy icon
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(rarityColor)
                        .transition(.scale.combined(with: .opacity))

                    Text("Milestone Unlocked!")
                        .font(.rewardHeadline)
                        .foregroundStyle(FFTheme.Text.primary)
                        .transition(.opacity)

                    Text(milestone.name)
                        .font(.system(size: 17))
                        .foregroundStyle(FFTheme.Text.secondary)
                        .transition(.opacity)

                    // Item card
                    FrostedCard {
                        VStack(spacing: FFTheme.Spacing.sm) {
                            HStack(spacing: FFTheme.Spacing.sm) {
                                Image(systemName: slotIcon)
                                    .font(.title3)
                                    .foregroundStyle(rarityColor)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(milestone.itemName)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(FFTheme.Text.primary)

                                    Text(milestone.itemRarity.rawValue.capitalized)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(rarityColor)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(
                                            Capsule()
                                                .fill(rarityColor.opacity(0.12))
                                        )
                                }
                                Spacer()
                            }

                            // Streak freeze bonus
                            HStack(spacing: 4) {
                                Image(systemName: "snowflake")
                                    .font(.system(size: 12))
                                Text("+1 Streak Freeze")
                                    .font(.system(size: 13))
                            }
                            .foregroundStyle(FFTheme.Accent.cyan)
                        }
                    }
                    .padding(.horizontal, FFTheme.Spacing.xxl)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()

                if showContent {
                    AccentPillButton(title: "Claim", action: onClaim, style: .purple)
                        .padding(.horizontal, FFTheme.Spacing.xxxl)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()
                    .frame(height: FFTheme.Spacing.xxl)
            }
        }
        .task {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
        .presentationDetents([.large])
    }

    private var rarityColor: Color {
        switch milestone.itemRarity {
        case .common: FFTheme.Rarity.common
        case .rare: FFTheme.Rarity.rare
        case .animatedRare: FFTheme.Accent.gold
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

#Preview {
    MilestoneUnlockView(
        milestone: MilestoneReward(
            milestoneID: "streak_7",
            name: "Week Warrior",
            streakDay: 7,
            itemID: "weaponR1",
            itemName: "Pea Shooter",
            itemSlot: .weapon,
            itemRarity: .common,
            freezeGranted: 1
        ),
        onClaim: {}
    )
}
