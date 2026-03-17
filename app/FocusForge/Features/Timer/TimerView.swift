import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(TimerEngine.self) private var engine
    @Environment(NotificationService.self) private var notificationService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @Query(filter: #Predicate<TimerPreset> { $0.isDefault == true })
    private var presets: [TimerPreset]
    @Query private var coachPreferences: [AICoachPreference]

    @State private var taskName: String = ""
    @State private var showCompletion = false
    @State private var completionResult: SessionResult?
    @State private var completionReflection: ReflectionResult?
    @State private var showMilestone = false
    @State private var pendingMilestone: MilestoneReward?
    @State private var showIntentFraming = false
    @State private var currentFraming: FramingResult?

    var body: some View {
        NavigationStack {
            ZStack {
                // Atmospheric background
                FocusBackground(
                    accentColor: FFTheme.sessionColor(for: engine.currentSessionType)
                )

                // Content
                VStack(spacing: 0) {
                    Spacer()

                    // Streak badge
                    StreakBadgeView()
                        .padding(.bottom, FFTheme.Spacing.sm)

                    // Session type label
                    Text(engine.currentSessionType.displayName.uppercased())
                        .font(.sessionLabel)
                        .foregroundStyle(FFTheme.Text.tertiary)
                        .tracking(2)
                        .padding(.bottom, FFTheme.Spacing.lg)

                    // Timer ring + display
                    ZStack {
                        GlowProgressRingView(
                            progress: engine.progress,
                            sessionType: engine.currentSessionType
                        )

                        VStack(spacing: 4) {
                            Text(engine.formattedTime)
                                .font(.timerDisplay)
                                .foregroundStyle(FFTheme.Text.primary)
                                .monospacedDigit()
                                .contentTransition(.numericText())
                                .accessibilityLabel(
                                    "Time remaining: \(engine.accessibleTimeDescription)"
                                )
                        }
                    }
                    .padding(.bottom, FFTheme.Spacing.lg)

                    // Task name
                    if engine.state == .idle {
                        taskNameField
                    } else if !taskName.isEmpty {
                        Text(taskName)
                            .font(.subheadline)
                            .foregroundStyle(FFTheme.Text.tertiary)
                    }

                    Spacer()

                    // Controls
                    timerControls
                        .padding(.bottom, FFTheme.Spacing.xxxl)

                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Timer")
                        .font(.headline)
                        .foregroundStyle(FFTheme.Text.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SessionHistoryView()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundStyle(FFTheme.Text.secondary)
                    }
                }
            }
            .darkNavigationAppearance()
            .onAppear { syncPresetToEngine() }
            .onChange(of: presetDurations) { _, _ in syncPresetToEngine() }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active { engine.recalculateOnForeground() }
            }
            .onChange(of: engine.state) { oldState, newState in
                handleStateChange(from: oldState, to: newState)
            }
            .sheet(isPresented: $showIntentFraming) {
                if let framing = currentFraming {
                    IntentFramingView(
                        framing: framing,
                        onAccept: { acceptedTask in
                            logFramingInteraction(templateID: framing.templateID, outcome: .accepted)
                            showIntentFraming = false
                            taskName = acceptedTask
                            startSessionDirectly()
                        },
                        onSkip: {
                            logFramingInteraction(templateID: framing.templateID, outcome: .dismissed)
                            showIntentFraming = false
                            startSessionDirectly()
                        }
                    )
                }
            }
            .sheet(isPresented: $showCompletion, onDismiss: dismissCompletion) {
                SessionCompletionView(
                    sessionType: engine.currentSessionType,
                    duration: engine.totalDuration,
                    result: completionResult ?? SessionResult(
                        xp: 0, coins: 0, streakDays: 0,
                        bonusXP: 0, newMilestone: nil, leveledUp: false,
                        completedQuests: []
                    ),
                    reflection: completionReflection,
                    onReflectionFeedback: { accepted in
                        if let reflection = completionReflection {
                            logReflectionInteraction(
                                templateID: reflection.templateID,
                                outcome: accepted ? .accepted : .dismissed
                            )
                        }
                    },
                    onDismiss: dismissCompletion
                )
                .presentationBackground(Color.clear)
            }
            .sheet(isPresented: $showMilestone) {
                if let milestone = pendingMilestone {
                    MilestoneUnlockView(milestone: milestone) {
                        showMilestone = false
                        pendingMilestone = nil
                    }
                    .presentationBackground(Color.clear)
                }
            }
        }
    }

    // MARK: - Task Name Field

    private var taskNameField: some View {
        HStack {
            TextField("", text: $taskName, prompt:
                Text("What are you working on?")
                    .foregroundStyle(FFTheme.Text.disabled)
            )
            .font(.subheadline)
            .foregroundStyle(FFTheme.Text.secondary)
            .multilineTextAlignment(.center)
            .submitLabel(.done)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: FFTheme.Radius.sm)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: FFTheme.Radius.sm)
                            .stroke(FFTheme.Border.default, lineWidth: 0.5)
                    )
            )
        }
        .padding(.horizontal, 40)
        .accessibilityLabel("Task name, optional")
    }

    // MARK: - Timer Controls

    private var timerControls: some View {
        Group {
            switch engine.state {
            case .idle:
                startButton

            case .running:
                HStack(spacing: FFTheme.Spacing.md) {
                    controlButton(
                        label: "Pause",
                        icon: "pause.fill",
                        style: .secondary
                    ) {
                        engine.pause()
                    }
                    controlButton(
                        label: "Cancel",
                        icon: "xmark",
                        style: .destructive
                    ) {
                        cancelSession()
                    }
                }
                .padding(.horizontal, FFTheme.Spacing.xl)

            case .paused:
                HStack(spacing: FFTheme.Spacing.md) {
                    controlButton(
                        label: "Resume",
                        icon: "play.fill",
                        style: .primary
                    ) {
                        engine.resume()
                    }
                    controlButton(
                        label: "Cancel",
                        icon: "xmark",
                        style: .destructive
                    ) {
                        cancelSession()
                    }
                }
                .padding(.horizontal, FFTheme.Spacing.xl)

            case .completed:
                EmptyView()
            }
        }
    }

    private var startButton: some View {
        let color = FFTheme.sessionColor(for: engine.currentSessionType)

        return Button(action: startSession) {
            Text("Start \(engine.currentSessionType.displayName)")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: FFTheme.Radius.md)
                        .fill(color)
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 40)
        .accessibilityHint(
            "Starts a \(engine.currentSessionType.displayName.lowercased()) session"
        )
    }

    private enum ControlStyle { case primary, secondary, destructive }

    private func controlButton(
        label: String,
        icon: String,
        style: ControlStyle,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(foregroundColor(for: style))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: FFTheme.Radius.sm)
                        .fill(backgroundColor(for: style))
                        .overlay(
                            RoundedRectangle(cornerRadius: FFTheme.Radius.sm)
                                .stroke(borderColor(for: style), lineWidth: 0.5)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    private func foregroundColor(for style: ControlStyle) -> Color {
        switch style {
        case .primary: .white
        case .secondary: FFTheme.Text.secondary
        case .destructive: FFTheme.Accent.red.opacity(0.8)
        }
    }

    private func backgroundColor(for style: ControlStyle) -> Color {
        switch style {
        case .primary:
            FFTheme.sessionColor(for: engine.currentSessionType).opacity(0.15)
        case .secondary:
            Color.white.opacity(0.06)
        case .destructive:
            FFTheme.Accent.red.opacity(0.08)
        }
    }

    private func borderColor(for style: ControlStyle) -> Color {
        switch style {
        case .primary:
            FFTheme.sessionColor(for: engine.currentSessionType).opacity(0.3)
        case .secondary:
            FFTheme.Border.default
        case .destructive:
            FFTheme.Accent.red.opacity(0.2)
        }
    }

    // MARK: - Preset Sync

    private var presetDurations: [Int] {
        guard let preset = presets.first else { return [] }
        return [
            preset.focusDurationSeconds,
            preset.shortBreakDurationSeconds,
            preset.longBreakDurationSeconds,
        ]
    }

    private func syncPresetToEngine() {
        guard engine.state == .idle, let preset = presets.first else { return }
        engine.loadPreset(
            focusSeconds: preset.focusDurationSeconds,
            shortBreakSeconds: preset.shortBreakDurationSeconds,
            longBreakSeconds: preset.longBreakDurationSeconds
        )
    }

    // MARK: - Session Lifecycle

    private func startSession() {
        guard presets.first != nil else { return }

        // Intent framing: only for focus sessions with a task name
        let preference = coachPreferences.first
        let framingEnabled = preference?.aiCoachEnabled == true && preference?.intentFramingEnabled == true

        if engine.currentSessionType == .focus && framingEnabled && !taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let signal = BehaviorSignalComputer.compute(in: modelContext)
            let tone = preference?.tone ?? .encouraging
            let framing = CoachTemplateEngine.selectFramingTemplate(
                taskName: taskName,
                signal: signal,
                tone: tone,
                in: modelContext
            )
            currentFraming = framing
            showIntentFraming = true
        } else {
            startSessionDirectly()
        }
    }

    private func startSessionDirectly() {
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
        notificationService.scheduleCompletion(
            in: duration, sessionType: engine.currentSessionType
        )
    }

    private func cancelSession() {
        let startedAt: Date?
        if case .running(let date) = engine.state {
            startedAt = date
        } else if case .paused = engine.state {
            startedAt = Date.now.addingTimeInterval(
                -(engine.totalDuration - engine.remainingSeconds)
            )
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
        let result = SessionLogger.logCompletion(
            taskName: engine.taskName,
            sessionType: engine.currentSessionType,
            plannedDuration: engine.totalDuration,
            startedAt: Date.now.addingTimeInterval(-engine.totalDuration),
            in: modelContext
        )
        completionResult = result

        // Compute reflection if enabled
        let preference = coachPreferences.first
        let reflectionEnabled = preference?.aiCoachEnabled == true && preference?.postReflectionEnabled == true

        if reflectionEnabled && engine.currentSessionType == .focus {
            let signal = BehaviorSignalComputer.compute(in: modelContext)
            let tone = preference?.tone ?? .encouraging
            let actualMinutes = Int(engine.totalDuration / 60)
            let plannedMinutes = actualMinutes
            completionReflection = CoachTemplateEngine.selectReflectionTemplate(
                outcome: .completed,
                actualMinutes: actualMinutes,
                plannedMinutes: plannedMinutes,
                signal: signal,
                tone: tone,
                in: modelContext
            )
        } else {
            completionReflection = nil
        }

        showCompletion = true

        // Queue milestone for after completion sheet dismissal
        if let milestone = result.newMilestone {
            pendingMilestone = milestone
        }
    }

    private func dismissCompletion() {
        showCompletion = false
        guard engine.state == .completed else { return }
        if let preset = presets.first {
            engine.prepareNextSession(
                sessionsBeforeLongBreak: preset.sessionsBeforeLongBreak
            )
            engine.acknowledge()
            engine.loadPreset(
                focusSeconds: preset.focusDurationSeconds,
                shortBreakSeconds: preset.shortBreakDurationSeconds,
                longBreakSeconds: preset.longBreakDurationSeconds
            )
        } else {
            engine.acknowledge()
        }
        taskName = ""

        // Show milestone after a brief delay so sheets don't conflict
        if pendingMilestone != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showMilestone = true
            }
        }
    }

    private func logFramingInteraction(templateID: String, outcome: AIInteractionOutcome) {
        let log = AIInteractionLog(
            featureType: .framing,
            templateID: templateID,
            outcome: outcome
        )
        modelContext.insert(log)
        try? modelContext.save()
    }

    private func logReflectionInteraction(templateID: String, outcome: AIInteractionOutcome) {
        let log = AIInteractionLog(
            featureType: .reflection,
            templateID: templateID,
            outcome: outcome
        )
        modelContext.insert(log)
        try? modelContext.save()
    }
}

#Preview {
    TimerView()
        .environment(TimerEngine())
        .environment(NotificationService())
        .modelContainer(
            for: [TimerPreset.self, SessionLog.self, StreakState.self],
            inMemory: true
        )
}
