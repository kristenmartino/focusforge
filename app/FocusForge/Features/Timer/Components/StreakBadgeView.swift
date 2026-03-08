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
                    .foregroundStyle(.orange)
                Text("\(streakDays) day\(streakDays == 1 ? "" : "s")")
            }
            .font(.subheadline.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.orange.opacity(0.15), in: Capsule())
        }
    }
}

#Preview {
    StreakBadgeView()
        .modelContainer(for: StreakState.self, inMemory: true)
}
