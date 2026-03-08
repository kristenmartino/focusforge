import SwiftUI
import SwiftData

struct CharacterView: View {
    @Query private var loadouts: [CharacterLoadout]

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 120))
                    .foregroundStyle(.secondary)
                Text("Character customization coming soon")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                Spacer()
            }
            .navigationTitle("Character")
        }
    }
}

#Preview {
    CharacterView()
        .modelContainer(for: CharacterLoadout.self, inMemory: true)
}
