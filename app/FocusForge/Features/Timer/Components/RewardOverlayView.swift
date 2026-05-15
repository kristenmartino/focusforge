import SwiftUI

/// Full-screen cinematic reward overlay. Replaces the sheet-based SessionCompletionView
/// with an in-place transition that morphs the timer screen into the reward screen.
///
/// Animation sequence:
/// Beat 1 (t=0):     Ring pulse on timer position
/// Beat 2 (t=400ms): Background crossfade focus → reward
/// Beat 3 (t=800ms): Particles + checkmark + headline
/// Beat 4 (t=1200ms): Reward card slides up
/// Beat 5 (t=1600ms): CTA button + number count-up
///
/// Tap anywhere to skip to final state. Respects reduce motion.
struct RewardOverlayView: View {
    let sessionType: SessionPhase
    let duration: TimeInterval
    let result: SessionResult
    let ringSize: CGFloat
    var reflection: ReflectionResult? = nil
    var onReflectionFeedback: ((Bool) -> Void)? = nil
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Cross-view deep link: when the user taps "Claim in the Quests tab",
    /// we write a target here and dismiss; ContentView observes the same key
    /// and switches selectedTab to Quests. (P2-6)
    @AppStorage("pendingDeepLink") private var pendingDeepLink: String = ""

    // Animation phase states
    @State private var showPulse = false
    @State private var showRewardBg = false
    @State private var showContent = false
    @State private var showRewards = false
    @State private var showButton = false
    @State private var startCountUp = false
    @State private var sequenceComplete = false

    var body: some View {
        ZStack {
            // MARK: - Background layers

            // Focus background (fades out)
            FocusBackground(accentColor: FFTheme.sessionColor(for: sessionType))
                .opacity(showRewardBg ? 0 : 1)

            // Reward background (fades in)
            RewardBackground()
                .opacity(showRewardBg ? 1 : 0)

            // Particles
            if showContent {
                ParticleField(count: 16)
                    .transition(reduceMotion ? .opacity : .opacity)
            }

            // MARK: - Ring pulse (beat 1)

            if showPulse && !showContent {
                RingPulseView(
                    color: FFTheme.sessionColor(for: sessionType),
                    ringSize: ringSize
                )
            }

            // MARK: - Reward content

            VStack(spacing: 0) {
                Spacer()

                if showContent {
                    // Checkmark
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(FFTheme.Accent.green)
                        .transition(contentTransition(.scale.combined(with: .opacity)))
                        .padding(.bottom, FFTheme.Spacing.md)
                        .accessibilityHidden(true)

                    // Headline
                    VStack(spacing: 4) {
                        Text("\(sessionType.displayName) Complete!")
                            .font(.rewardHeadline)
                            .foregroundStyle(FFTheme.Text.primary)

                        Text(Int(duration / 60).pluralized("minute"))
                            .font(.rewardSubhead)
                            .foregroundStyle(FFTheme.Text.tertiary)
                    }
                    .transition(contentTransition(.move(edge: .bottom).combined(with: .opacity)))
                    .padding(.bottom, FFTheme.Spacing.lg)
                    .accessibilityElement(children: .combine)

                    // Streak
                    if result.streakDays > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(FFTheme.Accent.orange)
                                .accessibilityHidden(true)
                            Text("\(result.streakDays.pluralized("day")) streak!")
                                .foregroundStyle(FFTheme.Accent.orange)
                        }
                        .font(.subheadline.weight(.semibold))
                        .transition(contentTransition(.opacity))
                        .padding(.bottom, FFTheme.Spacing.xl)
                    }
                }

                // Rewards card
                if showRewards && (result.xp > 0 || result.coins > 0) {
                    rewardsCard
                        .transition(contentTransition(.move(edge: .bottom).combined(with: .opacity)))
                        .padding(.horizontal, FFTheme.Spacing.xxl)
                        .padding(.bottom, FFTheme.Spacing.md)
                }

                // Level up
                if showRewards && result.leveledUp {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundStyle(FFTheme.Accent.cyan)
                            .accessibilityHidden(true)
                        Text("Level Up!")
                            .foregroundStyle(FFTheme.Accent.cyan)
                    }
                    .font(.subheadline.weight(.semibold))
                    .transition(contentTransition(.scale.combined(with: .opacity)))
                    .padding(.bottom, FFTheme.Spacing.sm)
                }

                // Milestone preview
                if showRewards, let milestone = result.newMilestone {
                    milestonePreview(milestone)
                        .transition(contentTransition(.opacity))
                        .padding(.horizontal, FFTheme.Spacing.xxl)
                        .padding(.bottom, FFTheme.Spacing.sm)
                }

                // Quest completions
                if showRewards && !result.completedQuests.isEmpty {
                    questsCompleted
                        .transition(contentTransition(.opacity))
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
                    .transition(contentTransition(.opacity))
                }

                Spacer()

                // CTA button
                if showButton {
                    AccentPillButton(title: "Continue", action: onDismiss, style: .purple)
                        .padding(.horizontal, FFTheme.Spacing.xxxl)
                        .transition(contentTransition(.move(edge: .bottom).combined(with: .opacity)))
                        .accessibilityHint("Dismisses the reward and returns to the timer")
                }

                Spacer()
                    .frame(height: FFTheme.Spacing.xxl)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            skipToEnd()
        }
        .accessibilityAction(named: Text("Skip animation")) {
            skipToEnd()
        }
        .task {
            if reduceMotion {
                runReducedMotionSequence()
            } else {
                await runFullSequence()
            }
        }
    }

    // MARK: - Animation Sequence

    private func runFullSequence() async {
        // Beat 1: Ring pulse
        withAnimation(.easeOut(duration: 0.6)) {
            showPulse = true
        }

        try? await Task.sleep(for: .milliseconds(400))
        guard !sequenceComplete else { return }

        // Beat 2: Background shift
        withAnimation(.easeOut(duration: 0.6)) {
            showRewardBg = true
        }

        try? await Task.sleep(for: .milliseconds(400))
        guard !sequenceComplete else { return }

        // Beat 3: Content (checkmark, headline, streak)
        withAnimation(.spring(duration: 0.5, bounce: 0.15)) {
            showContent = true
        }

        try? await Task.sleep(for: .milliseconds(400))
        guard !sequenceComplete else { return }

        // Beat 4: Rewards card
        withAnimation(.easeOut(duration: 0.4)) {
            showRewards = true
            startCountUp = true
        }

        try? await Task.sleep(for: .milliseconds(400))
        guard !sequenceComplete else { return }

        // Beat 5: CTA button
        withAnimation(.easeOut(duration: 0.3)) {
            showButton = true
        }
        sequenceComplete = true
    }

    private func runReducedMotionSequence() {
        withAnimation(.easeOut(duration: 0.3)) {
            showRewardBg = true
            showContent = true
            showRewards = true
            showButton = true
            startCountUp = true
            sequenceComplete = true
        }
    }

    private func skipToEnd() {
        guard !sequenceComplete else { return }
        sequenceComplete = true
        withAnimation(.easeOut(duration: 0.2)) {
            showPulse = false
            showRewardBg = true
            showContent = true
            showRewards = true
            showButton = true
            startCountUp = true
        }
    }

    /// Returns the appropriate transition based on reduce motion setting.
    private func contentTransition(_ standard: AnyTransition) -> AnyTransition {
        reduceMotion ? .opacity : standard
    }

    // MARK: - Rewards Card

    private var rewardsCard: some View {
        FrostedCard {
            HStack(spacing: FFTheme.Spacing.xs) {
                if result.xp > 0 {
                    rewardPill(
                        target: result.xp,
                        label: "XP",
                        icon: "star.fill",
                        color: FFTheme.Accent.gold
                    )
                }
                if result.coins > 0 {
                    rewardPill(
                        target: result.coins,
                        label: "COINS",
                        icon: "bitcoinsign.circle.fill",
                        color: FFTheme.Accent.orange
                    )
                }
                if result.bonusXP > 0 {
                    rewardPill(
                        target: result.bonusXP,
                        label: "BONUS",
                        icon: "sparkles",
                        color: FFTheme.Accent.gold.opacity(0.7)
                    )
                }
            }
        }
    }

    /// Reward pill with icon-above-number layout. The icon differentiates
    /// XP (star) from Coins (currency disc) from Bonus (sparkles) so the
    /// pills don't all read as "gold-yellow numbers" at small size (P2-5).
    private func rewardPill(target: Int, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color.opacity(0.8))
                .accessibilityHidden(true)
            if startCountUp {
                CountUpText(
                    target: target,
                    duration: 0.8,
                    prefix: "+",
                    font: .body.weight(.medium),
                    color: color
                )
            } else {
                Text("+0")
                    .font(.body.weight(.medium))
                    .foregroundStyle(color)
                    .monospacedDigit()
            }
            Text(label)
                .font(.caption2.weight(.medium))
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
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(milestone.name)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(FFTheme.Text.primary)
                    Text("New item unlocked!")
                        .font(.caption)
                        .foregroundStyle(FFTheme.Text.tertiary)
                }
                Spacer()
            }
        }
        .accessibilityElement(children: .combine)
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
                            .accessibilityHidden(true)
                        Text(quest.title)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(FFTheme.Text.secondary)
                    }
                }
                Button {
                    pendingDeepLink = "quests"
                    onDismiss()
                } label: {
                    HStack(spacing: 4) {
                        Text("Claim in the Quests tab")
                        Image(systemName: "arrow.right")
                    }
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(FFTheme.Accent.blue)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Dismisses the reward and opens the Quests tab")
            }
        }
    }
}

#Preview {
    RewardOverlayView(
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
        ringSize: 260,
        onDismiss: {}
    )
}
