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

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
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
                onEquip(nil)
            } else {
                if item.ownership == .new {
                    item.ownership = .owned
                }
                onEquip(item.itemID)
            }
        case .locked:
            if item.coinCost > 0, coins >= item.coinCost {
                if let state = streakStates.first {
                    state.totalCoins -= item.coinCost
                }
                item.ownership = .new
                item.acquiredAt = .now
                onEquip(item.itemID)
            } else {
                onLockedTap?(item)
            }
        }
    }

    private var noneCell: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 10)
                .fill(equippedItemID == nil ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.1))
                .frame(height: 72)
                .overlay(
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(equippedItemID == nil ? Color.accentColor : Color.clear, lineWidth: 2)
                )
            Text("None")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }

    private func itemCell(_ item: InventoryItem) -> some View {
        let isEquipped = equippedItemID == item.itemID
        let isOwned = item.ownership == .owned || item.ownership == .new

        return VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 10)
                .fill(isEquipped ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.1))
                .frame(height: 72)
                .overlay(
                    Image(item.itemID)
                        .resizable()
                        .interpolation(.high)
                        .aspectRatio(contentMode: .fit)
                        .padding(8)
                        .opacity(isOwned ? 1.0 : 0.3)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(rarityColor(item.rarity), lineWidth: isEquipped ? 2.5 : 1.5)
                )
                .overlay(alignment: .topTrailing) {
                    if isEquipped {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .offset(x: 4, y: -4)
                    }
                }
                .overlay(alignment: .topLeading) {
                    if item.ownership == .new {
                        Text("NEW")
                            .font(.system(size: 8, weight: .black))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Capsule().fill(.orange))
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
                            .foregroundStyle(coins >= item.coinCost ? .yellow : .gray)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(.black.opacity(0.6)))
                            .offset(y: 4)
                        } else {
                            HStack(spacing: 2) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 9))
                                Text("Streak")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(.black.opacity(0.6)))
                            .offset(y: 4)
                        }
                    }
                }
            Text(item.name)
                .font(.system(size: 10))
                .foregroundStyle(isOwned ? .primary : .secondary)
                .lineLimit(1)
        }
    }

    private func rarityColor(_ rarity: ItemRarity) -> Color {
        switch rarity {
        case .common: .gray
        case .rare: .purple
        case .animatedRare: .orange
        }
    }
}
