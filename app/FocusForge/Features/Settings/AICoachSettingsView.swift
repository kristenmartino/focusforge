import SwiftUI
import SwiftData

struct AICoachSettingsView: View {
    @Query private var preferences: [AICoachPreference]
    @Environment(\.modelContext) private var modelContext

    private var preference: AICoachPreference {
        preferences.first ?? AICoachPreferenceManager.fetchOrCreate(in: modelContext)
    }

    var body: some View {
        ZStack {
            FFTheme.Background.primary.ignoresSafeArea()

            List {
                Section {
                    Toggle("AI Coach", isOn: Binding(
                        get: { preference.aiCoachEnabled },
                        set: { preference.aiCoachEnabled = $0; preference.updatedAt = .now }
                    ))
                } footer: {
                    Text("The AI Coach provides focus tips and streak reminders. All features run on-device and are optional.")
                        .foregroundStyle(FFTheme.Text.tertiary)
                }
                .listRowBackground(Color.white.opacity(0.04))

                if preference.aiCoachEnabled {
                    Section("Features") {
                        Toggle("Intent Framing", isOn: Binding(
                            get: { preference.intentFramingEnabled },
                            set: { preference.intentFramingEnabled = $0; preference.updatedAt = .now }
                        ))
                        Toggle("Post-Session Tips", isOn: Binding(
                            get: { preference.postReflectionEnabled },
                            set: { preference.postReflectionEnabled = $0; preference.updatedAt = .now }
                        ))
                        Toggle("Streak Nudges", isOn: Binding(
                            get: { preference.streakNudgeEnabled },
                            set: { preference.streakNudgeEnabled = $0; preference.updatedAt = .now }
                        ))
                    }
                    .listRowBackground(Color.white.opacity(0.04))

                    Section {
                        Picker("Tone", selection: Binding(
                            get: { preference.tone },
                            set: { preference.tone = $0; preference.updatedAt = .now }
                        )) {
                            Text("Encouraging").tag(CoachTone.encouraging)
                            Text("Direct").tag(CoachTone.direct)
                            Text("Calm").tag(CoachTone.calm)
                        }
                        .pickerStyle(.segmented)
                        .accessibilityLabel("Coach tone")
                        .accessibilityValue(preference.tone.rawValue.capitalized)
                    } header: {
                        Text("Coach Tone")
                    } footer: {
                        Text(toneDescription)
                            .foregroundStyle(FFTheme.Text.tertiary)
                    }
                    .listRowBackground(Color.white.opacity(0.04))

                    Section {
                        Picker("Frequency", selection: Binding(
                            get: { preference.nudgeFrequency },
                            set: { preference.nudgeFrequency = $0; preference.updatedAt = .now }
                        )) {
                            Text("Low").tag(NudgeFrequency.low)
                            Text("Medium").tag(NudgeFrequency.medium)
                            Text("High").tag(NudgeFrequency.high)
                        }
                        .pickerStyle(.segmented)
                        .accessibilityLabel("Nudge frequency")
                        .accessibilityValue(preference.nudgeFrequency.rawValue.capitalized)
                    } header: {
                        Text("Nudge Frequency")
                    } footer: {
                        Text(frequencyDescription)
                            .foregroundStyle(FFTheme.Text.tertiary)
                    }
                    .listRowBackground(Color.white.opacity(0.04))

                    Section {
                        Picker("Start", selection: Binding(
                            get: { preference.quietHoursStart },
                            set: { preference.quietHoursStart = $0; preference.updatedAt = .now }
                        )) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(formatHour(hour)).tag(hour)
                            }
                        }
                        Picker("End", selection: Binding(
                            get: { preference.quietHoursEnd },
                            set: { preference.quietHoursEnd = $0; preference.updatedAt = .now }
                        )) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(formatHour(hour)).tag(hour)
                            }
                        }
                    } header: {
                        Text("Quiet Hours")
                    } footer: {
                        Text("No streak nudges will be sent during quiet hours.")
                            .foregroundStyle(FFTheme.Text.tertiary)
                    }
                    .listRowBackground(Color.white.opacity(0.04))
                }
            }
            .scrollContentBackground(.hidden)
            .tint(FFTheme.Accent.blue)
        }
        .navigationTitle("AI Coach")
        .darkNavigationAppearance()
    }

    private var toneDescription: String {
        switch preference.tone {
        case .encouraging: "Warm and supportive messages"
        case .direct: "Concise and action-focused messages"
        case .calm: "Gentle and mindful messages"
        }
    }

    private var frequencyDescription: String {
        switch preference.nudgeFrequency {
        case .low: "At most once per day"
        case .medium: "At most twice per day"
        case .high: "Up to four times per day"
        }
    }

    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        var components = DateComponents()
        components.hour = hour
        let date = Calendar.current.date(from: components) ?? .now
        return formatter.string(from: date)
    }
}
