import SwiftUI

struct NotificationPermissionStepView: View {
    @Environment(NotificationService.self) private var notificationService
    let onContinue: () -> Void

    @State private var hasResponded = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
                .accessibilityHidden(true)

            Text("Stay on Track")
                .font(.title2.bold())

            Text("Get notified when your timer completes, even if the app is in the background.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            VStack(spacing: 12) {
                Button(action: requestPermission) {
                    Text("Enable Notifications")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 40)

                Button(action: onContinue) {
                    Text("Not Now")
                        .font(.subheadline)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private func requestPermission() {
        Task {
            _ = await notificationService.requestPermission()
            onContinue()
        }
    }
}

#Preview {
    NotificationPermissionStepView(onContinue: {})
        .environment(NotificationService())
}
