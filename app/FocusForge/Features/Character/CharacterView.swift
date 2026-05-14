import SwiftUI
import SwiftData

struct CharacterView: View {
    @Query private var loadouts: [CharacterLoadout]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ZStack {
                FFTheme.Background.primary.ignoresSafeArea()

                Group {
                    if let loadout = loadouts.first {
                        DressingRoomView(loadout: loadout)
                    } else {
                        ContentUnavailableView(
                            "No Character",
                            systemImage: "person.crop.circle.badge.questionmark",
                            description: Text("Complete onboarding to create your character.")
                        )
                    }
                }
            }
            .navigationTitle("Character")
            .navigationBarTitleDisplayMode(.inline)
            .darkNavigationAppearance()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: CharacterLoadout.self, InventoryItem.self,
        configurations: config
    )
    let loadout = CharacterCatalog.createLoadout(from: CharacterCatalog.presets[0])
    container.mainContext.insert(loadout)
    CharacterCatalog.seedInventory(in: container.mainContext)
    return CharacterView()
        .modelContainer(container)
}
