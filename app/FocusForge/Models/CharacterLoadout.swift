import Foundation
import SwiftData

@Model
final class CharacterLoadout {
    var baseCharacterID: String
    var headItemID: String?
    var topItemID: String?
    var bottomItemID: String?
    var accessoryItemID: String?
    var faceTraitID: String?
    var expressionTraitID: String?
    var updatedAt: Date

    init(
        baseCharacterID: String = "default",
        headItemID: String? = nil,
        topItemID: String? = nil,
        bottomItemID: String? = nil,
        accessoryItemID: String? = nil,
        faceTraitID: String? = nil,
        expressionTraitID: String? = nil,
        updatedAt: Date = .now
    ) {
        self.baseCharacterID = baseCharacterID
        self.headItemID = headItemID
        self.topItemID = topItemID
        self.bottomItemID = bottomItemID
        self.accessoryItemID = accessoryItemID
        self.faceTraitID = faceTraitID
        self.expressionTraitID = expressionTraitID
        self.updatedAt = updatedAt
    }
}
