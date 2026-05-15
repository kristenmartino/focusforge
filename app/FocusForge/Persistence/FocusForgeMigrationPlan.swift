import Foundation
import SwiftData

/// Migration plan for FocusForge's SwiftData store.
///
/// **Today.** Only `FocusForgeSchemaV1` exists, so `stages` is empty — there
/// are no migrations to run. SwiftData will use V1 as the baseline schema.
///
/// **When you ship a model change.** Add a new versioned schema (e.g.
/// `FocusForgeSchemaV2`) that declares the updated models, then add a
/// `MigrationStage` to `stages` describing how to map V1 → V2. Two flavors:
///
/// - `.lightweight(...)` for additive changes (new properties with defaults,
///   new entities). SwiftData handles the data-side automatically.
/// - `.custom(...)` for anything that needs transformation logic (renames,
///   data reshaping, computed defaults).
///
/// Order in `schemas` matters: oldest first. Stages must form a path from
/// older versions to newer.
enum FocusForgeMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [FocusForgeSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
