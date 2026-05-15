import SwiftUI
import SwiftData

struct DressingRoomView: View {
    @Bindable var loadout: CharacterLoadout

    @State private var selectedSlot: ItemSlot = .horns
    @State private var toastMessage: String?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var bodyColor: Color { Color(hex: loadout.bodyColorHex) }

    var body: some View {
        ZStack {
            // Atmospheric background
            CharacterSceneBackground(characterColor: bodyColor)

            ScrollView {
                VStack(spacing: FFTheme.Spacing.lg) {
                    // Character preview with ground plane
                    ZStack {
                        CharacterSpriteView(loadout: loadout, size: 220)
                    }
                    .frame(height: 240)
                    .overlay(alignment: .bottom) {
                        GroundPlane(color: bodyColor, width: 180)
                            .offset(y: 4)
                    }
                    .padding(.top, FFTheme.Spacing.xs)

                    // Color pickers on dark surfaces
                    VStack(spacing: FFTheme.Spacing.sm) {
                        darkColorPicker(
                            label: "Skin",
                            colors: CharacterCatalog.skinColors,
                            selectedHex: $loadout.skinColorHex
                        )
                        darkColorPicker(
                            label: "Hair",
                            colors: CharacterCatalog.hairColors,
                            selectedHex: $loadout.hairColorHex
                        )
                        darkColorPicker(
                            label: "Body",
                            colors: CharacterCatalog.bodyColors,
                            selectedHex: $loadout.bodyColorHex
                        )
                    }
                    .padding(.horizontal)

                    // Divider
                    Rectangle()
                        .fill(FFTheme.Border.default)
                        .frame(height: 0.5)
                        .padding(.horizontal)

                    // Slot picker (dark segmented)
                    slotPicker
                        .padding(.horizontal)

                    // Inventory grid
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
                    .animation(reduceMotion ? .none : .default, value: selectedSlot)
                }
                // Generous bottom padding so the last inventory row clears
                // the tab bar with visible breathing room. Without this the
                // last items read as "clipped" even though they're scrollable.
                .padding(.bottom, 60)
            }
        }
        .overlay(alignment: .bottom) {
            if let message = toastMessage {
                Text(message)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(FFTheme.Text.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.12))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                            )
                    )
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 16)
                    .accessibilityAddTraits(.isStaticText)
            }
        }
        .animation(reduceMotion ? .none : .easeInOut(duration: 0.25), value: toastMessage)
    }

    // MARK: - Dark Color Picker

    private func darkColorPicker(
        label: String,
        colors: [(name: String, hex: String)],
        selectedHex: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption2.weight(.medium))
                .foregroundStyle(FFTheme.Text.tertiary)
                .tracking(1)
                .accessibilityAddTraits(.isHeader)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(colors, id: \.hex) { color in
                        Button {
                            selectedHex.wrappedValue = color.hex
                        } label: {
                            Circle()
                                .fill(Color(hex: color.hex))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            selectedHex.wrappedValue == color.hex
                                                ? Color.white.opacity(0.7)
                                                : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                                .overlay(
                                    Circle()
                                        .stroke(FFTheme.Background.primary, lineWidth: 1.5)
                                        .padding(1)
                                        .opacity(selectedHex.wrappedValue == color.hex ? 1 : 0)
                                )
                                .frame(minWidth: 44, minHeight: 44)
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(
                            "\(color.name) \(label)"
                        )
                        .accessibilityAddTraits(
                            selectedHex.wrappedValue == color.hex ? .isSelected : []
                        )
                    }
                }
            }
        }
    }

    // MARK: - Slot Picker

    private var slotPicker: some View {
        HStack(spacing: 2) {
            ForEach(
                [(ItemSlot.horns, "Horns"), (.wings, "Wings"), (.weapon, "Weapon")],
                id: \.0
            ) { slot, label in
                Button {
                    selectedSlot = slot
                } label: {
                    Text(label)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(
                            selectedSlot == slot
                                ? FFTheme.Text.primary
                                : FFTheme.Text.tertiary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .frame(minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: FFTheme.Radius.sm)
                                .fill(
                                    selectedSlot == slot
                                        ? Color.white.opacity(0.08)
                                        : Color.clear
                                )
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(label) slot")
                .accessibilityAddTraits(selectedSlot == slot ? .isSelected : [])
            }
        }
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: FFTheme.Radius.sm + 2)
                .fill(Color.white.opacity(0.03))
        )
    }

    // MARK: - Helpers

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
