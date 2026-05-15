import XCTest
import SwiftData
@testable import FocusForge

@MainActor
final class MilestoneEngineTests: XCTestCase {

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

    // MARK: - Milestone catalog sanity

    func test_milestoneCatalog_isSortedByStreakDay() {
        let days = MilestoneEngine.milestones.map(\.streakDay)
        XCTAssertEqual(days, days.sorted(), "Milestones must be in ascending streakDay order")
    }

    func test_milestoneCatalog_hasFiveMilestones() {
        XCTAssertEqual(MilestoneEngine.milestones.count, 5, "Launch catalog is 5 milestones")
    }

    func test_milestoneCatalog_includesExpectedStreakDays() {
        let days = Set(MilestoneEngine.milestones.map(\.streakDay))
        XCTAssertEqual(days, [3, 7, 14, 30, 60])
    }

    // MARK: - checkMilestone

    func test_checkMilestone_atZeroStreak_returnsNil() {
        let result = MilestoneEngine.checkMilestone(streakDays: 0, in: context)
        XCTAssertNil(result, "No milestone earned at 0 days")
    }

    func test_checkMilestone_belowFirstThreshold_returnsNil() {
        // First milestone is at day 3, so day 1 and day 2 should yield nil.
        XCTAssertNil(MilestoneEngine.checkMilestone(streakDays: 1, in: context))
        XCTAssertNil(MilestoneEngine.checkMilestone(streakDays: 2, in: context))
    }

    func test_checkMilestone_atDayThree_returnsEarlyBird() {
        let result = MilestoneEngine.checkMilestone(streakDays: 3, in: context)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.milestoneID, "streak_3")
        XCTAssertEqual(result?.name, "Early Bird")
    }

    func test_checkMilestone_atDaySeven_returnsWeekWarrior() {
        let result = MilestoneEngine.checkMilestone(streakDays: 7, in: context)
        XCTAssertEqual(result?.milestoneID, "streak_7")
    }

    func test_checkMilestone_alreadyUnlocked_returnsNil() {
        // First call should unlock.
        let first = MilestoneEngine.checkMilestone(streakDays: 3, in: context)
        XCTAssertNotNil(first)

        // Second call with same streakDay should NOT re-unlock.
        let second = MilestoneEngine.checkMilestone(streakDays: 3, in: context)
        XCTAssertNil(second, "Already-unlocked milestone should return nil")
    }

    func test_checkMilestone_crossingMultiple_returnsLatestUnlockedNotYetClaimed() {
        // Pre-condition: day 3 already unlocked
        _ = MilestoneEngine.checkMilestone(streakDays: 3, in: context)
        try? context.save()

        // Jump straight to day 14 — should unlock Day 14 (the highest not-yet-unlocked).
        let result = MilestoneEngine.checkMilestone(streakDays: 14, in: context)
        XCTAssertEqual(result?.streakDay, 14, "Returns highest applicable")
    }

    func test_checkMilestone_atDaySixtyFirst_returnsIronWill() {
        // 61 days is above all thresholds → still the highest (Iron Will, day 60).
        let result = MilestoneEngine.checkMilestone(streakDays: 61, in: context)
        XCTAssertEqual(result?.milestoneID, "streak_60")
        XCTAssertEqual(result?.name, "Iron Will")
    }

    func test_checkMilestone_grantsInventoryItemAndUnlockEvent() {
        _ = MilestoneEngine.checkMilestone(streakDays: 3, in: context)
        try? context.save()

        // UnlockEvent should now exist
        let events = (try? context.fetch(FetchDescriptor<UnlockEvent>())) ?? []
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.itemID, "horn1", "Early Bird grants Imp Points (horn1)")
        XCTAssertEqual(events.first?.streakDayAtUnlock, 3)

        // InventoryItem should be marked .new
        let items = (try? context.fetch(FetchDescriptor<InventoryItem>())) ?? []
        let imp = items.first(where: { $0.itemID == "horn1" })
        XCTAssertNotNil(imp)
        XCTAssertEqual(imp?.ownership, .new)
    }

    func test_checkMilestone_grantsStreakFreeze() {
        let stateBefore = StreakManager.fetchOrCreateStreakState(in: context)
        stateBefore.freezesAvailable = 0
        try? context.save()

        _ = MilestoneEngine.checkMilestone(streakDays: 3, in: context)
        try? context.save()

        let stateAfter = StreakManager.fetchOrCreateStreakState(in: context)
        XCTAssertEqual(stateAfter.freezesAvailable, 1, "Day 3 milestone grants +1 streak freeze")
    }
}
