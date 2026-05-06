import SwiftUI

/// A single radial pulse that expands outward and fades — the "ring complete" moment.
/// Renders as a circle that scales from 1x to 2x and fades to 0 over the duration.
struct RingPulseView: View {
    let color: Color
    let ringSize: CGFloat
    var duration: TimeInterval = 0.6

    @State private var animate = false

    var body: some View {
        Circle()
            .stroke(color, lineWidth: 3)
            .frame(width: ringSize, height: ringSize)
            .scaleEffect(animate ? 2.0 : 1.0)
            .opacity(animate ? 0 : 0.6)
            .onAppear {
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
