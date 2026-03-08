import SwiftUI

struct SessionCompletionView: View {
    let sessionType: SessionPhase
    let duration: TimeInterval
    let rewards: RewardCalculation
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
                .accessibilityHidden(true)

            Text("\(sessionType.displayName) Complete!")
                .font(.title2.bold())

            Text("\(Int(duration / 60)) minutes")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if rewards.xp > 0 || rewards.coins > 0 {
                HStack(spacing: 24) {
                    if rewards.xp > 0 {
                        Label("\(rewards.xp) XP", systemImage: "star.fill")
                            .foregroundStyle(.yellow)
                    }
                    if rewards.coins > 0 {
                        Label("\(rewards.coins) Coins", systemImage: "circle.fill")
                            .foregroundStyle(.orange)
                    }
                }
                .font(.headline)
            }

            Spacer()

            Button("Continue", action: onDismiss)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
    }
}

#Preview {
    SessionCompletionView(
        sessionType: .focus,
        duration: 1500,
        rewards: RewardCalculation(xp: 25, coins: 25),
        onDismiss: {}
    )
}
