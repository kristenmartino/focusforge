import Foundation
import SwiftData

enum AIFeatureType: String, Codable {
    case framing
    case reflection
    case nudge
}

enum AIInteractionOutcome: String, Codable {
    case accepted
    case dismissed
    case edited
}

@Model
final class AIInteractionLog {
    var interactionID: String
    var featureType: AIFeatureType
    var templateID: String
    var outcome: AIInteractionOutcome
    var createdAt: Date

    init(
        interactionID: String = UUID().uuidString,
        featureType: AIFeatureType = .framing,
        templateID: String = "",
        outcome: AIInteractionOutcome = .dismissed,
        createdAt: Date = .now
    ) {
        self.interactionID = interactionID
        self.featureType = featureType
        self.templateID = templateID
        self.outcome = outcome
        self.createdAt = createdAt
    }
}
