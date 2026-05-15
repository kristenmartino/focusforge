import XCTest
import SwiftData
@testable import FocusForge

@MainActor
final class SessionLoggerTests: XCTestCase {

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

    // MARK: - Helpers

    private func makeFocusResult(taskName: String = "Test task", durationSeconds: Int = 1500) -> SessionResult {
        SessionLogger.logCompletion(
            taskName: taskName,
            sessionType: .focus,
            plannedDuration: TimeInterval(durationSeconds),
            startedAt: Date.now.addingTimeInterval(-TimeInterval(durationSeconds)),
            in: context
        )
    }

    // MARK: - logCompletion — focus session rewards

    func test_logCompletion_focus_grantsXPEqualToMinutes() {
        // 25-minute focus session → base reward is 25 XP (xp = minutes).
        // First-ever session, so streak goes from 0 → 1, no streak bonus (multiplier
        // 1.0 for the first day).
        let result = makeFocusResult(durationSeconds: 1500)
        // streakBonusMultiplier(1) = 1.10, so totalXP = 25 * 1.10 - delta…
        // Actually re-reading SessionLogger: bonus is computed against streakDays
        // returned from recordFocusCompletion (which is 1 here), and bonusXP =
        // Int(25 * 1.10) - 25 = 27 - 25 = 2. totalXP = 25 + 2 = 27.
        XCTAssertEqual(result.xp, 27)
        XCTAssertEqual(result.bonusXP, 2)
        XCTAssertEqual(result.coins, 25, "Coins are not subject to streak bonus")
    }

    func test_logCompletion_focus_oneMinute_smallReward() {
        let result = makeFocusResult(durationSeconds: 60)
        XCTAssertEqual(result.xp, 1, "1 min focus = 1 base XP, no bonus uplift on integer math")
        XCTAssertEqual(result.coins, 1)
    }

    func test_logCompletion_focus_logsToSessionLog() {
        _ = makeFocusResult()
        let logs = (try? context.fetch(FetchDescriptor<SessionLog>())) ?? []
        XCTAssertEqual(logs.count, 1)
        XCTAssertEqual(logs.first?.outcome, .completed)
        XCTAssertEqual(logs.first?.sessionType, .focus)
        XCTAssertEqual(logs.first?.taskName, "Test task")
    }

    func test_logCompletion_focus_appliesStreakBonusOnFifthDay() {
        // Pre-seed streak at day 4; completing now bumps to day 5 → cap bonus 50%.
        // 25-min focus, base XP 25, multiplier 1.50 → totalXP 37, bonusXP 12.
        let state = StreakManager.fetchOrCreateStreakState(in: context)
        state.currentStreakDays = 4
        state.lastCompletedDate = TestSupport.daysAgo(1, atHour: 20)
        try? context.save()

        let result = makeFocusResult(durationSeconds: 1500)
        XCTAssertEqual(result.streakDays, 5)
        XCTAssertEqual(result.bonusXP, 12, "25 * 1.50 = 37.5 → Int 37, bonus = 37 - 25 = 12")
        XCTAssertEqual(result.xp, 37)
    }

    func test_logCompletion_focus_returnsMilestoneOnDayThree() {
        // Pre-seed streak at day 2; completing now hits day 3 → Early Bird.
        let state = StreakManager.fetchOrCreateStreakState(in: context)
        state.currentStreakDays = 2
        state.lastCompletedDate = TestSupport.daysAgo(1, atHour: 20)
        try? context.save()

        let result = makeFocusResult()
        XCTAssertEqual(result.streakDays, 3)
        XCTAssertNotNil(result.newMilestone)
        XCTAssertEqual(result.newMilestone?.milestoneID, "streak_3")
    }

    func test_logCompletion_focus_secondSessionSameDay_noStreakIncrement() {
        // First session today
        let first = makeFocusResult()
        XCTAssertEqual(first.streakDays, 1)

        // Second session same calendar day — streak stays at 1
        let second = makeFocusResult()
        XCTAssertEqual(second.streakDays, 1, "Second session same day does not extend streak")
    }

    // MARK: - logCompletion — break sessions

    func test_logCompletion_shortBreak_noXPNoCoins() {
        let result = SessionLogger.logCompletion(
            taskName: "",
            sessionType: .shortBreak,
            plannedDuration: 300,
            startedAt: Date.now.addingTimeInterval(-300),
            in: context
        )
        XCTAssertEqual(result.xp, 0)
        XCTAssertEqual(result.coins, 0)
        XCTAssertEqual(result.bonusXP, 0, "No bonus on breaks")
    }

    func test_logCompletion_longBreak_doesNotAdvanceStreak() {
        // Pre-seed streak at day 3
        let state = StreakManager.fetchOrCreateStreakState(in: context)
        state.currentStreakDays = 3
        state.lastCompletedDate = TestSupport.daysAgo(1, atHour: 20)

        let result = SessionLogger.logCompletion(
            taskName: "",
            sessionType: .longBreak,
            plannedDuration: 900,
            startedAt: Date.now.addingTimeInterval(-900),
            in: context
        )
        // The function still reports current streakDays, but does NOT advance it.
        XCTAssertEqual(result.streakDays, 3)
        XCTAssertEqual(state.currentStreakDays, 3, "Long break does not advance streak")
    }

    func test_logCompletion_break_logsToSessionLog() {
        _ = SessionLogger.logCompletion(
            taskName: "",
            sessionType: .shortBreak,
            plannedDuration: 300,
            startedAt: Date.now.addingTimeInterval(-300),
            in: context
        )
        let logs = (try? context.fetch(FetchDescriptor<SessionLog>())) ?? []
        XCTAssertEqual(logs.count, 1)
        XCTAssertEqual(logs.first?.sessionType, .shortBreak)
    }

    // MARK: - logAbandonment

    func test_logAbandonment_focus_logsAsAbandoned() {
        SessionLogger.logAbandonment(
            taskName: "Halted task",
            sessionType: .focus,
            plannedDuration: 1500,
            actualDuration: 600,
            startedAt: Date.now.addingTimeInterval(-600),
            in: context
        )
        let logs = (try? context.fetch(FetchDescriptor<SessionLog>())) ?? []
        XCTAssertEqual(logs.count, 1)
        XCTAssertEqual(logs.first?.outcome, .abandoned)
        XCTAssertEqual(logs.first?.xpEarned, 0, "Abandoned sessions give no XP")
        XCTAssertEqual(logs.first?.coinsEarned, 0, "Abandoned sessions give no coins")
        XCTAssertEqual(logs.first?.actualDurationSeconds, 600)
    }

    func test_logAbandonment_doesNotAdvanceStreak() {
        let state = StreakManager.fetchOrCreateStreakState(in: context)
        state.currentStreakDays = 5
        state.lastCompletedDate = TestSupport.daysAgo(1, atHour: 20)

        SessionLogger.logAbandonment(
            taskName: "",
            sessionType: .focus,
            plannedDuration: 1500,
            actualDuration: 300,
            startedAt: Date.now.addingTimeInterval(-300),
            in: context
        )
        XCTAssertEqual(state.currentStreakDays, 5, "Abandonment doesn't touch streak")
    }
}
