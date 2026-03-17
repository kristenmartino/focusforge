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

            VStack(alignment: .leading, spacing: 2) {
                Text("Protect your \(streakDays)-day streak!")
                    .font(.subheadline.bold())
                Text("A quick session keeps it alive")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Start", action: onStartSession)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}
