import SwiftUI

/// A single radial pulse that expands outward and fades — the "ring complete" moment.
/// Renders as a circle that scales from 1x to 2x and fades to 0 over the duration.
/// Respects accessibilityReduceMotion: skipped entirely when reduce-motion is on
/// (the parent reward overlay's static fallback covers the moment without spatial change).
struct RingPulseView: View {
    let color: Color
    let ringSize: CGFloat
    var duration: TimeInterval = 0.6

    @State private var animate = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Circle()
            .stroke(color, lineWidth: 3)
            .frame(width: ringSize, height: ringSize)
            .scaleEffect(reduceMotion ? 1.0 : (animate ? 2.0 : 1.0))
            .opacity(reduceMotion ? 0 : (animate ? 0 : 0.6))
            .accessibilityHidden(true)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeOut(duration: duration)) {
                    animate = true
                }
            }
    }
}

#Preview {
    ZStack {
        Color(hex: "#0A0A0F").ignoresSafeArea()
        RingPulseView(color: Color(hex: "#4A7BF7"), ringSize: 260)
    }
}
