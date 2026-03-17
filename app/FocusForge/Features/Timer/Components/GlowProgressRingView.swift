import SwiftUI

/// Progress ring with a soft glow aura — the centerpiece of focus mode.
///
/// The glow is achieved by drawing two rings:
/// 1. A wide, low-opacity ring (the "aura")
/// 2. A thin, high-opacity ring (the crisp edge)
/// Plus a subtle track ring at very low opacity.
struct GlowProgressRingView: View {
    let progress: Double
    let sessionType: SessionPhase
    var size: CGFloat = 260
    var lineWidth: CGFloat = 3
    var glowWidth: CGFloat = 8

    private var ringColor: Color {
        FFTheme.sessionColor(for: sessionType)
    }

    var body: some View {
        ZStack {
            // Track (very subtle)
            Circle()
                .stroke(
                    Color.white.opacity(0.04),
                    lineWidth: lineWidth
                )

            // Glow aura (wide, transparent)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ringColor.opacity(0.15),
                    style: StrokeStyle(lineWidth: glowWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Crisp ring (thin, opaque)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ringColor.opacity(0.90),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
        .animation(.linear(duration: 0.1), value: progress)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Timer progress")
        .accessibilityValue("\(Int(progress * 100)) percent remaining")
    }
}

#Preview {
    ZStack {
        FocusBackground()
        GlowProgressRingView(progress: 0.65, sessionType: .focus)
    }
}
