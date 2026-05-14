import SwiftUI

struct QuestRowView: View {
    @Bindable var quest: QuestProgress
    let onClaim: () -> Void

    @State private var showRewardFlyout = false
    @State private var capturedXP: Int = 0
    @State private var capturedCoins: Int = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var progressClamped: Int {
        min(quest.currentCount, quest.targetCount)
    }

    /// Display progress for the bar: clamps tiny progress (1/50 = 2%) to a
    /// minimum visible 8% fill so the bar reads as "started" rather than
    /// "empty". The numeric label still shows the exact count.
    private var visualProgress: Double {
        guard quest.targetCount > 0 else { return 0 }
        let actual = Double(progressClamped) / Double(quest.targetCount)
        if actual <= 0 { return 0 }
        return max(0.08, actual)
    }

    private var stateDescription: String {
        if quest.isClaimed { return "Claimed" }
        if quest.isCompleted { return "Ready to claim" }
        return "In progress"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: FFTheme.Spacing.xs) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.title)
                        .font(.body.weight(.semibold))
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
                        .accessibilityLabel("Claimed")
                } else if quest.isCompleted {
                    Button {
                        capturedXP = quest.rewardXP
                        capturedCoins = quest.rewardCoins
                        if reduceMotion {
                            showRewardFlyout = true
                        } else {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                                showRewardFlyout = true
                            }
                        }
                        onClaim()
                        Task {
                            try? await Task.sleep(for: .seconds(1.4))
                            await MainActor.run {
                                if reduceMotion {
                                    showRewardFlyout = false
                                } else {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        showRewardFlyout = false
                                    }
                                }
                            }
                        }
                    } label: {
                        Text("Claim")
                            .font(.callout.weight(.medium))
                            .foregroundStyle(FFTheme.Text.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .frame(minHeight: 44)
                            .background(Capsule().fill(FFTheme.Accent.purple))
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Claims the reward for this quest")
                }
            }

            if !quest.isClaimed {
                ProgressView(value: visualProgress, total: 1.0)
                    .tint(quest.isCompleted ? FFTheme.Accent.green : FFTheme.Accent.blue)
                    .accessibilityHidden(true)
            }

            HStack(spacing: FFTheme.Spacing.sm) {
                if quest.rewardXP > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .accessibilityHidden(true)
                        Text("\(quest.rewardXP) XP")
                            .font(.caption)
                    }
                    .foregroundStyle(FFTheme.Accent.gold)
                }
                if quest.rewardCoins > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "circle.fill")
                            .font(.caption2)
                            .accessibilityHidden(true)
                        Text("\(quest.rewardCoins) Coins")
                            .font(.caption)
                    }
                    .foregroundStyle(FFTheme.Accent.orange)
                }
                Spacer()
                Text("\(progressClamped)/\(quest.targetCount)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(FFTheme.Text.tertiary)
            }
        }
        .padding(.vertical, 4)
        .overlay(alignment: .center) {
            if showRewardFlyout {
                rewardFlyout
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(quest.title)
        .accessibilityValue(
            "\(stateDescription). Progress: \(progressClamped) of \(quest.targetCount). " +
            "Reward: \(quest.rewardXP) XP, \(quest.rewardCoins) coins."
        )
    }

    /// Brief reward feedback pill that fades in/out after the user taps Claim.
    /// Sits centered over the row so it's visible regardless of whether the
    /// claim button has already been replaced by the checkmark in the re-render.
    private var rewardFlyout: some View {
        HStack(spacing: FFTheme.Spacing.sm) {
            if capturedXP > 0 {
                Label("+\(capturedXP)", systemImage: "star.fill")
                    .foregroundStyle(FFTheme.Accent.gold)
            }
            if capturedCoins > 0 {
                Label("+\(capturedCoins)", systemImage: "circle.fill")
                    .foregroundStyle(FFTheme.Accent.orange)
            }
        }
        .font(.callout.weight(.bold))
        .labelStyle(.titleAndIcon)
        .padding(.horizontal, FFTheme.Spacing.md)
        .padding(.vertical, FFTheme.Spacing.xs)
        .background(
            Capsule()
                .fill(FFTheme.Background.secondary)
                .overlay(
                    Capsule()
                        .stroke(FFTheme.Border.emphasis, lineWidth: 0.5)
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 12, y: 4)
        .transition(
            reduceMotion
                ? .opacity
                : .scale(scale: 0.65).combined(with: .opacity)
        )
    }
}
