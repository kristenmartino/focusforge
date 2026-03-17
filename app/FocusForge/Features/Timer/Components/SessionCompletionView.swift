import SwiftUI

struct SessionCompletionView: View {
    let sessionType: SessionPhase
    let duration: TimeInterval
    let result: SessionResult
    var reflection: ReflectionResult? = nil
    var onReflectionFeedback: ((Bool) -> Void)? = nil
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
                .accessibilityHidden(true)

            Text("\(sessionType.displayName) Complete!")
                .font(.title2.bold())

            Text("\(Int(duration / 60)) minutes")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if result.streakDays > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("Day \(result.streakDays) streak!")
                }
                .font(.headline)
            }

            if result.xp > 0 || result.coins > 0 {
                VStack(spacing: 8) {
                    HStack(spacing: 24) {
                        if result.xp > 0 {
                            Label("\(result.xp) XP", systemImage: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                        if result.coins > 0 {
                            Label("\(result.coins) Coins", systemImage: "circle.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                    .font(.headline)

                    if result.bonusXP > 0 {
                        Text("+\(result.bonusXP) streak bonus XP")
                            .font(.caption)
                            .foregroundStyle(.yellow.opacity(0.8))
                    }
                }
            }

            if result.leveledUp {
                Label("Level Up!", systemImage: "arrow.up.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.cyan)
            }

            if let milestone = result.newMilestone {
                VStack(spacing: 4) {
                    Divider()
                        .padding(.horizontal)
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                        Text(milestone.name)
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(.purple)
                    Text("New item unlocked!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if !result.completedQuests.isEmpty {
                VStack(spacing: 4) {
                    Divider()
                        .padding(.horizontal)
                    ForEach(result.completedQuests, id: \.questID) { quest in
                        HStack(spacing: 4) {
                            Image(systemName: "scroll.fill")
                            Text("Quest complete: \(quest.title)")
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(.cyan)
                    }
                    Text("Claim rewards in the Quests tab")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let reflection {
                PostReflectionCardView(
                    reflection: reflection,
                    onFeedback: { accepted in
                        onReflectionFeedback?(accepted)
                    }
                )
            }

            Spacer()

            Button("Continue", action: onDismiss)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
        .interactiveDismissDisabled()
    }
}

#Preview {
    SessionCompletionView(
        sessionType: .focus,
        duration: 1500,
        result: SessionResult(
            xp: 30,
            coins: 25,
            streakDays: 3,
            bonusXP: 5,
            newMilestone: nil,
            leveledUp: false,
            completedQuests: []
        ),
        onDismiss: {}
    )
}
