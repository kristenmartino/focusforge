import SwiftUI

struct QuestRowView: View {
    @Bindable var quest: QuestProgress
    let onClaim: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.title)
                        .font(.body.bold())
                    Text(quest.questDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()

                if quest.isClaimed {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                } else if quest.isCompleted {
                    Button("Claim", action: onClaim)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                }
            }

            if !quest.isClaimed {
                ProgressView(
                    value: Double(min(quest.currentCount, quest.targetCount)),
                    total: Double(quest.targetCount)
                )
                .tint(quest.isCompleted ? .green : .accentColor)
            }

            HStack(spacing: 12) {
                if quest.rewardXP > 0 {
                    Label("\(quest.rewardXP) XP", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
                if quest.rewardCoins > 0 {
                    Label("\(quest.rewardCoins) Coins", systemImage: "circle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                Spacer()
                Text("\(min(quest.currentCount, quest.targetCount))/\(quest.targetCount)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
