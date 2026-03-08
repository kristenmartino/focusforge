import Foundation
import SwiftData

@Model
final class TimerPreset {
    var name: String
    var focusDurationSeconds: Int
    var shortBreakDurationSeconds: Int
    var longBreakDurationSeconds: Int
    var sessionsBeforeLongBreak: Int
    var isDefault: Bool

    init(
        name: String = "Default",
        focusDurationSeconds: Int = 1500,
        shortBreakDurationSeconds: Int = 300,
        longBreakDurationSeconds: Int = 900,
        sessionsBeforeLongBreak: Int = 4,
        isDefault: Bool = true
    ) {
        self.name = name
        self.focusDurationSeconds = focusDurationSeconds
        self.shortBreakDurationSeconds = shortBreakDurationSeconds
        self.longBreakDurationSeconds = longBreakDurationSeconds
        self.sessionsBeforeLongBreak = sessionsBeforeLongBreak
        self.isDefault = isDefault
    }
}
