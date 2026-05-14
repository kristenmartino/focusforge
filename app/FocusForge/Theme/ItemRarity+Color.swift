import SwiftUI

extension ItemRarity {
    /// Single source of truth for rarity color mapping. Used by InventoryGridView,
    /// MilestoneTrackerView, and any other view that surfaces an item's rarity.
    var color: Color {
        switch self {
        case .common: FFTheme.Rarity.common
        case .rare: FFTheme.Rarity.rare
        case .animatedRare: FFTheme.Rarity.animatedRare
        }
    }

    /// Human-readable rarity name. Used in rarity capsules and milestone reveals.
    /// Avoids `.rawValue.capitalized` which butchers camelCase ("animatedRare" → "Animatedrare").
    var displayName: String {
        switch self {
        case .common: "Common"
        case .rare: "Rare"
        case .animatedRare: "Animated Rare"
        }
    }
}
