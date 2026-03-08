import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    let lineWidth: CGFloat
    let sessionType: SessionPhase

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Timer progress")
        .accessibilityValue("\(Int(progress * 100)) percent remaining")
    }

    private var ringColor: Color {
        switch sessionType {
        case .focus: return .blue
        case .shortBreak: return .green
        case .longBreak: return .orange
        }
    }
}

#Preview {
    ProgressRingView(progress: 0.65, lineWidth: 12, sessionType: .focus)
        .frame(width: 260, height: 260)
        .padding()
}
