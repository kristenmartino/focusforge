import Foundation
import SwiftData
import FocusForgeCoachEngine

enum StreakNudgeScheduler {

    static func evaluateAndScheduleIfNeeded(
        in context: ModelContext,
        notificationService: NotificationService
    ) {
        let preference = AICoachPreferenceManager.fetchOrCreate(in: context)

        guard preference.aiCoachEnabled && preference.streakNudgeEnabled else { return }

        let signal = BehaviorSignalComputer.compute(in: context)

        // Only nudge when streak is actually at risk
        guard signal.streakRiskScore >= 0.3 else { return }

        // Check if user already completed a session today
        guard !hasCompletedSessionToday(in: context) else { return }

        // Check frequency cap and quiet hours
        let calendar = Calendar.current
        guard canSendNudge(preference: preference, now: .now, calendar: calendar) else { return }

        // Select nudge template
        let streakState = StreakManager.fetchOrCreateStreakState(in: context)
        let nudge = CoachTemplateEngine.selectNudgeTemplate(
            streakDays: streakState.currentStreakDays,
            signal: signal,
            tone: preference.tone
        )

        // Schedule notification
        notificationService.scheduleStreakNudge(
            title: nudge.title,
            body: "\(nudge.body) \(nudge.quickStartSuggestion)"
        )

        // Update cooldown
        preference.lastNudgeSentAt = .now
        preference.updatedAt = .now

        // Log interaction
        let log = AIInteractionLog(
            featureType: .nudge,
            templateID: nudge.templateID,
            outcome: .dismissed  // Default; updated if user opens from notification
        )
        context.insert(log)

        try? context.save()
    }

    static func canSendNudge(
        preference: AICoachPreference,
        now: Date,
        calendar: Calendar
    ) -> Bool {
        // Check frequency cap
        if let lastSent = preference.lastNudgeSentAt {
            let cooldown = preference.nudgeFrequency.cooldownSeconds
            if now.timeIntervalSince(lastSent) < cooldown {
                return false
            }
        }

        // Check quiet hours
        let currentHour = calendar.component(.hour, from: now)
        let start = preference.quietHoursStart
        let end = preference.quietHoursEnd

        if start < end {
            // e.g., quiet from 22 to 8 doesn't wrap (unusual config)
            if currentHour >= start && currentHour < end {
                return false
            }
        } else if start > end {
            // e.g., quiet from 22 to 8 (wraps midnight)
            if currentHour >= start || currentHour < end {
                return false
            }
        }
        // start == end means no quiet hours

        return true
    }

    private static func hasCompletedSessionToday(in context: ModelContext) -> Bool {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: .now)
        let focusType = SessionType.focus
        let completedOutcome = SessionOutcome.completed

        let descriptor = FetchDescriptor<SessionLog>(
            predicate: #Predicate<SessionLog> {
                $0.startedAt >= todayStart &&
                $0.sessionType == focusType &&
                $0.outcome == completedOutcome
            }
        )
        let count = (try? context.fetchCount(descriptor)) ?? 0
        return count > 0
    }
}
