import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query(filter: #Predicate<TimerPreset> { $0.isDefault == true })
    private var presets: [TimerPreset]
    @Environment(\.modelContext) private var modelContext

    private var preset: TimerPreset? { presets.first }

    var body: some View {
        NavigationStack {
            List {
                if let preset {
                    Section("Timer") {
                        Stepper(
                            "Focus: \(preset.focusDurationSeconds / 60) min",
                            value: focusBinding(preset),
                            in: 1...120
                        )
                        Stepper(
                            "Short break: \(preset.shortBreakDurationSeconds / 60) min",
                            value: shortBreakBinding(preset),
                            in: 1...30
                        )
                        Stepper(
                            "Long break: \(preset.longBreakDurationSeconds / 60) min",
                            value: longBreakBinding(preset),
                            in: 1...30
                        )
                        Stepper(
                            "Sessions before long break: \(preset.sessionsBeforeLongBreak)",
                            value: sessionsBinding(preset),
                            in: 1...10
                        )
                    }
                }
                Section("About") {
                    LabeledContent("Version", value: "0.1.0")
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func focusBinding(_ preset: TimerPreset) -> Binding<Int> {
        Binding(
            get: { preset.focusDurationSeconds / 60 },
            set: { preset.focusDurationSeconds = PresetManager.clampFocusMinutes($0) * 60 }
        )
    }

    private func shortBreakBinding(_ preset: TimerPreset) -> Binding<Int> {
        Binding(
            get: { preset.shortBreakDurationSeconds / 60 },
            set: { preset.shortBreakDurationSeconds = PresetManager.clampBreakMinutes($0) * 60 }
        )
    }

    private func longBreakBinding(_ preset: TimerPreset) -> Binding<Int> {
        Binding(
            get: { preset.longBreakDurationSeconds / 60 },
            set: { preset.longBreakDurationSeconds = PresetManager.clampBreakMinutes($0) * 60 }
        )
    }

    private func sessionsBinding(_ preset: TimerPreset) -> Binding<Int> {
        Binding(
            get: { preset.sessionsBeforeLongBreak },
            set: { preset.sessionsBeforeLongBreak = PresetManager.clampSessionsBeforeLongBreak($0) }
        )
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: TimerPreset.self, inMemory: true)
}
