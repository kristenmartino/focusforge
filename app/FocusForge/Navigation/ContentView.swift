import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(filter: #Predicate<QuestProgress> { $0.isCompleted && !$0.isClaimed })
    private var claimableQuests: [QuestProgress]
    @Query private var coachPreferences: [AICoachPreference]
    @Query private var streakStates: [StreakState]
    @Environment(\.modelContext) private var modelContext

    @State private var selectedTab = 0
    @State private var showRescueBanner = false
    @State private var bannerDismissed = false

    private var shouldShowBanner: Bool {
        guard !bannerDismissed else { return false }
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
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 4)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: shouldShowBanner)
        .preferredColorScheme(.dark)
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
