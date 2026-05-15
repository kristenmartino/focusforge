import XCTest
import SwiftData
@testable import FocusForge

@MainActor
final class StreakManagerTests: XCTestCase {

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

    // MARK: - streakBonusMultiplier

    func test_streakBonusMultiplier_zero_returnsOne() {
        XCTAssertEqual(StreakManager.streakBonusMultiplier(for: 0), 1.0, accuracy: 0.001)
    }

    func test_streakBonusMultiplier_oneDay_returnsTenPercentBonus() {
        XCTAssertEqual(StreakManager.streakBonusMultiplier(for: 1), 1.10, accuracy: 0.001)
    }

    func test_streakBonusMultiplier_fourDays_returnsFortyPercentBonus() {
        XCTAssertEqual(StreakManager.streakBonusMultiplier(for: 4), 1.40, accuracy: 0.001)
    }

    func test_streakBonusMultiplier_fiveDays_capsAtFiftyPercent() {
        XCTAssertEqual(StreakManager.streakBonusMultiplier(for: 5), 1.50, accuracy: 0.001)
    }

    func test_streakBonusMultiplier_hundredDays_staysCappedAtFiftyPercent() {
        XCTAssertEqual(StreakManager.streakBonusMultiplier(for: 100), 1.50, accuracy: 0.001)
    }

    // MARK: - recordFocusCompletion — state transitions

    func test_recordFocusCompletion_firstEverSession_setsStreakToOne() {
        // No StreakState exists yet — function should create one and set to 1.
        let result = StreakManager.recordFocusCompletion(in: context)
        XCTAssertEqual(result, 1)

        let state = StreakManager.fetchOrCreateStreakState(in: context)
        XCTAssertEqual(state.currentStreakDays, 1)
        XCTAssertEqual(state.longestStreakDays, 1)
        XCTAssertNotNil(state.lastCompletedDate)
    }

    func test_recordFocusCompletion_sameCalendarDay_doesNotIncrement() {
        let state = StreakManager.fetchOrCreateStreakState(in: context)
        state.currentStreakDays = 5
        state.lastCompletedDate = .now  // earlier today
        state.longestStreakDays = 5

        let result = StreakManager.recordFocusCompletion(in: context)
        XCTAssertEqual(result, 5, "Same calendar day should not increment")
        XCTAssertEqual(state.currentStreakDays, 5)
    }

    func test_recordFocusCompletion_yesterday_incrementsByOne() {
        let state = StreakManager.fetchOrCreateStreakState(in: context)
        state.currentStreakDays = 3
        state.lastCompletedDate = TestSupport.daysAgo(1, atHour: 20)
        state.longestStreakDays = 3

        let result = StreakManager.recordFocusCompletion(in: context)
        XCTAssertEqual(result, 4)
        XCTAssertEqual(state.currentStreakDays, 4)
    }

    func test_recordFocusCompletion_twoDaysAgo_noFreezes_resetsToOne() {
        let state = StreakManager.fetchOrCreateStreakState(in: context)
        state.currentStreakDays = 10
        state.lastCompletedDate = TestSupport.daysAgo(2)
        state.freezesAvailable = 0
        state.longestStreakDays = 10

        let result = StreakManager.recordFocusCompletion(in: context)
        XCTAssertEqual(result, 1, "No freezes → streak resets")
        XCTAssertEqual(state.currentStreakDays, 1)
        // Longest preserved even after reset
        XCTAssertEqual(state.longestStreakDays, 10)
    }

    func test_recordFocusCompletion_twoDaysAgo_withFreeze_consumesAndIncrements() {
        let state = StreakManager.fetchOrCreateStreakState(in: context)
        state.currentStreakDays = 10
        state.lastCompletedDate = TestSupport.daysAgo(2)
        state.freezesAvailable = 2
        state.freezesUsed = 0
        state.longestStreakDays = 10

        let result = StreakManager.recordFocusCompletion(in: context)
        XCTAssertEqual(result, 11, "Freeze consumed → streak continues +1")
        XCTAssertEqual(state.currentStreakDays, 11)
        XCTAssertEqual(state.freezesAvailable, 1, "One freeze consumed")
        XCTAssertEqual(state.freezesUsed, 1)
    }

    func test_recordFocusCompletion_fiveDayGap_withFreeze_stillConsumesOnlyOne() {
        // Important: the freeze logic doesn't iterate; one freeze covers any gap of 2+ days.
        // That's a design choice worth pinning down: a single freeze protects against a
        // long absence, not just a one-day slip.
        let state = StreakManager.fetchOrCreateStreakState(in: context)
        state.currentStreakDays = 7
        state.lastCompletedDate = TestSupport.daysAgo(5)
        state.freezesAvailable = 1
        state.longestStreakDays = 7

        let result = StreakManager.recordFocusCompletion(in: context)
        XCTAssertEqual(result, 8)
        XCTAssertEqual(state.freezesAvailable, 0)
        XCTAssertEqual(state.freezesUsed, 1)
    }

    func test_recordFocusCompletion_updatesLongestStreak() {
        let state = StreakManager.fetchOrCreateStreakState(in: context)
        state.currentStreakDays = 9
        state.lastCompletedDate = TestSupport.daysAgo(1)
        state.longestStreakDays = 9

        _ = StreakManager.recordFocusCompletion(in: context)
        XCTAssertEqual(state.currentStreakDays, 10)
        XCTAssertEqual(state.longestStreakDays, 10)
    }

    func test_recordFocusCompletion_preservesLongestWhenCurrentNotMax() {
        let state = StreakManager.fetchOrCreateStreakState(in: context)
        state.currentStreakDays = 3
        state.lastCompletedDate = TestSupport.daysAgo(1)
        state.longestStreakDays = 30  // historical max

        _ = StreakManager.recordFocusCompletion(in: context)
        XCTAssertEqual(state.currentStreakDays, 4)
        XCTAssertEqual(state.longestStreakDays, 30, "Historical max preserved")
    }

    // MARK: - applyRewards

    func test_applyRewards_underLevelThreshold_returnsFalse() {
        let state = StreakManager.fetchOrCreateStreakState(in: context)
        state.totalXP = 0
        state.currentLevel = 1

        let leveledUp = StreakManager.applyRewards(xp: 50, coins: 10, in: context)
        XCTAssertFalse(leveledUp)
        XCTAssertEqual(state.totalXP, 50)
        XCTAssertEqual(state.totalCoins, 10)
        XCTAssertEqual(state.currentLevel, 1, "50 XP < 100 → still level 1")
    }

    func test_applyRewards_crossesLevelThreshold_returnsTrue() {
        let state = StreakManager.fetchOrCreateStreakState(in: context)
        state.totalXP = 90
        state.currentLevel = 1

        let leveledUp = StreakManager.applyRewards(xp: 20, coins: 0, in: context)
        XCTAssertTrue(leveledUp, "Crossing 100 XP → level up")
        XCTAssertEqual(state.totalXP, 110)
        XCTAssertEqual(state.currentLevel, 2)
    }

    func test_applyRewards_largeXPCrossesMultipleLevels_jumpsLevel() {
        // 0 XP, level 1 → +300 XP should jump to level 4 (totalXP/100 + 1 = 4)
        let state = StreakManager.fetchOrCreateStreakState(in: context)
        state.totalXP = 0
        state.currentLevel = 1

        let leveledUp = StreakManager.applyRewards(xp: 300, coins: 0, in: context)
        XCTAssertTrue(leveledUp)
        XCTAssertEqual(state.totalXP, 300)
        XCTAssertEqual(state.currentLevel, 4)
    }
}
