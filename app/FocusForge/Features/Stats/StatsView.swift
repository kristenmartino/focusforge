import SwiftUI
import SwiftData

struct StatsView: View {
    @Query private var sessions: [SessionLog]

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.secondary)
                Text("Stats & insights coming soon")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                Spacer()
            }
            .navigationTitle("Stats")
        }
    }
}

#Preview {
    StatsView()
        .modelContainer(for: SessionLog.self, inMemory: true)
}
