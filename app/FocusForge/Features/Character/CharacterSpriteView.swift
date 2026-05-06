import SwiftUI

struct CharacterSpriteView: View {
    let loadout: CharacterLoadout
    var size: CGFloat = 200

    private var skinColor: Color { Color(hex: loadout.skinColorHex) }
    private var hairColor: Color { Color(hex: loadout.hairColorHex) }
    private var bodyColor: Color { Color(hex: loadout.bodyColorHex) }

    var body: some View {
        ZStack {
            // Back layer — wings behind body
            if loadout.equippedWings != nil {
                layer("wingL1").colorMultiply(skinColor)
                layer("wingR1").colorMultiply(skinColor)
            }

            // Feet
            layer("footL1").colorMultiply(skinColor)
            layer("footR1").colorMultiply(skinColor)

            // Body
            layer("body1").colorMultiply(bodyColor)

            // Head (behind hands so hands overlap)
            layer(loadout.headShape).colorMultiply(skinColor)

            // Hands
            layer("handL1").colorMultiply(skinColor)

            // Weapon in right hand (behind handR so grip overlaps)
            if let weapon = loadout.equippedWeapon {
                layer(weapon)
            }

            layer("handR1").colorMultiply(skinColor)

            // Face features — eyes and mouth stay untinted
            layer(loadout.eyeStyle)
            layer(loadout.mouthStyle)

            // Hair
            layer(loadout.hairStyle).colorMultiply(hairColor)

            // Horns on top
            if let horns = loadout.equippedHorns {
                layer(horns)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isImage)
        .accessibilityLabel(accessibilityDescription)
    }

    /// Single coherent description for VoiceOver instead of 12 separate layer announcements.
    private var accessibilityDescription: String {
        var parts = ["Your character"]
        if loadout.equippedWings != nil { parts.append("with wings") }
        if loadout.equippedHorns != nil { parts.append("with horns") }
        if loadout.equippedWeapon != nil { parts.append("holding a weapon") }
        return parts.joined(separator: " ")
    }

    private func layer(_ name: String) -> some View {
        Image(name)
            .resizable()
            .interpolation(.high)
            .aspectRatio(contentMode: .fit)
    }
}

#Preview("Spark Preset") {
    let loadout = CharacterCatalog.createLoadout(
        from: CharacterCatalog.presets[0]
    )
    CharacterSpriteView(loadout: loadout, size: 300)
}

#Preview("Ember with Horns") {
    let loadout = CharacterCatalog.createLoadout(
        from: CharacterCatalog.presets[1]
    )
    loadout.equippedHorns = "horn2"
    return CharacterSpriteView(loadout: loadout, size: 300)
}
