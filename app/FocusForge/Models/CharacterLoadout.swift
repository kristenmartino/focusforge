import Foundation
import SwiftData

@Model
final class CharacterLoadout {
    // Base appearance (chosen during character creation)
    var headShape: String
    var hairStyle: String
    var eyeStyle: String
    var mouthStyle: String

    // Colors as hex strings for runtime tinting
    var skinColorHex: String
    var hairColorHex: String
    var bodyColorHex: String

    // Equipped cosmetics (optional, earned via milestones/coins)
    var equippedHorns: String?
    var equippedWings: String?
    var equippedWeapon: String?

    var updatedAt: Date

    init(
        headShape: String = "head1",
        hairStyle: String = "hair1",
        eyeStyle: String = "eyes1",
        mouthStyle: String = "mouth1",
        skinColorHex: String = "#E8B894",
        hairColorHex: String = "#5B7FFF",
        bodyColorHex: String = "#2980B9",
        equippedHorns: String? = nil,
        equippedWings: String? = nil,
        equippedWeapon: String? = nil,
        updatedAt: Date = .now
    ) {
        self.headShape = headShape
        self.hairStyle = hairStyle
        self.eyeStyle = eyeStyle
        self.mouthStyle = mouthStyle
        self.skinColorHex = skinColorHex
        self.hairColorHex = hairColorHex
        self.bodyColorHex = bodyColorHex
        self.equippedHorns = equippedHorns
        self.equippedWings = equippedWings
        self.equippedWeapon = equippedWeapon
        self.updatedAt = updatedAt
    }
}
