import SwiftUI
import SwiftData

struct StreakBadgeView: View {
    @Query private var streakStates: [StreakState]

    private var streakDays: Int {
        streakStates.first?.currentStreakDays ?? 0
    }

    var body: some View {
        if streakDays > 0 {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(FFTheme.Accent.orange)
                    .font(.caption)
                    .accessibilityHidden(true)
                Text("Day \(streakDays)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(FFTheme.Accent.orange)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(FFTheme.Accent.orange.opacity(0.10))
                    .overlay(
                        Capsule()
                            .stroke(FFTheme.Accent.orange.opacity(0.20), lineWidth: 0.5)
                    )
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Current streak: \(streakDays) day\(streakDays == 1 ? "" : "s")")
        }
    }
}

#Preview {
    ZStack {
        FocusBackground()
        StreakBadgeView()
    }
    .modelContainer(for: StreakState.self, inMemory: true)
}
