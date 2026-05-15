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
    /// Visual intensity. `.idle` reads as "ready"; `.running` pushes the glow
    /// aura wider; `.paused` softens both rings so the screen reads as
    /// "frozen mid-session" without changing layout. (P2-3 / P2-4)
    var state: VisualState = .running
    var size: CGFloat = 260
    var lineWidth: CGFloat = 3
    var glowWidth: CGFloat = 8

    enum VisualState {
        case idle, running, paused
    }

    private var ringColor: Color {
        FFTheme.sessionColor(for: sessionType)
    }

    private var auraOpacity: Double {
        switch state {
        case .idle:    return 0.12
        case .running: return 0.24
        case .paused:  return 0.10
        }
    }

    private var crispOpacity: Double {
        switch state {
        case .idle:    return 0.70
        case .running: return 0.95
        case .paused:  return 0.50
        }
    }

    private var auraGlowWidth: CGFloat {
        // Push the glow wider in the active state for a "breathing" presence.
        state == .running ? glowWidth + 2 : glowWidth
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
                    ringColor.opacity(auraOpacity),
                    style: StrokeStyle(lineWidth: auraGlowWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Crisp ring (thin, opaque)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ringColor.opacity(crispOpacity),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
        .animation(.linear(duration: 0.1), value: progress)
        .animation(.easeInOut(duration: 0.25), value: auraOpacity)
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
