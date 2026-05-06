import SwiftUI

struct NotificationPermissionStepView: View {
    @Environment(NotificationService.self) private var notificationService
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            FFTheme.Background.primary.ignoresSafeArea()

            RadialGradient(
                colors: [
                    FFTheme.Accent.blue.opacity(0.06),
                    Color.clear,
                ],
                center: UnitPoint(x: 0.5, y: 0.35),
                startRadius: 0,
                endRadius: 160
            )
            .ignoresSafeArea()

            VStack(spacing: FFTheme.Spacing.xl) {
                Spacer()

                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(FFTheme.Accent.blue)
                    .accessibilityHidden(true)

                VStack(spacing: FFTheme.Spacing.xs) {
                    Text("Stay on Track")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(FFTheme.Text.primary)

                    Text("Get notified when your timer completes,\neven if the app is in the background.")
                        .font(.body)
                        .foregroundStyle(FFTheme.Text.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                Spacer()

                VStack(spacing: FFTheme.Spacing.sm) {
                    AccentPillButton(
                        title: "Enable Notifications",
                        action: {
                            Task {
                                _ = await notificationService.requestPermission()
                                onContinue()
                            }
                        },
                        style: .blue
                    )
                    .padding(.horizontal, 40)

                    Button(action: onContinue) {
                        Text("Not Now")
                            .font(.subheadline)
                            .foregroundStyle(FFTheme.Text.tertiary)
                    }
                }

                Spacer()
                    .frame(height: FFTheme.Spacing.xxxl)
            }
        }
    }
}

#Preview {
    NotificationPermissionStepView(onContinue: {})
        .environment(NotificationService())
}
