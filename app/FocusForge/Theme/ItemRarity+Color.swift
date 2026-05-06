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
}
