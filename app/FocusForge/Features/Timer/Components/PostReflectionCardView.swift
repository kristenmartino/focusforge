import SwiftUI
import FocusForgeCoachEngine

/// Post-session reflection tip. Rendered inline inside `RewardOverlayView`
/// (beat 4-5) so this view is the content, not its own scene — the
/// surrounding reward atmosphere provides the background and energy.
///
/// Layout: a subtle frosted-glass card with the category icon, the tip
/// text, and Helpful / Not helpful feedback buttons that disappear after
/// the user taps either.
struct PostReflectionCardView: View {
    let reflection: ReflectionResult
    let onFeedback: (Bool) -> Void

    @State private var feedbackGiven = false

    var body: some View {
        FrostedCard {
            VStack(alignment: .leading, spacing: FFTheme.Spacing.sm) {
                HStack(alignment: .top, spacing: FFTheme.Spacing.sm) {
                    Image(systemName: categoryIcon)
                        .font(.subheadline)
                        .foregroundStyle(FFTheme.Accent.cyan)
                        .frame(width: 22, alignment: .center)
                        .accessibilityHidden(true)
                    Text(reflection.tipText)
                        .font(.subheadline)
                        .foregroundStyle(FFTheme.Text.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .onAppear {
                    AnalyticsService.track(.aiPromptShown, parameters: [
                        "kind": "reflection",
                        "category": reflection.category.rawValue
                    ])
                }

                if !feedbackGiven {
                    HStack(spacing: FFTheme.Spacing.sm) {
                        feedbackButton(
                            label: "Helpful",
                            icon: "hand.thumbsup",
                            tint: FFTheme.Accent.green
                        ) {
                            feedbackGiven = true
                            AnalyticsService.track(.aiRecommendationFollowed, parameters: [
                                "kind": "reflection",
                                "category": reflection.category.rawValue
                            ])
                            onFeedback(true)
                        }

                        feedbackButton(
                            label: "Not helpful",
                            icon: "hand.thumbsdown",
                            tint: FFTheme.Text.tertiary
                        ) {
                            feedbackGiven = true
                            AnalyticsService.track(.aiSuggestionDismissed, parameters: [
                                "kind": "reflection",
                                "category": reflection.category.rawValue
                            ])
                            onFeedback(false)
                        }

                        Spacer()
                    }
                    .padding(.leading, 30)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.caption2)
                            .accessibilityHidden(true)
                        Text("Thanks for the feedback")
                    }
                    .font(.caption)
                    .foregroundStyle(FFTheme.Text.tertiary)
                    .padding(.leading, 30)
                    .transition(.opacity)
                }
            }
        }
    }

    /// Pill-styled feedback button. Uses the tint color for the icon + text
    /// foreground, sits on a subtle tinted background. Matches the inline
    /// affordance density of the reward card and doesn't shout — feedback
    /// should be a quiet ask, not a loud CTA.
    private func feedbackButton(
        label: String,
        icon: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .accessibilityHidden(true)
                Text(label)
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(tint)
            .padding(.horizontal, FFTheme.Spacing.sm)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(tint.opacity(0.10))
                    .overlay(
                        Capsule()
                            .stroke(tint.opacity(0.20), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private var categoryIcon: String {
        switch reflection.category {
        case .timeManagement: "clock.arrow.2.circlepath"
        case .consistency: "chart.line.uptrend.xyaxis"
        case .selfCare: "heart.fill"
        case .momentum: "bolt.fill"
        }
    }
}

#Preview {
    ZStack {
        FFTheme.Background.rewardMid.ignoresSafeArea()
        PostReflectionCardView(
            reflection: ReflectionResult(
                templateID: "ref_comp_01",
                tipText: "Nice work! What helped you stay focused? Try to repeat that tomorrow.",
                category: .consistency
            ),
            onFeedback: { _ in }
        )
        .padding(.horizontal, FFTheme.Spacing.xxl)
    }
    .preferredColorScheme(.dark)
}
