import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query(filter: #Predicate<TimerPreset> { $0.isDefault == true })
    private var presets: [TimerPreset]
    @Query private var streakStates: [StreakState]
    @Environment(\.modelContext) private var modelContext

    private var preset: TimerPreset? { presets.first }
    private var streakState: StreakState? { streakStates.first }

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

                Section {
                    HStack {
                        Label("Streak Freezes", systemImage: "snowflake")
                        Spacer()
                        Text("\(streakState?.freezesAvailable ?? 0) available")
                            .foregroundStyle(.secondary)
                    }
                    if let state = streakState, state.freezesUsed > 0 {
                        HStack {
                            Text("Freezes used")
                            Spacer()
                            Text("\(state.freezesUsed)")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Streak Freezes")
                } footer: {
                    Text("Streak freezes are earned at milestone days (3, 7, 14, 30, 60). When you miss a day, a freeze is automatically used to protect your streak.")
                }

                #if DEBUG
                Section("Debug") {
                    Button("Grant 500 Coins") {
                        let state = StreakManager.fetchOrCreateStreakState(in: modelContext)
                        state.totalCoins += 500
                    }
                    Button("Set Streak to Day 3 (Early Bird)") {
                        let state = StreakManager.fetchOrCreateStreakState(in: modelContext)
                        state.currentStreakDays = 3
                        state.lastCompletedDate = .now
                        if let reward = MilestoneEngine.checkMilestone(streakDays: 3, in: modelContext) {
                            try? modelContext.save()
                        }
                    }
                    Button("Set Streak to Day 7 (Week Warrior)") {
                        let state = StreakManager.fetchOrCreateStreakState(in: modelContext)
                        state.currentStreakDays = 7
                        state.lastCompletedDate = .now
                        if let reward = MilestoneEngine.checkMilestone(streakDays: 7, in: modelContext) {
                            try? modelContext.save()
                        }
                    }
                    HStack {
                        Text("Coins")
                        Spacer()
                        Text("\(streakState?.totalCoins ?? 0)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Streak")
                        Spacer()
                        Text("Day \(streakState?.currentStreakDays ?? 0)")
                            .foregroundStyle(.secondary)
                    }
                }
                #endif

                Section("About") {
                    LabeledContent("Version", value: "0.3.0")
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
        .modelContainer(for: [TimerPreset.self, StreakState.self], inMemory: true)
}
