import Foundation
import SwiftData

/// FocusForge v1.0.0 SwiftData schema.
///
/// **Why this exists.** SwiftData's default `Schema([...])` constructor produces
/// an unversioned store. The schema format isn't pinned to a version, so the
/// first time we ship a model change — adding a property, renaming a field,
/// adding an attribute — SwiftData will try to infer a migration. That
/// inference can succeed (lightweight migration) or fail silently (data lost).
///
/// Declaring a `VersionedSchema` now, before any production user data exists,
/// pins v1.0.0 as the baseline. Subsequent versions add a `FocusForgeSchemaV2`,
/// then `FocusForgeSchemaV3`, etc., and `FocusForgeMigrationPlan` declares the
/// migration stages between them.
///
/// Required for v1.0 ship — without versioning, the first iOS update that
/// changes SwiftData internals can wipe every user's streak/XP/inventory data
/// silently.
enum FocusForgeSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        Schema.Version(1, 0, 0)
    }

    static var models: [any PersistentModel.Type] {
        [
            UserProfile.self,
            TimerPreset.self,
            SessionLog.self,
            StreakState.self,
            CharacterLoadout.self,
            InventoryItem.self,
            UnlockEvent.self,
            QuestProgress.self,
            AICoachPreference.self,
            AIInteractionLog.self,
        ]
    }
}
