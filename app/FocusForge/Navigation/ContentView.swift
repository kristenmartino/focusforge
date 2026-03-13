import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(filter: #Predicate<QuestProgress> { $0.isCompleted && !$0.isClaimed })
    private var claimableQuests: [QuestProgress]

    var body: some View {
        TabView {
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
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            UserProfile.self,
            TimerPreset.self,
            SessionLog.self,
            QuestProgress.self,
        ], inMemory: true)
}
