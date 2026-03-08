import SwiftUI

struct TimerControlsView: View {
    @Environment(TimerEngine.self) private var engine

    let onStart: () -> Void
    let onCancel: () -> Void

    var body: some View {
        switch engine.state {
        case .idle:
            Button(action: onStart) {
                Text("Start \(engine.currentSessionType.displayName)")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(buttonTint)
            .padding(.horizontal, 40)
            .accessibilityHint("Starts a \(engine.currentSessionType.displayName.lowercased()) session")

        case .running:
            HStack(spacing: 24) {
                Button(action: { engine.pause() }) {
                    Label("Pause", systemImage: "pause.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.secondary)

                Button(role: .destructive, action: onCancel) {
                    Label("Cancel", systemImage: "xmark")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 24)

        case .paused:
            HStack(spacing: 24) {
                Button(action: { engine.resume() }) {
                    Label("Resume", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(buttonTint)

                Button(role: .destructive, action: onCancel) {
                    Label("Cancel", systemImage: "xmark")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 24)

        case .completed:
            EmptyView()
        }
    }

    private var buttonTint: Color {
        switch engine.currentSessionType {
        case .focus: return .blue
        case .shortBreak: return .green
        case .longBreak: return .orange
        }
    }
}
