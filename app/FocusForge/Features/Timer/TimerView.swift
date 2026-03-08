import SwiftUI
import SwiftData

struct TimerView: View {
    @Query private var presets: [TimerPreset]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("25:00")
                    .font(.system(size: 72, weight: .light, design: .monospaced))
                    .foregroundStyle(.primary)

                Text("Focus Session")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Spacer()

                Button(action: {}) {
                    Text("Start Focus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 40)

                Spacer()
            }
            .navigationTitle("Timer")
        }
    }
}

#Preview {
    TimerView()
        .modelContainer(for: TimerPreset.self, inMemory: true)
}
