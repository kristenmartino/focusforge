import Foundation
import SwiftData

/// In-app data backup. Generates a single JSON document representing the user's
/// entire FocusForge state (streak, character, inventory, sessions, quests,
/// preferences), suitable for AirDrop / Files / email export via the system
/// share sheet.
///
/// **Why this exists (v1.0).** CloudKit sync is deferred to v1.1, so a user
/// who upgrades their iPhone or wipes their device today loses every streak,
/// XP point, and unlocked cosmetic with no recovery path. For an app whose
/// retention thesis depends on the character growing as the user works, that
/// loss is catastrophic. Export is the belt-and-suspenders mitigation: even
/// without cloud sync, a user can self-backup before any risky operation.
///
/// **Restore is NOT in v1.0.** Generating + sharing a backup is a one-way
/// reassurance for now. Re-importing a backup into a fresh install is a v1.1
/// concern (requires handling ID conflicts, freeze accounting, etc.).
enum DataExportService {

    /// Serializes the current SwiftData store into a `FocusForgeBackup` and
    /// encodes it as pretty-printed JSON. Throws if encoding fails.
    @MainActor
    static func exportJSON(in context: ModelContext) throws -> Data {
        let backup = try buildBackup(in: context)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(backup)
    }

    /// Builds the structured backup (without encoding) — useful for tests
    /// that want to inspect contents directly.
    @MainActor
    static func buildBackup(in context: ModelContext) throws -> FocusForgeBackup {
        let streak = (try? context.fetch(FetchDescriptor<StreakState>()))?.first
        let loadout = (try? context.fetch(FetchDescriptor<CharacterLoadout>()))?.first
        let inventory = (try? context.fetch(FetchDescriptor<InventoryItem>())) ?? []
        let sessions = (try? context.fetch(
            FetchDescriptor<SessionLog>(sortBy: [SortDescriptor(\.startedAt)])
        )) ?? []
        let unlocks = (try? context.fetch(
            FetchDescriptor<UnlockEvent>(sortBy: [SortDescriptor(\.unlockedAt)])
        )) ?? []
        let quests = (try? context.fetch(FetchDescriptor<QuestProgress>())) ?? []
        let preference = (try? context.fetch(FetchDescriptor<AICoachPreference>()))?.first
        let preset = (try? context.fetch(FetchDescriptor<TimerPreset>()))?.first

        return FocusForgeBackup(
            exportedAt: .now,
            appVersion: Bundle.main.appVersionString,
            schemaVersion: "1.0.0",
            streak: streak.map(StreakStateBackup.init),
            characterLoadout: loadout.map(CharacterLoadoutBackup.init),
            inventory: inventory.map(InventoryItemBackup.init),
            sessions: sessions.map(SessionLogBackup.init),
            unlocks: unlocks.map(UnlockEventBackup.init),
            activeQuests: quests.map(QuestProgressBackup.init),
            coachPreferences: preference.map(CoachPreferenceBackup.init),
            timerPreset: preset.map(TimerPresetBackup.init)
        )
    }

    /// Suggested filename for the share sheet. ISO-style for sortability.
    static func defaultFilename(now: Date = .now) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "focusforge-backup-\(formatter.string(from: now)).json"
    }
}

// MARK: - Backup Document

/// Wire format for FocusForge backups. Plain Codable; intentionally mirrors
/// the SwiftData models but stays independent so the on-disk schema can
/// evolve without breaking exported files.
struct FocusForgeBackup: Codable, Equatable {
    let exportedAt: Date
    let appVersion: String
    let schemaVersion: String

    let streak: StreakStateBackup?
    let characterLoadout: CharacterLoadoutBackup?
    let inventory: [InventoryItemBackup]
    let sessions: [SessionLogBackup]
    let unlocks: [UnlockEventBackup]
    let activeQuests: [QuestProgressBackup]
    let coachPreferences: CoachPreferenceBackup?
    let timerPreset: TimerPresetBackup?
}

struct StreakStateBackup: Codable, Equatable {
    let currentStreakDays: Int
    let longestStreakDays: Int
    let lastCompletedDate: Date?
    let freezesAvailable: Int
    let freezesUsed: Int
    let totalXP: Int
    let totalCoins: Int
    let currentLevel: Int

    init(_ state: StreakState) {
        currentStreakDays = state.currentStreakDays
        longestStreakDays = state.longestStreakDays
        lastCompletedDate = state.lastCompletedDate
        freezesAvailable = state.freezesAvailable
        freezesUsed = state.freezesUsed
        totalXP = state.totalXP
        totalCoins = state.totalCoins
        currentLevel = state.currentLevel
    }
}

struct CharacterLoadoutBackup: Codable, Equatable {
    let headShape: String
    let hairStyle: String
    let eyeStyle: String
    let mouthStyle: String
    let skinColorHex: String
    let hairColorHex: String
    let bodyColorHex: String
    let equippedHorns: String?
    let equippedWings: String?
    let equippedWeapon: String?

    init(_ loadout: CharacterLoadout) {
        headShape = loadout.headShape
        hairStyle = loadout.hairStyle
        eyeStyle = loadout.eyeStyle
        mouthStyle = loadout.mouthStyle
        skinColorHex = loadout.skinColorHex
        hairColorHex = loadout.hairColorHex
        bodyColorHex = loadout.bodyColorHex
        equippedHorns = loadout.equippedHorns
        equippedWings = loadout.equippedWings
        equippedWeapon = loadout.equippedWeapon
    }
}

struct InventoryItemBackup: Codable, Equatable {
    let itemID: String
    let name: String
    let slot: String
    let rarity: String
    let ownership: String
    let coinCost: Int
    let acquiredAt: Date?

    init(_ item: InventoryItem) {
        itemID = item.itemID
        name = item.name
        slot = item.slot.rawValue
        rarity = item.rarity.rawValue
        ownership = item.ownership.rawValue
        coinCost = item.coinCost
        acquiredAt = item.acquiredAt
    }
}

struct SessionLogBackup: Codable, Equatable {
    let taskName: String
    let sessionType: String
    let startedAt: Date
    let endedAt: Date?
    let plannedDurationSeconds: Int
    let actualDurationSeconds: Int
    let outcome: String
    let xpEarned: Int
    let coinsEarned: Int

    init(_ log: SessionLog) {
        taskName = log.taskName
        sessionType = log.sessionType.rawValue
        startedAt = log.startedAt
        endedAt = log.endedAt
        plannedDurationSeconds = log.plannedDurationSeconds
        actualDurationSeconds = log.actualDurationSeconds
        outcome = log.outcome.rawValue
        xpEarned = log.xpEarned
        coinsEarned = log.coinsEarned
    }
}

struct UnlockEventBackup: Codable, Equatable {
    let itemID: String
    let source: String
    let unlockedAt: Date
    let streakDayAtUnlock: Int?

    init(_ event: UnlockEvent) {
        itemID = event.itemID
        source = event.source.rawValue
        unlockedAt = event.unlockedAt
        streakDayAtUnlock = event.streakDayAtUnlock
    }
}

struct QuestProgressBackup: Codable, Equatable {
    let questID: String
    let title: String
    let questType: String
    let targetCount: Int
    let currentCount: Int
    let isCompleted: Bool
    let isClaimed: Bool
    let rewardCoins: Int
    let rewardXP: Int
    let createdAt: Date
    let expiresAt: Date

    init(_ quest: QuestProgress) {
        questID = quest.questID
        title = quest.title
        questType = quest.questType.rawValue
        targetCount = quest.targetCount
        currentCount = quest.currentCount
        isCompleted = quest.isCompleted
        isClaimed = quest.isClaimed
        rewardCoins = quest.rewardCoins
        rewardXP = quest.rewardXP
        createdAt = quest.createdAt
        expiresAt = quest.expiresAt
    }
}

struct CoachPreferenceBackup: Codable, Equatable {
    let tone: String
    let nudgeFrequency: String
    let aiCoachEnabled: Bool
    let intentFramingEnabled: Bool
    let postReflectionEnabled: Bool
    let streakNudgeEnabled: Bool

    init(_ pref: AICoachPreference) {
        tone = pref.tone.rawValue
        nudgeFrequency = pref.nudgeFrequency.rawValue
        aiCoachEnabled = pref.aiCoachEnabled
        intentFramingEnabled = pref.intentFramingEnabled
        postReflectionEnabled = pref.postReflectionEnabled
        streakNudgeEnabled = pref.streakNudgeEnabled
    }
}

struct TimerPresetBackup: Codable, Equatable {
    let name: String
    let focusDurationSeconds: Int
    let shortBreakDurationSeconds: Int
    let longBreakDurationSeconds: Int
    let sessionsBeforeLongBreak: Int

    init(_ preset: TimerPreset) {
        name = preset.name
        focusDurationSeconds = preset.focusDurationSeconds
        shortBreakDurationSeconds = preset.shortBreakDurationSeconds
        longBreakDurationSeconds = preset.longBreakDurationSeconds
        sessionsBeforeLongBreak = preset.sessionsBeforeLongBreak
    }
}

// MARK: - Bundle helper

private extension Bundle {
    var appVersionString: String {
        let short = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "\(short) (\(build))"
    }
}
