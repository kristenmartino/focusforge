import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(filter: #Predicate<QuestProgress> { $0.isCompleted && !$0.isClaimed })
    private var claimableQuests: [QuestProgress]
    @Query private var coachPreferences: [AICoachPreference]
    @Query private var streakStates: [StreakState]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedTab = 0
    @State private var showRescueBanner = false
    @State private var bannerDismissed = false

    /// P1-16: debug-only override so the streak rescue banner is testable
    /// without engineering specific BehaviorSignalComputer conditions.
    /// Toggled from SettingsView's Debug section.
    @AppStorage("debug.forceStreakRescueBanner") private var debugForceStreakRescueBanner = false

    /// P2-6: cross-view deep link target. RewardOverlayView writes "quests"
    /// when the user taps the "Claim in the Quests tab" link; this view
    /// switches the selected tab and clears the flag.
    @AppStorage("pendingDeepLink") private var pendingDeepLink: String = ""

    private var shouldShowBanner: Bool {
        guard !bannerDismissed else { return false }
        #if DEBUG
        if debugForceStreakRescueBanner {
            return (streakStates.first?.currentStreakDays ?? 0) > 0
        }
        #endif
        guard let pref = coachPreferences.first,
              pref.aiCoachEnabled && pref.streakNudgeEnabled else { return false }
        guard let streak = streakStates.first,
              streak.currentStreakDays > 0 else { return false }

        let signal = BehaviorSignalComputer.compute(in: modelContext)
        return signal.streakRiskScore >= 0.3
    }

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $selectedTab) {
                TimerView()
                    .tabItem {
                        Label("Timer", systemImage: "timer")
                    }
                    .tag(0)

                CharacterView()
                    .tabItem {
                        Label("Character", systemImage: "person.fill")
                    }
                    .tag(1)

                QuestListView()
                    .tabItem {
                        Label("Quests", systemImage: "scroll")
                    }
                    .tag(2)
                    .badge(claimableQuests.count)

                StatsView()
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar.fill")
                    }
                    .tag(3)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(4)
            }
            .darkTabBarAppearance()
            .tint(FFTheme.Accent.blue)

            if shouldShowBanner {
                StreakRescueBannerView(
                    streakDays: streakStates.first?.currentStreakDays ?? 0,
                    onStartSession: {
                        bannerDismissed = true
                        selectedTab = 0
                    },
                    onDismiss: {
                        bannerDismissed = true
                    }
                )
                .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                .padding(.top, 4)
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.3), value: shouldShowBanner)
        .preferredColorScheme(.dark)
        .onChange(of: pendingDeepLink) { _, newValue in
            // P2-6: act on any pending deep link, then clear so it doesn't refire.
            switch newValue {
            case "quests":
                selectedTab = 2
            case "character":
                selectedTab = 1
            case "stats":
                selectedTab = 3
            case "settings":
                selectedTab = 4
            case "timer":
                selectedTab = 0
            default:
                break
            }
            if !newValue.isEmpty {
                pendingDeepLink = ""
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            UserProfile.self,
            TimerPreset.self,
            SessionLog.self,
            QuestProgress.self,
            AICoachPreference.self,
        ], inMemory: true)
}
