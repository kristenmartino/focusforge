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
    @State private var showRewardOverlay = false
    @State private var completionResult: SessionResult?
    @State private var completionReflection: ReflectionResult?
    @State private var showMilestone = false
    @State private var pendingMilestone: MilestoneReward?
    @State private var showIntentFraming = false
    @State private var currentFraming: FramingResult?

    private let ringSize: CGFloat = 260

    var body: some View {
        NavigationStack {
            ZStack {
                // Focus mode background (always present, fades under reward)
                FocusBackground(
                    accentColor: FFTheme.sessionColor(for: engine.currentSessionType)
                )

                // Timer content — hidden during reward overlay
                if !showRewardOverlay {
                    timerContent
                        .transition(.opacity)
                }

                // Reward overlay (replaces timer in-place with cinematic sequence)
                if showRewardOverlay, let result = completionResult {
                    RewardOverlayView(
                        sessionType: engine.currentSessionType,
                        duration: engine.totalDuration,
                        result: result,
                        ringSize: ringSize,
                        reflection: completionReflection,
                        onReflectionFeedback: { accepted in
                            if let reflection = completionReflection {
                                logReflectionInteraction(
                                    templateID: reflection.templateID,
                                    outcome: accepted ? .accepted : .dismissed
                                )
                            }
                        },
                        onDismiss: dismissReward
                    )
                    .transition(.opacity)
                    .zIndex(10)
                }
            }
            .navigationTitle(showRewardOverlay ? "" : "Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !showRewardOverlay {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            SessionHistoryView()
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundStyle(FFTheme.Text.secondary)
                        }
                        .accessibilityLabel("Session history")
                        .accessibilityHint("Shows your past focus and break sessions")
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

    // MARK: - Timer Content

    private var timerContent: some View {
        VStack(spacing: 0) {
            Spacer()

            StreakBadgeView()
                .padding(.bottom, FFTheme.Spacing.sm)

            Text(engine.currentSessionType.displayName.uppercased())
                .font(.sessionLabel)
                .foregroundStyle(FFTheme.Text.tertiary)
                .tracking(2)
                .padding(.bottom, FFTheme.Spacing.lg)

            ZStack {
                GlowProgressRingView(
                    progress: engine.progress,
                    sessionType: engine.currentSessionType,
                    size: ringSize
                )

                Text(engine.formattedTime)
                    .font(.timerDisplay)
                    .foregroundStyle(FFTheme.Text.primary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .accessibilityLabel(
                        "Time remaining: \(engine.accessibleTimeDescription)"
                    )
            }
            .padding(.bottom, FFTheme.Spacing.lg)

            if engine.state == .idle {
                taskNameField
            } else if !taskName.isEmpty {
                Text(taskName)
                    .font(.subheadline)
                    .foregroundStyle(FFTheme.Text.tertiary)
            }

            Spacer()

            timerControls
                .padding(.bottom, FFTheme.Spacing.xxxl)

            Spacer()
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
            .padding(.horizontal, FFTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: FFTheme.Radius.sm)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: FFTheme.Radius.sm)
                            .stroke(FFTheme.Border.default, lineWidth: 0.5)
                    )
            )
        }
        .padding(.horizontal, FFTheme.Spacing.xxxl)
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
                    controlButton(label: "Pause", icon: "pause.fill", style: .secondary) {
                        engine.pause()
                    }
                    controlButton(label: "Cancel", icon: "xmark", style: .destructive) {
                        cancelSession()
                    }
                }
                .padding(.horizontal, FFTheme.Spacing.xl)
            case .paused:
                HStack(spacing: FFTheme.Spacing.md) {
                    controlButton(label: "Resume", icon: "play.fill", style: .primary) {
                        engine.resume()
                    }
                    controlButton(label: "Cancel", icon: "xmark", style: .destructive) {
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
                .font(.body.weight(.medium))
                .foregroundStyle(FFTheme.Text.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: FFTheme.Radius.md)
                        .fill(color)
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, FFTheme.Spacing.xxxl)
        .accessibilityHint(
            "Starts a \(engine.currentSessionType.displayName.lowercased()) session"
        )
    }

    private enum ControlStyle { case primary, secondary, destructive }

    private func controlButton(
        label: String, icon: String, style: ControlStyle,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(foreground(for: style))
                .frame(maxWidth: .infinity)
                .padding(.vertical, FFTheme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: FFTheme.Radius.sm)
                        .fill(background(for: style))
                        .overlay(
                            RoundedRectangle(cornerRadius: FFTheme.Radius.sm)
                                .stroke(border(for: style), lineWidth: 0.5)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    private func foreground(for s: ControlStyle) -> Color {
        switch s {
        case .primary: FFTheme.Text.primary
        case .secondary: FFTheme.Text.secondary
        case .destructive: FFTheme.Accent.red.opacity(0.8)
        }
    }
    private func background(for s: ControlStyle) -> Color {
        switch s {
        case .primary: FFTheme.sessionColor(for: engine.currentSessionType).opacity(0.15)
        case .secondary: Color.white.opacity(0.06)
        case .destructive: FFTheme.Accent.red.opacity(0.08)
        }
    }
    private func border(for s: ControlStyle) -> Color {
        switch s {
        case .primary: FFTheme.sessionColor(for: engine.currentSessionType).opacity(0.3)
        case .secondary: FFTheme.Border.default
        case .destructive: FFTheme.Accent.red.opacity(0.2)
        }
    }

    // MARK: - Preset Sync

    private var presetDurations: [Int] {
        guard let preset = presets.first else { return [] }
        return [preset.focusDurationSeconds, preset.shortBreakDurationSeconds, preset.longBreakDurationSeconds]
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
        let duration: TimeInterval = switch engine.currentSessionType {
        case .focus: TimeInterval(preset.focusDurationSeconds)
        case .shortBreak: TimeInterval(preset.shortBreakDurationSeconds)
        case .longBreak: TimeInterval(preset.longBreakDurationSeconds)
        }
        engine.taskName = taskName
        engine.start(duration: duration, sessionType: engine.currentSessionType)
        notificationService.scheduleCompletion(in: duration, sessionType: engine.currentSessionType)
        AnalyticsService.track(.sessionStarted, parameters: [
            "phase": engine.currentSessionType.rawValue,
            "planned_minutes": Int(duration / 60),
            "task_named": !taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ])
    }

    private func cancelSession() {
        let startedAt: Date?
        if case .running(let date) = engine.state { startedAt = date }
        else if case .paused = engine.state {
            startedAt = Date.now.addingTimeInterval(-(engine.totalDuration - engine.remainingSeconds))
        } else { startedAt = nil }

        let plannedDuration = engine.totalDuration
        let actualDuration = engine.totalDuration - engine.remainingSeconds
        let sessionType = engine.currentSessionType
        engine.cancel()
        notificationService.cancelPending()

        if let startedAt {
            SessionLogger.logAbandonment(
                taskName: taskName, sessionType: sessionType,
                plannedDuration: plannedDuration, actualDuration: actualDuration,
                startedAt: startedAt, in: modelContext
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
                    in: engine.remainingSeconds, sessionType: engine.currentSessionType
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

        withAnimation(.easeOut(duration: 0.3)) {
            showRewardOverlay = true
        }

        if let milestone = result.newMilestone {
            pendingMilestone = milestone
        }
    }

    private func dismissReward() {
        withAnimation(.easeOut(duration: 0.3)) {
            showRewardOverlay = false
        }
        completionResult = nil
        completionReflection = nil

        if let preset = presets.first {
            engine.prepareNextSession(sessionsBeforeLongBreak: preset.sessionsBeforeLongBreak)
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
