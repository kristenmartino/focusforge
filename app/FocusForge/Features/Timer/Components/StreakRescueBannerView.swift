import SwiftUI

struct StreakRescueBannerView: View {
    let streakDays: Int
    let onStartSession: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.title3)
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("Protect your \(streakDays)-day streak!")
                    .font(.subheadline.bold())
                Text("A quick session keeps it alive")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Start") {
                AnalyticsService.track(.aiNudgeOpened, parameters: [
                    "kind": "streak_rescue",
                    "streak_days": streakDays
                ])
                onStartSession()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)

            Button {
                AnalyticsService.track(.aiSuggestionDismissed, parameters: [
                    "kind": "streak_rescue",
                    "streak_days": streakDays
                ])
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .accessibilityLabel("Dismiss streak nudge")
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .onAppear {
            AnalyticsService.track(.aiPromptShown, parameters: [
                "kind": "streak_rescue",
                "streak_days": streakDays
            ])
        }
    }
}
