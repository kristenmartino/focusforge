import SwiftUI

struct PostReflectionCardView: View {
    let reflection: ReflectionResult
    let onFeedback: (Bool) -> Void

    @State private var feedbackGiven = false

    var body: some View {
        VStack(spacing: 8) {
            Divider()
                .padding(.horizontal)

            HStack(spacing: 8) {
                Image(systemName: categoryIcon)
                    .foregroundStyle(.cyan)
                Text(reflection.tipText)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal)

            if !feedbackGiven {
                HStack(spacing: 16) {
                    Button {
                        feedbackGiven = true
                        onFeedback(true)
                    } label: {
                        Label("Helpful", systemImage: "hand.thumbsup")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Button {
                        feedbackGiven = true
                        onFeedback(false)
                    } label: {
                        Label("Not helpful", systemImage: "hand.thumbsdown")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            } else {
                Text("Thanks for the feedback!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
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
