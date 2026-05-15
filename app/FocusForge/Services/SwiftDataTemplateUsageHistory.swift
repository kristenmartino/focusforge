import Foundation
import SwiftData
import FocusForgeCoachEngine

/// SwiftData-backed adapter for the coach engine's `TemplateUsageHistory`
/// protocol. The engine asks this adapter "what templates have been shown
/// recently?" so it can deduplicate selections; the adapter answers by
/// querying the `AIInteractionLog` model from the app's persistence layer.
///
/// **Why this exists.** The `FocusForgeCoachEngine` package is intentionally
/// Foundation-only — no SwiftData dependency — so it can run on any Swift
/// platform and be tested in isolation. The protocol seam means the host
/// app (FocusForge) provides whatever persistence makes sense for it; this
/// adapter is what makes that work.
///
/// **Read shape.** `recentTemplateIDs(featureType:limit:)` runs one fetch
/// per call, sorted by `createdAt` descending, returning the top `limit`
/// template IDs as a `Set`. Cheap enough at a few thousand interaction
/// logs that we don't bother caching.
///
/// **Write shape.** `recordShown(templateID:featureType:)` constructs and
/// inserts a new `AIInteractionLog` with `outcome = .dismissed` by
/// default. Callers that observe a user action on the prompt (accepted /
/// edited) should call `AIInteractionLog.upsertOutcome(...)` after this to
/// mark the interaction's actual outcome.
///
/// Bridges the package's `AIFeatureType` (which mirrors the same enum
/// shape) to the app's `AIFeatureType` via raw-value pass-through.
@MainActor
final class SwiftDataTemplateUsageHistory: TemplateUsageHistory {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func recentTemplateIDs(
        featureType: FocusForgeCoachEngine.AIFeatureType,
        limit: Int
    ) -> Set<String> {
        let targetType = AIFeatureType(rawValue: featureType.rawValue) ?? .framing
        let descriptor = FetchDescriptor<AIInteractionLog>(
            predicate: #Predicate<AIInteractionLog> {
                $0.featureType == targetType
            },
            sortBy: [SortDescriptor(\AIInteractionLog.createdAt, order: .reverse)]
        )
        let logs = (try? context.fetch(descriptor)) ?? []
        let ids = logs.prefix(limit).map(\.templateID)
        return Set(ids)
    }

    func recordShown(
        templateID: String,
        featureType: FocusForgeCoachEngine.AIFeatureType
    ) {
        let appFeatureType = AIFeatureType(rawValue: featureType.rawValue) ?? .framing
        let log = AIInteractionLog(
            featureType: appFeatureType,
            templateID: templateID,
            outcome: .dismissed
        )
        context.insert(log)
        try? context.save()
    }
}
