import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationService.self) private var notificationService

    @State private var currentStep = 0
    @State private var selectedCharacterID = "spark"

    var body: some View {
        ZStack {
            FFTheme.Background.primary.ignoresSafeArea()

            TabView(selection: $currentStep) {
                WelcomeStepView(onContinue: { withAnimation { currentStep = 1 } })
                    .tag(0)
                CharacterSelectionStepView(
                    selectedID: $selectedCharacterID,
                    onContinue: { withAnimation { currentStep = 2 } }
                )
                .tag(1)
                NotificationPermissionStepView(onContinue: { withAnimation { currentStep = 3 } })
                    .tag(2)
                FirstSessionNudgeView(onComplete: completeOnboarding)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .preferredColorScheme(.dark)
    }

    private func completeOnboarding() {
        let profile = UserProfile(
            hasCompletedOnboarding: true,
            selectedCharacterID: selectedCharacterID,
            notificationPermissionRequested: true
        )
        modelContext.insert(profile)

        if let preset = CharacterCatalog.presets.first(where: { $0.id == selectedCharacterID }) {
            let loadout = CharacterCatalog.createLoadout(from: preset)
            modelContext.insert(loadout)
        }

        try? modelContext.save()
    }
}
