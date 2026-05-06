import SwiftUI

struct MilestoneUnlockView: View {
    let milestone: MilestoneReward
    let onClaim: () -> Void

    @State private var showContent = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            RewardBackground()

            if showContent {
                ParticleField(count: 18)
                    .transition(.opacity)
                    .accessibilityHidden(true)
            }

            VStack(spacing: FFTheme.Spacing.lg) {
                Spacer()

                if showContent {
                    // Trophy icon
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(rarityColor)
                        .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                        .accessibilityHidden(true)

                    Text("Milestone Unlocked!")
                        .font(.rewardHeadline)
                        .foregroundStyle(FFTheme.Text.primary)
                        .transition(.opacity)

                    Text(milestone.name)
                        .font(.body)
                        .foregroundStyle(FFTheme.Text.secondary)
                        .transition(.opacity)

                    // Item card
                    FrostedCard {
                        VStack(spacing: FFTheme.Spacing.sm) {
                            HStack(spacing: FFTheme.Spacing.sm) {
                                Image(systemName: slotIcon)
                                    .font(.title3)
                                    .foregroundStyle(rarityColor)
                                    .accessibilityHidden(true)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(milestone.itemName)
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(FFTheme.Text.primary)

                                    Text(milestone.itemRarity.rawValue.capitalized)
                                        .font(.caption.weight(.semibold))
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
                                    .font(.caption)
                                    .accessibilityHidden(true)
                                Text("+1 Streak Freeze")
                                    .font(.footnote)
                            }
                            .foregroundStyle(FFTheme.Accent.cyan)
                        }
                    }
                    .animatedRareShimmer(if: milestone.itemRarity == .animatedRare)
                    .padding(.horizontal, FFTheme.Spacing.xxl)
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                    .accessibilityElement(children: .combine)
                }

                Spacer()

                if showContent {
                    AccentPillButton(title: "Claim", action: onClaim, style: .purple)
                        .padding(.horizontal, FFTheme.Spacing.xxxl)
                        .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                        .accessibilityHint("Claims the milestone reward")
                }

                Spacer()
                    .frame(height: FFTheme.Spacing.xxl)
            }
        }
        .task {
            if reduceMotion {
                showContent = true
            } else {
                withAnimation(.easeOut(duration: 0.6)) {
                    showContent = true
                }
            }
        }
        .presentationDetents([.large])
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
