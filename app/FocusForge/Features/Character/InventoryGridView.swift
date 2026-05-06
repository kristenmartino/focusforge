import SwiftUI
import SwiftData

struct InventoryGridView: View {
    let slot: ItemSlot
    let equippedItemID: String?
    let onEquip: (String?) -> Void
    var onLockedTap: ((_ item: InventoryItem) -> Void)?

    @Query private var allItems: [InventoryItem]
    @Query private var streakStates: [StreakState]

    private var coins: Int { streakStates.first?.totalCoins ?? 0 }

    private var items: [InventoryItem] {
        allItems.filter { $0.slot == slot }
    }

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: FFTheme.Spacing.sm),
        count: 4
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: FFTheme.Spacing.sm) {
            Button {
                onEquip(nil)
            } label: {
                noneCell
            }
            .buttonStyle(.plain)

            ForEach(items, id: \.itemID) { item in
                Button {
                    handleTap(item)
                } label: {
                    itemCell(item)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func handleTap(_ item: InventoryItem) {
        switch item.ownership {
        case .owned, .new:
            if equippedItemID == item.itemID {
                AnalyticsService.track(.cosmeticUnequipped, parameters: [
                    "item_id": item.itemID,
                    "slot": item.slot.rawValue,
                    "rarity": item.rarity.rawValue
                ])
                onEquip(nil)
            } else {
                if item.ownership == .new {
                    item.ownership = .owned
                }
                AnalyticsService.track(.cosmeticEquipped, parameters: [
                    "item_id": item.itemID,
                    "slot": item.slot.rawValue,
                    "rarity": item.rarity.rawValue
                ])
                onEquip(item.itemID)
            }
        case .locked:
            if item.coinCost > 0, coins >= item.coinCost {
                if let state = streakStates.first {
                    state.totalCoins -= item.coinCost
                }
                item.ownership = .new
                item.acquiredAt = .now
                AnalyticsService.track(.cosmeticPurchased, parameters: [
                    "item_id": item.itemID,
                    "slot": item.slot.rawValue,
                    "rarity": item.rarity.rawValue,
                    "coin_cost": item.coinCost
                ])
                AnalyticsService.track(.cosmeticEquipped, parameters: [
                    "item_id": item.itemID,
                    "slot": item.slot.rawValue,
                    "rarity": item.rarity.rawValue
                ])
                onEquip(item.itemID)
            } else {
                onLockedTap?(item)
            }
        }
    }

    private var noneCell: some View {
        VStack(spacing: FFTheme.Spacing.xxs) {
            RoundedRectangle(cornerRadius: FFTheme.Radius.md)
                .fill(equippedItemID == nil
                      ? FFTheme.Accent.blue.opacity(0.15)
                      : Color.white.opacity(0.04))
                .frame(height: 72)
                .overlay(
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(FFTheme.Text.secondary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: FFTheme.Radius.md)
                        .stroke(equippedItemID == nil
                                ? FFTheme.Accent.blue
                                : FFTheme.Border.default,
                                lineWidth: equippedItemID == nil ? 2 : 0.5)
                )
            Text("None")
                .font(.system(size: 10))
                .foregroundStyle(FFTheme.Text.secondary)
        }
    }

    private func itemCell(_ item: InventoryItem) -> some View {
        let isEquipped = equippedItemID == item.itemID
        let isOwned = item.ownership == .owned || item.ownership == .new

        return VStack(spacing: FFTheme.Spacing.xxs) {
            RoundedRectangle(cornerRadius: FFTheme.Radius.md)
                .fill(isEquipped
                      ? FFTheme.Accent.blue.opacity(0.15)
                      : Color.white.opacity(0.04))
                .frame(height: 72)
                .overlay(
                    Image(item.itemID)
                        .resizable()
                        .interpolation(.high)
                        .aspectRatio(contentMode: .fit)
                        .padding(FFTheme.Spacing.xs)
                        .opacity(isOwned ? 1.0 : 0.3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: FFTheme.Radius.md)
                        .stroke(item.rarity.color, lineWidth: isEquipped ? 2.5 : 1.5)
                )
                .overlay(alignment: .topTrailing) {
                    if isEquipped {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(FFTheme.Accent.green)
                            .offset(x: 4, y: -4)
                    }
                }
                .overlay(alignment: .topLeading) {
                    if item.ownership == .new {
                        Text("NEW")
                            .font(.system(size: 8, weight: .black))
                            .foregroundStyle(FFTheme.Text.primary)
                            .padding(.horizontal, FFTheme.Spacing.xxs)
                            .padding(.vertical, 1)
                            .background(Capsule().fill(FFTheme.Accent.orange))
                            .offset(x: -4, y: -4)
                    }
                }
                .overlay(alignment: .bottom) {
                    if !isOwned {
                        if item.coinCost > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .font(.system(size: 9))
                                Text("\(item.coinCost)")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundStyle(coins >= item.coinCost
                                             ? FFTheme.Accent.gold
                                             : FFTheme.Text.tertiary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(FFTheme.Background.primary.opacity(0.7)))
                            .offset(y: 4)
                        } else {
                            HStack(spacing: 2) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 9))
                                Text("Streak")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundStyle(FFTheme.Accent.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(FFTheme.Background.primary.opacity(0.7)))
                            .offset(y: 4)
                        }
                    }
                }
                .animatedRareShimmer(
                    if: isOwned && item.rarity == .animatedRare,
                    cornerRadius: FFTheme.Radius.md
                )
            Text(item.name)
                .font(.system(size: 10))
                .foregroundStyle(isOwned ? FFTheme.Text.primary : FFTheme.Text.secondary)
                .lineLimit(1)
        }
    }
}
