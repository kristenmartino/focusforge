import Foundation
import Observation

enum SessionPhase: String, CaseIterable {
    case focus
    case shortBreak
    case longBreak

    var displayName: String {
        switch self {
        case .focus: return "Focus"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }
}

enum TimerState: Equatable {
    case idle
    case running(startedAt: Date)
    case paused(remaining: TimeInterval)
    case completed
}

@Observable
final class TimerEngine {
    // MARK: - State

    private(set) var state: TimerState = .idle
    private(set) var currentSessionType: SessionPhase = .focus
    private(set) var totalDuration: TimeInterval = 1500
    private(set) var remainingSeconds: TimeInterval = 1500
    private(set) var completedFocusCount: Int = 0

    var taskName: String = ""

    var sessionStartedAt: Date? {
        if case .running(let startedAt) = state { return startedAt }
        return nil
    }

    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return remainingSeconds / totalDuration
    }

    var formattedTime: String {
        let total = max(0, Int(ceil(remainingSeconds)))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var accessibleTimeDescription: String {
        let total = max(0, Int(ceil(remainingSeconds)))
        let minutes = total / 60
        let seconds = total % 60
        if minutes > 0 && seconds > 0 {
            return "\(minutes) minutes, \(seconds) seconds"
        } else if minutes > 0 {
            return "\(minutes) minutes"
        } else {
            return "\(seconds) seconds"
        }
    }

    // MARK: - Private

    private var ticker: Timer?

    // MARK: - Actions

    func start(duration: TimeInterval, sessionType: SessionPhase) {
        totalDuration = duration
        remainingSeconds = duration
        currentSessionType = sessionType
        let now = Date.now
        state = .running(startedAt: now)
        startTicking()
    }

    func pause() {
        guard case .running(let startedAt) = state else { return }
        stopTicking()
        let elapsed = Date.now.timeIntervalSince(startedAt)
        let remaining = max(0, totalDuration - elapsed)
        remainingSeconds = remaining
        state = .paused(remaining: remaining)
    }

    func resume() {
        guard case .paused(let remaining) = state else { return }
        remainingSeconds = remaining
        let now = Date.now
        let syntheticStart = now.addingTimeInterval(-totalDuration + remaining)
        state = .running(startedAt: syntheticStart)
        startTicking()
    }

    func cancel() {
        stopTicking()
        let actualDuration: TimeInterval
        if case .running(let startedAt) = state {
            actualDuration = Date.now.timeIntervalSince(startedAt)
        } else if case .paused(let remaining) = state {
            actualDuration = totalDuration - remaining
        } else {
            actualDuration = 0
        }
        _ = actualDuration
        state = .idle
        remainingSeconds = totalDuration
    }

    func acknowledge() {
        guard state == .completed else { return }
        state = .idle
    }

    func prepareNextSession(sessionsBeforeLongBreak: Int) {
        let nextType: SessionPhase
        switch currentSessionType {
        case .focus:
            nextType = (completedFocusCount % sessionsBeforeLongBreak == 0)
                ? .longBreak : .shortBreak
        case .shortBreak, .longBreak:
            nextType = .focus
        }
        currentSessionType = nextType
    }

    func loadPreset(focusSeconds: Int, shortBreakSeconds: Int, longBreakSeconds: Int) {
        guard state == .idle else { return }
        switch currentSessionType {
        case .focus:
            totalDuration = TimeInterval(focusSeconds)
        case .shortBreak:
            totalDuration = TimeInterval(shortBreakSeconds)
        case .longBreak:
            totalDuration = TimeInterval(longBreakSeconds)
        }
        remainingSeconds = totalDuration
    }

    func recalculateOnForeground() {
        guard case .running(let startedAt) = state else { return }
        let elapsed = Date.now.timeIntervalSince(startedAt)
        remainingSeconds = max(0, totalDuration - elapsed)
        if remainingSeconds <= 0 {
            complete()
        }
    }

    // MARK: - Private

    private func startTicking() {
        stopTicking()
        ticker = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func stopTicking() {
        ticker?.invalidate()
        ticker = nil
    }

    private func tick() {
        guard case .running(let startedAt) = state else { return }
        let elapsed = Date.now.timeIntervalSince(startedAt)
        remainingSeconds = max(0, totalDuration - elapsed)
        if remainingSeconds <= 0 {
            complete()
        }
    }

    private func complete() {
        stopTicking()
        remainingSeconds = 0
        if currentSessionType == .focus {
            completedFocusCount += 1
        }
        state = .completed
    }
}
