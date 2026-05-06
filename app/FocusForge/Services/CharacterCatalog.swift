import Foundation
import SwiftUI
import SwiftData

enum CharacterCatalog {
    // MARK: - Color Palettes

    static let skinColors: [(name: String, hex: String)] = [
        ("Fair", "#F5D6C3"),
        ("Light", "#E8B894"),
        ("Medium", "#C68642"),
        ("Tan", "#A0724A"),
        ("Brown", "#6B4226"),
        ("Dark", "#3B2314"),
    ]

    static let hairColors: [(name: String, hex: String)] = [
        ("Black", "#1A1A1A"),
        ("Brown", "#5C3317"),
        ("Blonde", "#F0D58C"),
        ("Red", "#B33030"),
        ("Blue", "#5B7FFF"),
        ("Purple", "#9B59B6"),
        ("Pink", "#E891B2"),
        ("White", "#E8E8E8"),
    ]

    static let bodyColors: [(name: String, hex: String)] = [
        ("Red", "#C0392B"),
        ("Blue", "#2980B9"),
        ("Green", "#27AE60"),
        ("Purple", "#8E44AD"),
        ("Orange", "#E67E22"),
        ("Slate", "#2C3E50"),
    ]

    // MARK: - Preset Characters

    struct CharacterPreset: Identifiable {
        let id: String
        let name: String
        let headShape: String
        let hairStyle: String
        let eyeStyle: String
        let mouthStyle: String
        let skinColorHex: String
        let hairColorHex: String
        let bodyColorHex: String
    }

    static let presets: [CharacterPreset] = [
        CharacterPreset(
            id: "spark", name: "Spark",
            headShape: "head1", hairStyle: "hair1",
            eyeStyle: "eyes1", mouthStyle: "mouth1",
            skinColorHex: "#E8B894", hairColorHex: "#5B7FFF", bodyColorHex: "#2980B9"
        ),
        CharacterPreset(
            id: "ember", name: "Ember",
            headShape: "head2", hairStyle: "hair2",
            eyeStyle: "eyes3", mouthStyle: "mouth3",
            skinColorHex: "#C68642", hairColorHex: "#B33030", bodyColorHex: "#C0392B"
        ),
        CharacterPreset(
            id: "sage", name: "Sage",
            headShape: "head3", hairStyle: "hair3",
            eyeStyle: "eyes5", mouthStyle: "mouth5",
            skinColorHex: "#F5D6C3", hairColorHex: "#27AE60", bodyColorHex: "#27AE60"
        ),
    ]

    // MARK: - Cosmetic Item Catalog

    struct CosmeticDefinition {
        let itemID: String
        let name: String
        let slot: ItemSlot
        let rarity: ItemRarity
        let coinCost: Int
    }

    static let allCosmetics: [CosmeticDefinition] = [
        // Horns
        CosmeticDefinition(itemID: "horn1", name: "Imp Points", slot: .horns, rarity: .common, coinCost: 0),
        CosmeticDefinition(itemID: "horn2", name: "Wide Spikes", slot: .horns, rarity: .common, coinCost: 50),
        CosmeticDefinition(itemID: "horn3", name: "Alicorn", slot: .horns, rarity: .rare, coinCost: 0),
        CosmeticDefinition(itemID: "horn4", name: "Battle Scarred", slot: .horns, rarity: .rare, coinCost: 100),
        CosmeticDefinition(itemID: "horn5", name: "Ram Curls", slot: .horns, rarity: .animatedRare, coinCost: 200),
        // Wings
        CosmeticDefinition(itemID: "wingL1", name: "Shadow Wings", slot: .wings, rarity: .rare, coinCost: 0),
        // Weapons
        CosmeticDefinition(itemID: "weaponR1", name: "Pea Shooter", slot: .weapon, rarity: .common, coinCost: 0),
        CosmeticDefinition(itemID: "weaponR2", name: "Boomstick", slot: .weapon, rarity: .rare, coinCost: 100),
        CosmeticDefinition(itemID: "weaponR3", name: "Ray Gun", slot: .weapon, rarity: .animatedRare, coinCost: 0),
    ]

    // MARK: - Seed Inventory

    static func seedInventory(in context: ModelContext) {
        let descriptor = FetchDescriptor<InventoryItem>()
        let existing = (try? context.fetch(descriptor)) ?? []
        let existingByID = Dictionary(uniqueKeysWithValues: existing.map { ($0.itemID, $0) })

        for cosmetic in allCosmetics {
            if let item = existingByID[cosmetic.itemID] {
                item.name = cosmetic.name
            } else {
                let item = InventoryItem(
                    itemID: cosmetic.itemID,
                    name: cosmetic.name,
                    slot: cosmetic.slot,
                    rarity: cosmetic.rarity,
                    ownership: .locked,
                    coinCost: cosmetic.coinCost
                )
                context.insert(item)
            }
        }
        try? context.save()
    }

    // MARK: - Loadout from Preset

    static func createLoadout(from preset: CharacterPreset) -> CharacterLoadout {
        CharacterLoadout(
            headShape: preset.headShape,
            hairStyle: preset.hairStyle,
            eyeStyle: preset.eyeStyle,
            mouthStyle: preset.mouthStyle,
            skinColorHex: preset.skinColorHex,
            hairColorHex: preset.hairColorHex,
            bodyColorHex: preset.bodyColorHex
        )
    }
}

