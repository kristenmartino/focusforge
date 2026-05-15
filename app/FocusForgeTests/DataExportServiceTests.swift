import XCTest
import SwiftData
@testable import FocusForge

@MainActor
final class DataExportServiceTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext { container.mainContext }

    override func setUp() async throws {
        try await super.setUp()
        container = try TestSupport.makeContainer()
    }

    override func tearDown() async throws {
        container = nil
        try await super.tearDown()
    }

    // MARK: - Empty store

    func test_buildBackup_emptyStore_returnsSkeletonWithMetadata() throws {
        let backup = try DataExportService.buildBackup(in: context)

        // Metadata always present
        XCTAssertEqual(backup.schemaVersion, "1.0.0")
        XCTAssertFalse(backup.appVersion.isEmpty)

        // No entities → all collections empty, all singletons nil
        XCTAssertNil(backup.streak)
        XCTAssertNil(backup.characterLoadout)
        XCTAssertEqual(backup.inventory.count, 0)
        XCTAssertEqual(backup.sessions.count, 0)
        XCTAssertEqual(backup.unlocks.count, 0)
        XCTAssertEqual(backup.activeQuests.count, 0)
        XCTAssertNil(backup.coachPreferences)
        XCTAssertNil(backup.timerPreset)
    }

    // MARK: - Seeded data round-trip

    func test_buildBackup_capturesStreakState() throws {
        let state = StreakManager.fetchOrCreateStreakState(in: context)
        state.currentStreakDays = 12
        state.longestStreakDays = 30
        state.freezesAvailable = 2
        state.freezesUsed = 1
        state.totalXP = 350
        state.totalCoins = 175
        state.currentLevel = 4
        try? context.save()

        let backup = try DataExportService.buildBackup(in: context)
        let s = try XCTUnwrap(backup.streak)
        XCTAssertEqual(s.currentStreakDays, 12)
        XCTAssertEqual(s.longestStreakDays, 30)
        XCTAssertEqual(s.freezesAvailable, 2)
        XCTAssertEqual(s.freezesUsed, 1)
        XCTAssertEqual(s.totalXP, 350)
        XCTAssertEqual(s.totalCoins, 175)
        XCTAssertEqual(s.currentLevel, 4)
    }

    func test_buildBackup_capturesSessionLogs() throws {
        // Complete two focus sessions, abandon one
        _ = SessionLogger.logCompletion(
            taskName: "Task A",
            sessionType: .focus,
            plannedDuration: 1500,
            startedAt: .now.addingTimeInterval(-1500),
            in: context
        )
        SessionLogger.logAbandonment(
            taskName: "Task B",
            sessionType: .focus,
            plannedDuration: 1500,
            actualDuration: 200,
            startedAt: .now.addingTimeInterval(-200),
            in: context
        )

        let backup = try DataExportService.buildBackup(in: context)
        XCTAssertEqual(backup.sessions.count, 2)
        let completed = backup.sessions.first(where: { $0.outcome == "completed" })
        XCTAssertEqual(completed?.taskName, "Task A")
        XCTAssertGreaterThan(completed?.xpEarned ?? 0, 0)
        let abandoned = backup.sessions.first(where: { $0.outcome == "abandoned" })
        XCTAssertEqual(abandoned?.taskName, "Task B")
        XCTAssertEqual(abandoned?.xpEarned, 0)
    }

    func test_buildBackup_capturesUnlockEvents() throws {
        // Unlock the day-3 milestone
        _ = MilestoneEngine.checkMilestone(streakDays: 3, in: context)
        try? context.save()

        let backup = try DataExportService.buildBackup(in: context)
        XCTAssertEqual(backup.unlocks.count, 1)
        XCTAssertEqual(backup.unlocks.first?.itemID, "horn1")
        XCTAssertEqual(backup.unlocks.first?.streakDayAtUnlock, 3)
    }

    // MARK: - JSON encoding

    func test_exportJSON_producesValidParseableJSON() throws {
        let state = StreakManager.fetchOrCreateStreakState(in: context)
        state.currentStreakDays = 5
        try? context.save()

        let data = try DataExportService.exportJSON(in: context)

        // Decodes round-trip
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(FocusForgeBackup.self, from: data)
        XCTAssertEqual(decoded.streak?.currentStreakDays, 5)
        XCTAssertEqual(decoded.schemaVersion, "1.0.0")
    }

    func test_exportJSON_isPrettyPrinted() throws {
        let data = try DataExportService.exportJSON(in: context)
        let raw = String(data: data, encoding: .utf8) ?? ""
        // Pretty-printed JSON has newlines and 2-space indentation.
        XCTAssertTrue(raw.contains("\n"), "Pretty-printed JSON should contain newlines")
        XCTAssertTrue(raw.contains("  "), "Pretty-printed JSON should be indented")
    }

    func test_defaultFilename_isISODateBased() {
        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)  // 2023-11-14 UTC
        let name = DataExportService.defaultFilename(now: fixedDate)
        XCTAssertTrue(name.hasPrefix("focusforge-backup-"))
        XCTAssertTrue(name.hasSuffix(".json"))
        // The exact date depends on local timezone, but the format YYYY-MM-DD
        // means the body is 10 chars and the date pieces are well-formed.
        let dateBody = name
            .replacingOccurrences(of: "focusforge-backup-", with: "")
            .replacingOccurrences(of: ".json", with: "")
        XCTAssertEqual(dateBody.count, 10, "YYYY-MM-DD = 10 chars")
        XCTAssertEqual(dateBody.filter { $0 == "-" }.count, 2)
    }
}
