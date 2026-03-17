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
            AICoachPreference.self,
            AIInteractionLog.self,
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

    @State private var timerEngine = TimerEngine()
    @State private var notificationService = NotificationService()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(timerEngine)
                .environment(notificationService)
        }
        .modelContainer(sharedModelContainer)
    }
}

struct AppRootView: View {
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationService.self) private var notificationService
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if let profile = profiles.first, profile.hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingContainerView()
            }
        }
        .task {
            PresetManager.ensureDefaultPreset(in: modelContext)
            CharacterCatalog.seedInventory(in: modelContext)
            QuestManager.ensureActiveQuests(in: modelContext)
            AICoachPreferenceManager.fetchOrCreate(in: modelContext)
            await notificationService.checkCurrentStatus()
            StreakNudgeScheduler.evaluateAndScheduleIfNeeded(in: modelContext, notificationService: notificationService)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                QuestManager.ensureActiveQuests(in: modelContext)
                StreakNudgeScheduler.evaluateAndScheduleIfNeeded(in: modelContext, notificationService: notificationService)
            }
        }
    }
}
