import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAnalytics

@main
struct FocusForgeApp: App {
    init() {
        FirebaseApp.configure()
        AnalyticsService.backend = FirebaseAnalyticsBackend()

        // Honor the user's analytics opt-out at the Firebase SDK level
        // too. AnalyticsService.track() also gates on this flag, but
        // disabling the SDK is the stronger guarantee — even logs that
        // bypass AnalyticsService won't reach Firebase. Defense in depth.
        Analytics.setAnalyticsCollectionEnabled(AnalyticsService.isAnalyticsEnabled)
    }

    var sharedModelContainer: ModelContainer = {
        // Use the versioned schema (FocusForgeSchemaV1) so future model
        // changes can be migrated rather than silently dropping user data.
        let schema = Schema(versionedSchema: FocusForgeSchemaV1.self)
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: FocusForgeMigrationPlan.self,
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
