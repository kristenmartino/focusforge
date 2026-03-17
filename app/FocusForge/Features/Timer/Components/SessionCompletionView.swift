import SwiftUI

struct SessionCompletionView: View {
    let sessionType: SessionPhase
    let duration: TimeInterval
    let result: SessionResult
    var reflection: ReflectionResult? = nil
    var onReflectionFeedback: ((Bool) -> Void)? = nil
    let onDismiss: () -> Void

    @State private var showContent = false
    @State private var showRewards = false
    @State private var showButton = false

    var body: some View {
        ZStack {
            // Atmospheric reward background
            RewardBackground()

            // Particle field
            if showContent {
                ParticleField(count: 14)
                    .transition(.opacity)
            }

            VStack(spacing: 0) {
                Spacer()

                // Completion icon
                if showContent {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(FFTheme.Accent.green)
                        .transition(.scale.combined(with: .opacity))
                        .padding(.bottom, FFTheme.Spacing.md)
                }

                // Headline
                if showContent {
                    VStack(spacing: 4) {
                        Text("\(sessionType.displayName) Complete!")
                            .font(.rewardHeadline)
                            .foregroundStyle(FFTheme.Text.primary)

                        Text("\(Int(duration / 60)) minutes")
                            .font(.rewardSubhead)
                            .foregroundStyle(FFTheme.Text.tertiary)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, FFTheme.Spacing.lg)
                }

                // Streak callout
                if showContent && result.streakDays > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(FFTheme.Accent.orange)
                        Text("Day \(result.streakDays) streak!")
                            .foregroundStyle(FFTheme.Accent.orange)
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.bottom, FFTheme.Spacing.xl)
                    .transition(.opacity)
                }

                // Rewards card
                if showRewards && (result.xp > 0 || result.coins > 0) {
                    rewardsCard
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, FFTheme.Spacing.xxl)
                        .padding(.bottom, FFTheme.Spacing.md)
                }

                // Level up
                if showRewards && result.leveledUp {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundStyle(FFTheme.Accent.cyan)
                        Text("Level Up!")
                            .foregroundStyle(FFTheme.Accent.cyan)
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .transition(.scale.combined(with: .opacity))
                    .padding(.bottom, FFTheme.Spacing.sm)
                }

                // Milestone preview
                if showRewards, let milestone = result.newMilestone {
                    milestonePreview(milestone)
                        .transition(.opacity)
                        .padding(.horizontal, FFTheme.Spacing.xxl)
                        .padding(.bottom, FFTheme.Spacing.sm)
                }

                // Quest completions
                if showRewards && !result.completedQuests.isEmpty {
                    questsCompleted
                        .transition(.opacity)
                        .padding(.horizontal, FFTheme.Spacing.xxl)
                        .padding(.bottom, FFTheme.Spacing.sm)
                }

                // AI Coach reflection
                if showRewards, let reflection {
                    PostReflectionCardView(
                        reflection: reflection,
                        onFeedback: { accepted in
                            onReflectionFeedback?(accepted)
                        }
                    )
                    .padding(.horizontal, FFTheme.Spacing.xxl)
                    .padding(.bottom, FFTheme.Spacing.sm)
                    .transition(.opacity)
                }

                Spacer()

                // CTA
                if showButton {
                    AccentPillButton(title: "Continue", action: onDismiss, style: .purple)
                        .padding(.horizontal, FFTheme.Spacing.xxxl)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer()
                    .frame(height: FFTheme.Spacing.xxl)
            }
        }
        .task {
            // Cinematic reveal sequence
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
            try? await Task.sleep(for: .milliseconds(400))
            withAnimation(.easeOut(duration: 0.4)) {
                showRewards = true
            }
            try? await Task.sleep(for: .milliseconds(300))
            withAnimation(.easeOut(duration: 0.3)) {
                showButton = true
            }
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled()
    }

    // MARK: - Rewards Card

    private var rewardsCard: some View {
        FrostedCard {
            HStack(spacing: FFTheme.Spacing.xs) {
                if result.xp > 0 {
                    rewardPill(
                        value: "+\(result.xp)",
                        label: "XP",
                        color: FFTheme.Accent.gold
                    )
                }
                if result.coins > 0 {
                    rewardPill(
                        value: "+\(result.coins)",
                        label: "COINS",
                        color: FFTheme.Accent.orange
                    )
                }
                if result.bonusXP > 0 {
                    rewardPill(
                        value: "+\(result.bonusXP)",
                        label: "BONUS",
                        color: FFTheme.Accent.gold.opacity(0.7)
                    )
                }
            }
        }
    }

    private func rewardPill(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(color.opacity(0.5))
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, FFTheme.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: FFTheme.Radius.sm)
                .fill(color.opacity(0.06))
        )
    }

    // MARK: - Milestone Preview

    private func milestonePreview(_ milestone: MilestoneReward) -> some View {
        FrostedCard {
            HStack(spacing: FFTheme.Spacing.sm) {
                Image(systemName: "trophy.fill")
                    .font(.title3)
                    .foregroundStyle(FFTheme.Accent.purple)

                VStack(alignment: .leading, spacing: 2) {
                    Text(milestone.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(FFTheme.Text.primary)
                    Text("New item unlocked!")
                        .font(.system(size: 11))
                        .foregroundStyle(FFTheme.Text.tertiary)
                }

                Spacer()
            }
        }
    }

    // MARK: - Quest Completions

    private var questsCompleted: some View {
        FrostedCard {
            VStack(alignment: .leading, spacing: FFTheme.Spacing.xs) {
                ForEach(result.completedQuests, id: \.questID) { quest in
                    HStack(spacing: FFTheme.Spacing.xs) {
                        Image(systemName: "scroll.fill")
                            .font(.caption)
                            .foregroundStyle(FFTheme.Accent.cyan)
                        Text(quest.title)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(FFTheme.Text.secondary)
                    }
                }
                Text("Claim in the Quests tab")
                    .font(.system(size: 10))
                    .foregroundStyle(FFTheme.Text.tertiary)
            }
        }
    }
}

#Preview {
    SessionCompletionView(
        sessionType: .focus,
        duration: 1500,
        result: SessionResult(
            xp: 30,
            coins: 25,
            streakDays: 7,
            bonusXP: 5,
            newMilestone: nil,
            leveledUp: false,
            completedQuests: []
        ),
        onDismiss: {}
    )
}
