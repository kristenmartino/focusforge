import SwiftUI

struct FirstSessionNudgeView: View {
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            FFTheme.Background.primary.ignoresSafeArea()

            RadialGradient(
                colors: [
                    FFTheme.Accent.green.opacity(0.06),
                    Color.clear,
                ],
                center: UnitPoint(x: 0.5, y: 0.35),
                startRadius: 0,
                endRadius: 160
            )
            .ignoresSafeArea()

            VStack(spacing: FFTheme.Spacing.xl) {
                Spacer()

                Image(systemName: "timer")
                    .font(.system(size: 60))
                    .foregroundStyle(FFTheme.Accent.green)
                    .accessibilityHidden(true)

                VStack(spacing: FFTheme.Spacing.xs) {
                    Text("You're All Set!")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(FFTheme.Text.primary)

                    Text("Start your first focus session\nand begin building your streak.")
                        .font(.body)
                        .foregroundStyle(FFTheme.Text.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                Spacer()

                AccentPillButton(title: "Start Focusing", action: onComplete, style: .blue)
                    .padding(.horizontal, 40)

                Spacer()
                    .frame(height: FFTheme.Spacing.xxxl)
            }
        }
    }
}

#Preview {
    FirstSessionNudgeView(onComplete: {})
}
