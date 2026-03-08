import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationService.self) private var notificationService

    @State private var currentStep = 0
    @State private var selectedCharacterID = "default"

    var body: some View {
        TabView(selection: $currentStep) {
            WelcomeStepView(onContinue: { currentStep = 1 })
                .tag(0)
            CharacterSelectionStepView(
                selectedID: $selectedCharacterID,
                onContinue: { currentStep = 2 }
            )
            .tag(1)
            NotificationPermissionStepView(onContinue: { currentStep = 3 })
                .tag(2)
            FirstSessionNudgeView(onComplete: completeOnboarding)
                .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }

    private func completeOnboarding() {
        let profile = UserProfile(
            hasCompletedOnboarding: true,
            selectedCharacterID: selectedCharacterID,
            notificationPermissionRequested: true
        )
        modelContext.insert(profile)
        try? modelContext.save()
    }
}
