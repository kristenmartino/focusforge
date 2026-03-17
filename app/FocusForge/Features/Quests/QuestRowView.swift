import SwiftUI

struct QuestRowView: View {
    @Bindable var quest: QuestProgress
    let onClaim: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: FFTheme.Spacing.xs) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(FFTheme.Text.primary)
                    Text(quest.questDescription)
                        .font(.caption)
                        .foregroundStyle(FFTheme.Text.tertiary)
                }
                Spacer()

                if quest.isClaimed {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(FFTheme.Accent.green)
                        .font(.title3)
                } else if quest.isCompleted {
                    Button("Claim", action: onClaim)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(FFTheme.Accent.purple)
                        )
                        .buttonStyle(.plain)
                }
            }

            if !quest.isClaimed {
                ProgressView(
                    value: Double(min(quest.currentCount, quest.targetCount)),
                    total: Double(quest.targetCount)
                )
                .tint(quest.isCompleted ? FFTheme.Accent.green : FFTheme.Accent.blue)
            }

            HStack(spacing: FFTheme.Spacing.sm) {
                if quest.rewardXP > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("\(quest.rewardXP) XP")
                            .font(.caption)
                    }
                    .foregroundStyle(FFTheme.Accent.gold)
                }
                if quest.rewardCoins > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 10))
                        Text("\(quest.rewardCoins) Coins")
                            .font(.caption)
                    }
                    .foregroundStyle(FFTheme.Accent.orange)
                }
                Spacer()
                Text("\(min(quest.currentCount, quest.targetCount))/\(quest.targetCount)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(FFTheme.Text.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
