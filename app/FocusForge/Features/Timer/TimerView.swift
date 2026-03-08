import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(TimerEngine.self) private var engine
    @Environment(NotificationService.self) private var notificationService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @Query(filter: #Predicate<TimerPreset> { $0.isDefault == true })
    private var presets: [TimerPreset]

    @State private var taskName: String = ""
    @State private var showCompletion = false
    @State private var completionRewards: RewardCalculation?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text(engine.currentSessionType.displayName)
                    .font(.title3)
                    .foregroundStyle(.secondary)

                ZStack {
                    ProgressRingView(
                        progress: engine.progress,
                        lineWidth: 12,
                        sessionType: engine.currentSessionType
                    )
                    .frame(width: 260, height: 260)

                    Text(engine.formattedTime)
                        .font(.system(size: 56, weight: .light, design: .monospaced))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .accessibilityLabel("Time remaining: \(engine.accessibleTimeDescription)")
                }

                if engine.state == .idle {
                    TaskNameInputView(taskName: $taskName)
                } else if !taskName.isEmpty {
                    Text(taskName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                TimerControlsView(
                    onStart: startSession,
                    onCancel: cancelSession
                )

                Spacer()
            }
            .navigationTitle("Timer")
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    engine.recalculateOnForeground()
                }
            }
            .onChange(of: engine.state) { oldState, newState in
                handleStateChange(from: oldState, to: newState)
            }
            .sheet(isPresented: $showCompletion) {
                SessionCompletionView(
                    sessionType: engine.currentSessionType,
                    duration: engine.totalDuration,
                    rewards: completionRewards ?? RewardCalculation(xp: 0, coins: 0),
                    onDismiss: dismissCompletion
                )
            }
        }
    }

    private func startSession() {
        guard let preset = presets.first else { return }

        let duration: TimeInterval
        switch engine.currentSessionType {
        case .focus:
            duration = TimeInterval(preset.focusDurationSeconds)
        case .shortBreak:
            duration = TimeInterval(preset.shortBreakDurationSeconds)
        case .longBreak:
            duration = TimeInterval(preset.longBreakDurationSeconds)
        }

        engine.taskName = taskName
        engine.start(duration: duration, sessionType: engine.currentSessionType)
        notificationService.scheduleCompletion(in: duration, sessionType: engine.currentSessionType)
    }

    private func cancelSession() {
        let startedAt: Date?
        if case .running(let date) = engine.state {
            startedAt = date
        } else if case .paused = engine.state {
            startedAt = Date.now.addingTimeInterval(-(engine.totalDuration - engine.remainingSeconds))
        } else {
            startedAt = nil
        }

        let plannedDuration = engine.totalDuration
        let actualDuration = engine.totalDuration - engine.remainingSeconds
        let sessionType = engine.currentSessionType

        engine.cancel()
        notificationService.cancelPending()

        if let startedAt {
            SessionLogger.logAbandonment(
                taskName: taskName,
                sessionType: sessionType,
                plannedDuration: plannedDuration,
                actualDuration: actualDuration,
                startedAt: startedAt,
                in: modelContext
            )
        }
    }

    private func handleStateChange(from oldState: TimerState, to newState: TimerState) {
        switch newState {
        case .paused:
            notificationService.cancelPending()
        case .running:
            if case .paused = oldState {
                notificationService.scheduleCompletion(
                    in: engine.remainingSeconds,
                    sessionType: engine.currentSessionType
                )
            }
        case .completed:
            handleCompletion()
        case .idle:
            break
        }
    }

    private func handleCompletion() {
        let rewards = SessionLogger.logCompletion(
            taskName: engine.taskName,
            sessionType: engine.currentSessionType,
            plannedDuration: engine.totalDuration,
            startedAt: Date.now.addingTimeInterval(-engine.totalDuration),
            in: modelContext
        )
        completionRewards = rewards
        showCompletion = true
    }

    private func dismissCompletion() {
        showCompletion = false
        if let preset = presets.first {
            engine.prepareNextSession(sessionsBeforeLongBreak: preset.sessionsBeforeLongBreak)
            engine.loadPreset(
                focusSeconds: preset.focusDurationSeconds,
                shortBreakSeconds: preset.shortBreakDurationSeconds,
                longBreakSeconds: preset.longBreakDurationSeconds
            )
        }
        engine.acknowledge()
        taskName = ""
    }
}

#Preview {
    TimerView()
        .environment(TimerEngine())
        .environment(NotificationService())
        .modelContainer(for: [TimerPreset.self, SessionLog.self, StreakState.self], inMemory: true)
}
