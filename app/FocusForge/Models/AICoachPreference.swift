import Foundation
import SwiftData
import FocusForgeCoachEngine

@Model
final class AICoachPreference {
    var tone: CoachTone
    var nudgeFrequency: NudgeFrequency
    var aiCoachEnabled: Bool
    var intentFramingEnabled: Bool
    var postReflectionEnabled: Bool
    var streakNudgeEnabled: Bool
    var quietHoursStart: Int  // hour 0-23
    var quietHoursEnd: Int    // hour 0-23
    var lastNudgeSentAt: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        tone: CoachTone = .encouraging,
        nudgeFrequency: NudgeFrequency = .medium,
        aiCoachEnabled: Bool = true,
        intentFramingEnabled: Bool = true,
        postReflectionEnabled: Bool = true,
        streakNudgeEnabled: Bool = true,
        quietHoursStart: Int = 22,
        quietHoursEnd: Int = 8,
        lastNudgeSentAt: Date? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.tone = tone
        self.nudgeFrequency = nudgeFrequency
        self.aiCoachEnabled = aiCoachEnabled
        self.intentFramingEnabled = intentFramingEnabled
        self.postReflectionEnabled = postReflectionEnabled
        self.streakNudgeEnabled = streakNudgeEnabled
        self.quietHoursStart = quietHoursStart
        self.quietHoursEnd = quietHoursEnd
        self.lastNudgeSentAt = lastNudgeSentAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
