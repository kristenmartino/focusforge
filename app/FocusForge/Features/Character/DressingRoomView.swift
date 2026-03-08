import SwiftUI
import SwiftData

struct DressingRoomView: View {
    @Bindable var loadout: CharacterLoadout

    @State private var selectedSlot: ItemSlot = .horns
    @State private var toastMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Large character preview
                CharacterSpriteView(loadout: loadout, size: 220)
                    .padding(.top, 8)

                // Color pickers
                VStack(spacing: 12) {
                    ColorPickerRowView(
                        label: "Skin",
                        colors: CharacterCatalog.skinColors,
                        selectedHex: $loadout.skinColorHex
                    )
                    ColorPickerRowView(
                        label: "Hair",
                        colors: CharacterCatalog.hairColors,
                        selectedHex: $loadout.hairColorHex
                    )
                    ColorPickerRowView(
                        label: "Body",
                        colors: CharacterCatalog.bodyColors,
                        selectedHex: $loadout.bodyColorHex
                    )
                }
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                // Equipment slot picker
                Picker("Slot", selection: $selectedSlot) {
                    Text("Horns").tag(ItemSlot.horns)
                    Text("Wings").tag(ItemSlot.wings)
                    Text("Weapon").tag(ItemSlot.weapon)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Inventory grid for selected slot
                InventoryGridView(
                    slot: selectedSlot,
                    equippedItemID: equippedID(for: selectedSlot),
                    onEquip: { itemID in
                        equip(itemID: itemID, slot: selectedSlot)
                    },
                    onLockedTap: { item in
                        showToast(for: item)
                    }
                )
                .padding(.horizontal)
                .animation(.default, value: selectedSlot)
            }
            .padding(.bottom, 20)
        }
        .overlay(alignment: .bottom) {
            if let message = toastMessage {
                Text(message)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(.black.opacity(0.8)))
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 16)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: toastMessage)
    }

    private func equippedID(for slot: ItemSlot) -> String? {
        switch slot {
        case .horns: loadout.equippedHorns
        case .wings: loadout.equippedWings
        case .weapon: loadout.equippedWeapon
        }
    }

    private func equip(itemID: String?, slot: ItemSlot) {
        switch slot {
        case .horns: loadout.equippedHorns = itemID
        case .wings: loadout.equippedWings = itemID
        case .weapon: loadout.equippedWeapon = itemID
        }
        loadout.updatedAt = .now
    }

    private func showToast(for item: InventoryItem) {
        if item.coinCost == 0 {
            toastMessage = "\(item.name) — earn via streak milestone"
        } else {
            toastMessage = "\(item.name) — need \(item.coinCost) coins"
        }
        Task {
            try? await Task.sleep(for: .seconds(2))
            toastMessage = nil
        }
    }
}
