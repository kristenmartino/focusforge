import Foundation
import SwiftData

enum SessionType: String, Codable {
    case focus
    case shortBreak
    case longBreak
}

enum SessionOutcome: String, Codable {
    case completed
    case abandoned
}

@Model
final class SessionLog {
    var taskName: String
    var sessionType: SessionType
    var startedAt: Date
    var endedAt: Date?
    var plannedDurationSeconds: Int
    var actualDurationSeconds: Int
    var outcome: SessionOutcome
    var xpEarned: Int
    var coinsEarned: Int

    init(
        taskName: String = "",
        sessionType: SessionType = .focus,
        startedAt: Date = .now,
        endedAt: Date? = nil,
        plannedDurationSeconds: Int = 1500,
        actualDurationSeconds: Int = 0,
        outcome: SessionOutcome = .completed,
        xpEarned: Int = 0,
        coinsEarned: Int = 0
    ) {
        self.taskName = taskName
        self.sessionType = sessionType
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.plannedDurationSeconds = plannedDurationSeconds
        self.actualDurationSeconds = actualDurationSeconds
        self.outcome = outcome
        self.xpEarned = xpEarned
        self.coinsEarned = coinsEarned
    }
}
