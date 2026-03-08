import SwiftUI
import SwiftData

@main
struct FocusForgeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            TimerPreset.self,
            SessionLog.self,
            StreakState.self,
            CharacterLoadout.self,
            InventoryItem.self,
            UnlockEvent.self,
            QuestProgress.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
