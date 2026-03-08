import SwiftUI

struct FirstSessionNudgeView: View {
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "timer")
                .font(.system(size: 60))
                .foregroundStyle(.green)
                .accessibilityHidden(true)

            Text("You're All Set!")
                .font(.title2.bold())

            Text("Start your first focus session and begin building your streak.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button(action: onComplete) {
                Text("Start Focusing")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 40)

            Spacer()
        }
    }
}

#Preview {
    FirstSessionNudgeView(onComplete: {})
}
