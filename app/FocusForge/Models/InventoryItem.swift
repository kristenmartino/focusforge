import Foundation
import SwiftData

enum ItemSlot: String, Codable {
    case horns
    case wings
    case weapon
}

enum ItemRarity: String, Codable {
    case common
    case rare
    case animatedRare
}

enum ItemOwnership: String, Codable {
    case locked
    case owned
    case new
}

@Model
final class InventoryItem {
    @Attribute(.unique) var itemID: String
    var name: String
    var slot: ItemSlot
    var rarity: ItemRarity
    var ownership: ItemOwnership
    var coinCost: Int
    var acquiredAt: Date?

    init(
        itemID: String,
        name: String = "",
        slot: ItemSlot = .horns,
        rarity: ItemRarity = .common,
        ownership: ItemOwnership = .locked,
        coinCost: Int = 0,
        acquiredAt: Date? = nil
    ) {
        self.itemID = itemID
        self.name = name
        self.slot = slot
        self.rarity = rarity
        self.ownership = ownership
        self.coinCost = coinCost
        self.acquiredAt = acquiredAt
    }
}
