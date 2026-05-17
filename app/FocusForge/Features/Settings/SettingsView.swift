import SwiftUI
import SwiftData
import FocusForgeCoachEngine

struct SettingsView: View {
    @Query(filter: #Predicate<TimerPreset> { $0.isDefault == true })
    private var presets: [TimerPreset]
    @Query private var streakStates: [StreakState]
    @Environment(\.modelContext) private var modelContext
    @State private var debugSignalText: String = ""
    @State private var debugMilestonePreview: MilestoneReward?
    @AppStorage("debug.forceStreakRescueBanner") private var debugForceStreakRescueBanner = false
    // Mirrors `AnalyticsService.analyticsEnabledKey`. Default true means
    // analytics flow until the user explicitly toggles off. Changes here
    // also need to call `Analytics.setAnalyticsCollectionEnabled(...)` to
    // disable the Firebase SDK itself (handled via .onChange below).
    @AppStorage("analytics.enabled") private var analyticsEnabled = true
    @State private var showBackupShare = false
    @State private var backupShareItems: [Any] = []
    @State private var backupError: String?

    private var preset: TimerPreset? { presets.first }
    private var streakState: StreakState? { streakStates.first }

    var body: some View {
        NavigationStack {
            ZStack {
                FFTheme.Background.primary.ignoresSafeArea()

                List {
                    if let preset {
                        Section("Timer") {
                            Stepper(
                                "Focus: \(preset.focusDurationSeconds / 60) min",
                                value: focusBinding(preset),
                                in: 1...120
                            )
                            .accessibilityValue("\(preset.focusDurationSeconds / 60) minutes")
                            Stepper(
                                "Short break: \(preset.shortBreakDurationSeconds / 60) min",
                                value: shortBreakBinding(preset),
                                in: 1...30
                            )
                            .accessibilityValue("\(preset.shortBreakDurationSeconds / 60) minutes")
                            Stepper(
                                "Long break: \(preset.longBreakDurationSeconds / 60) min",
                                value: longBreakBinding(preset),
                                in: 1...30
                            )
                            .accessibilityValue("\(preset.longBreakDurationSeconds / 60) minutes")
                            Stepper(
                                "Long break every: \(preset.sessionsBeforeLongBreak)",
                                value: sessionsBinding(preset),
                                in: 1...10
                            )
                            .accessibilityValue("\(preset.sessionsBeforeLongBreak) sessions")
                        }
                        .listRowBackground(Color.white.opacity(0.04))
                    }

                    Section {
                        HStack {
                            Label("Streak Freezes", systemImage: "snowflake")
                                .foregroundStyle(FFTheme.Accent.cyan)
                            Spacer()
                            Text("\(streakState?.freezesAvailable ?? 0) available")
                                .foregroundStyle(FFTheme.Text.tertiary)
                        }
                        if let state = streakState, state.freezesUsed > 0 {
                            HStack {
                                Text("Freezes used")
                                Spacer()
                                Text("\(state.freezesUsed)")
                                    .foregroundStyle(FFTheme.Text.tertiary)
                            }
                        }
                    } header: {
                        Text("Streak Freezes")
                    } footer: {
                        Text("Streak freezes are earned at milestone days (3, 7, 14, 30, 60). When you miss a day, a freeze is automatically used to protect your streak.")
                    }
                    .listRowBackground(Color.white.opacity(0.04))

                    Section("AI Coach") {
                        NavigationLink {
                            AICoachSettingsView()
                        } label: {
                            Label("AI Coach Settings", systemImage: "brain.head.profile")
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.04))

                    Section {
                        Button {
                            exportBackup()
                        } label: {
                            Label("Export My Progress", systemImage: "square.and.arrow.up")
                                .foregroundStyle(FFTheme.Accent.blue)
                        }
                        if let backupError {
                            Text(backupError)
                                .font(.caption)
                                .foregroundStyle(FFTheme.Accent.red)
                        }
                    } header: {
                        Text("Backup")
                    } footer: {
                        Text("Save a JSON snapshot of your streak, character, inventory, sessions, and quests. Useful before upgrading your phone or wiping data. CloudKit sync arrives in v1.1.")
                            .foregroundStyle(FFTheme.Text.tertiary)
                    }
                    .listRowBackground(Color.white.opacity(0.04))

                    Section {
                        Toggle(isOn: $analyticsEnabled) {
                            Label("Send anonymous analytics", systemImage: "chart.bar.fill")
                                .foregroundStyle(FFTheme.Text.primary)
                        }
                        .tint(FFTheme.Accent.blue)
                        .onChange(of: analyticsEnabled) { _, newValue in
                            // Toggle the Firebase SDK collection flag in
                            // sync. AnalyticsService.track() also gates on
                            // this AppStorage key, but flipping the SDK
                            // flag stops any analytics-adjacent code paths
                            // (Crashlytics breadcrumbs, etc.) from
                            // reaching Firebase too. Defense in depth.
                            AnalyticsService.setSDKCollectionEnabled(newValue)
                        }
                    } header: {
                        Text("Privacy")
                    } footer: {
                        Text("When on, we send anonymous product analytics (which screens you visit, session counts) to help us improve the app. We never send your task names, focus content, or any identifying information. Crash reports stay on either way — they help us fix bugs that affect you.")
                            .foregroundStyle(FFTheme.Text.tertiary)
                    }
                    .listRowBackground(Color.white.opacity(0.04))

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
                            if let _ = MilestoneEngine.checkMilestone(streakDays: 3, in: modelContext) {
                                try? modelContext.save()
                            }
                        }
                        Button("Set Streak to Day 7 (Week Warrior)") {
                            let state = StreakManager.fetchOrCreateStreakState(in: modelContext)
                            state.currentStreakDays = 7
                            state.lastCompletedDate = .now
                            if let _ = MilestoneEngine.checkMilestone(streakDays: 7, in: modelContext) {
                                try? modelContext.save()
                            }
                        }
                        HStack {
                            Text("Coins")
                            Spacer()
                            Text("\(streakState?.totalCoins ?? 0)")
                                .foregroundStyle(FFTheme.Text.tertiary)
                        }
                        HStack {
                            Text("Streak")
                            Spacer()
                            Text("Day \(streakState?.currentStreakDays ?? 0)")
                                .foregroundStyle(FFTheme.Text.tertiary)
                        }
                        Button("Trigger Streak Risk (Yesterday Evening)") {
                            let state = StreakManager.fetchOrCreateStreakState(in: modelContext)
                            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
                            let yesterdayEvening = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: yesterday)!
                            state.lastCompletedDate = yesterdayEvening
                            if state.currentStreakDays == 0 { state.currentStreakDays = 3 }
                        }
                        Button("Show Behavior Signal") {
                            let signal = BehaviorSignalComputer.compute(in: modelContext)
                            debugSignalText = String(format: "Completion: %.0f%% | Abandon: %.0f%% | Avg: %.0fmin | Risk: %.2f | Sessions: %d",
                                signal.completionRate7d * 100,
                                signal.abandonRate7d * 100,
                                signal.avgActualFocusMinutes,
                                signal.streakRiskScore,
                                signal.totalSessions7d
                            )
                        }
                        if !debugSignalText.isEmpty {
                            Text(debugSignalText)
                                .font(.caption2)
                                .foregroundStyle(FFTheme.Text.tertiary)
                        }

                        // P1-15: present MilestoneUnlockView directly so the
                        // celebration UI is testable without simulating multi-day
                        // streak progression.
                        ForEach(MilestoneEngine.milestones) { milestone in
                            Button("Preview Day \(milestone.streakDay) Milestone — \(milestone.name)") {
                                debugMilestonePreview = milestone
                            }
                        }

                        // P1-16: force the streak rescue banner regardless of
                        // BehaviorSignalComputer's time-of-day-dependent score.
                        // Read by ContentView via the same @AppStorage key.
                        Toggle("Force Streak Rescue Banner", isOn: $debugForceStreakRescueBanner)
                    }
                    .listRowBackground(Color.white.opacity(0.04))
                    #endif

                    Section("About") {
                        NavigationLink {
                            AboutView()
                        } label: {
                            Label("About FocusForge", systemImage: "info.circle")
                        }
                        LabeledContent("Version", value: aboutVersionShort)
                    }
                    .listRowBackground(Color.white.opacity(0.04))
                }
                .scrollContentBackground(.hidden)
                .tint(FFTheme.Accent.blue)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .darkNavigationAppearance()
            .sheet(item: $debugMilestonePreview) { milestone in
                MilestoneUnlockView(milestone: milestone) {
                    debugMilestonePreview = nil
                }
                .presentationBackground(Color.clear)
            }
            .sheet(isPresented: $showBackupShare) {
                ShareSheet(items: backupShareItems)
            }
        }
    }

    // MARK: - Backup

    /// Generates a JSON backup of the user's progress and presents the system
    /// share sheet. Writes to the temporary directory so the share-sheet target
    /// (Files, Mail, AirDrop, etc.) sees a real file with a sensible filename.
    private func exportBackup() {
        backupError = nil
        do {
            let data = try DataExportService.exportJSON(in: modelContext)
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(DataExportService.defaultFilename())
            try data.write(to: url, options: .atomic)
            backupShareItems = [url]
            showBackupShare = true
        } catch {
            backupError = "Couldn't generate backup: \(error.localizedDescription)"
        }
    }

    // MARK: - Bindings

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

    // MARK: - Version display

    /// Short version display for the Settings About row. Pulls from
    /// Info.plist so it doesn't drift from the build number. The full
    /// "Version X (build)" string lives in AboutView's footer.
    private var aboutVersionShort: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        return short
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [TimerPreset.self, StreakState.self], inMemory: true)
}
