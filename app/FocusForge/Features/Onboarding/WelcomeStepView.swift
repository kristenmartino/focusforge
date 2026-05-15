import SwiftUI

struct WelcomeStepView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            FFTheme.Background.primary.ignoresSafeArea()

            // Warm ambient glow behind the icon — radius and opacity bumped
            // so the flame feels anchored in atmosphere rather than floating
            // on a flat dark plane (P2-1).
            RadialGradient(
                colors: [
                    FFTheme.Accent.orange.opacity(0.14),
                    Color.clear,
                ],
                center: UnitPoint(x: 0.5, y: 0.35),
                startRadius: 0,
                endRadius: 260
            )
            .ignoresSafeArea()

            VStack(spacing: FFTheme.Spacing.xl) {
                Spacer()

                Image(systemName: "flame.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(FFTheme.Accent.orange)
                    .accessibilityHidden(true)

                VStack(spacing: FFTheme.Spacing.xs) {
                    Text("FocusForge")
                        .font(.largeTitle.bold())
                        .foregroundStyle(FFTheme.Text.primary)

                    Text("Your focus grows your character.")
                        .font(.body)
                        .foregroundStyle(FFTheme.Text.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                Spacer()

                AccentPillButton(title: "Get Started", action: onContinue, style: .blue)
                    .padding(.horizontal, 40)

                Spacer()
                    .frame(height: FFTheme.Spacing.xxxl)
            }
        }
    }
}

#Preview {
    WelcomeStepView(onContinue: {})
}
