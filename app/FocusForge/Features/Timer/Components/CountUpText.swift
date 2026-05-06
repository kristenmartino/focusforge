import SwiftUI

/// Animates a number from 0 to a target value over a given duration.
/// Uses `TimelineView` for smooth frame-by-frame interpolation.
struct CountUpText: View {
    let target: Int
    let duration: TimeInterval
    let prefix: String
    var font: Font = .system(size: 18, weight: .medium)
    var color: Color = .white

    @State private var startTime: Date?
    @State private var displayValue: Int = 0
    @State private var isComplete = false

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: isComplete)) { context in
            Text("\(prefix)\(displayValue)")
                .font(font)
                .foregroundStyle(color)
                .monospacedDigit()
                .contentTransition(.numericText())
                .onChange(of: context.date) { _, now in
                    guard let start = startTime else {
                        startTime = now
                        return
                    }
                    let elapsed = now.timeIntervalSince(start)
                    let progress = min(elapsed / duration, 1.0)
                    // Ease-out curve: 1 - (1-t)^3
                    let eased = 1.0 - pow(1.0 - progress, 3)
                    displayValue = Int(Double(target) * eased)
                    if progress >= 1.0 {
                        displayValue = target
                        isComplete = true
                    }
                }
        }
        .onAppear {
            if target == 0 { isComplete = true }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 20) {
            CountUpText(
                target: 30,
                duration: 0.8,
                prefix: "+",
                color: Color(hex: "#F0C840")
            )
            CountUpText(
                target: 25,
                duration: 0.8,
                prefix: "+",
                color: Color(hex: "#F0A040")
            )
        }
    }
}
