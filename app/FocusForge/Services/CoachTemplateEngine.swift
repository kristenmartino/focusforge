import Foundation
import SwiftData

// MARK: - Result Types

struct FramingResult {
    let templateID: String
    let originalTask: String
    let reframedTask: String
    let motivationalLine: String
}

struct ReflectionResult {
    let templateID: String
    let tipText: String
    let category: ReflectionCategory
}

struct NudgeResult {
    let templateID: String
    let title: String
    let body: String
    let quickStartSuggestion: String
}

// MARK: - Template Engine

enum CoachTemplateEngine {

    // MARK: - Intent Framing

    static func selectFramingTemplate(
        taskName: String,
        signal: BehaviorSignal,
        tone: CoachTone,
        in context: ModelContext
    ) -> FramingResult {
        let category = detectCategory(from: taskName)
        let condition = framingCondition(from: signal)
        let recentIDs = recentTemplateIDs(featureType: .framing, limit: 3, in: context)

        // Find matching templates, excluding recently used
        let candidates = CoachTemplateCatalog.framingTemplates.filter { template in
            template.category == category &&
            template.condition == condition &&
            !recentIDs.contains(template.id)
        }

        // Fallback: same category any condition, then general defaults
        let template = candidates.randomElement()
            ?? CoachTemplateCatalog.framingTemplates.filter {
                $0.category == category && !recentIDs.contains($0.id)
            }.randomElement()
            ?? CoachTemplateCatalog.framingTemplates.filter {
                $0.category == "general" && $0.condition == .default
            }.randomElement()
            ?? CoachTemplateCatalog.framingTemplates[0]

        let format = template.reframeFormat[tone] ?? template.reframeFormat[.encouraging]!
        let reframed = applySafetyFilter(String(format: format, taskName))
        let motivation = template.motivationalLine[tone] ?? template.motivationalLine[.encouraging]!

        return FramingResult(
            templateID: template.id,
            originalTask: taskName,
            reframedTask: reframed,
            motivationalLine: applySafetyFilter(motivation)
        )
    }

    // MARK: - Post-Session Reflection

    static func selectReflectionTemplate(
        outcome: SessionOutcome,
        actualMinutes: Int,
        plannedMinutes: Int,
        signal: BehaviorSignal,
        tone: CoachTone,
        in context: ModelContext
    ) -> ReflectionResult {
        let condition = reflectionCondition(
            actualMinutes: actualMinutes,
            signal: signal
        )
        let recentIDs = recentTemplateIDs(featureType: .reflection, limit: 3, in: context)

        let candidates = CoachTemplateCatalog.reflectionTemplates.filter { template in
            template.condition == condition && !recentIDs.contains(template.id)
        }

        let template = candidates.randomElement()
            ?? CoachTemplateCatalog.reflectionTemplates.filter {
                $0.condition == .default && !recentIDs.contains($0.id)
            }.randomElement()
            ?? CoachTemplateCatalog.reflectionTemplates.filter {
                $0.condition == .default
            }.randomElement()
            ?? CoachTemplateCatalog.reflectionTemplates[0]

        let text = template.tipText[tone] ?? template.tipText[.encouraging]!

        return ReflectionResult(
            templateID: template.id,
            tipText: applySafetyFilter(text),
            category: template.category
        )
    }

    // MARK: - Streak Rescue Nudge

    static func selectNudgeTemplate(
        streakDays: Int,
        signal: BehaviorSignal,
        tone: CoachTone
    ) -> NudgeResult {
        let candidates = CoachTemplateCatalog.nudgeTemplates.filter { template in
            template.streakTier.contains(streakDays)
        }

        let template = candidates.randomElement()
            ?? CoachTemplateCatalog.nudgeTemplates.last!

        let title = template.title[tone] ?? template.title[.encouraging]!
        let bodyFormat = template.body[tone] ?? template.body[.encouraging]!
        let body = String(format: bodyFormat, streakDays)

        let suggestion: String
        if signal.avgActualFocusMinutes < 15 {
            suggestion = "Try a 10-minute session"
        } else {
            suggestion = "Try a 15-minute session"
        }

        return NudgeResult(
            templateID: template.id,
            title: applySafetyFilter(title),
            body: applySafetyFilter(body),
            quickStartSuggestion: suggestion
        )
    }

    // MARK: - Safety Filter

    static func applySafetyFilter(_ text: String) -> String {
        let bannedPatterns = [
            "you failed", "you should be ashamed", "disappointed in you",
            "lazy", "pathetic", "useless", "waste of time", "giving up",
            "loser", "shame on", "what's wrong with you", "can't even",
            "you never", "you always fail",
        ]

        let lowered = text.lowercased()
        for pattern in bannedPatterns {
            if lowered.contains(pattern) {
                return "Great job focusing today. Keep it up!"
            }
        }

        // Length validation
        if text.count > 300 {
            return String(text.prefix(297)) + "..."
        }

        return text
    }

    // MARK: - Private Helpers

    private static func detectCategory(from taskName: String) -> String {
        let words = taskName.lowercased().components(separatedBy: .alphanumerics.inverted)
        for word in words {
            if let category = CoachTemplateCatalog.keywordCategories[word] {
                return category
            }
        }
        return "general"
    }

    private static func framingCondition(from signal: BehaviorSignal) -> TemplateCondition {
        if signal.totalSessions7d < 3 {
            return .newUser
        }
        if signal.abandonRate7d > 0.3 {
            return .highAbandon
        }
        if signal.completionRate7d < 0.5 {
            return .lowCompletion
        }
        if signal.completionRate7d >= 0.8 {
            return .highCompletion
        }
        return .default
    }

    private static func reflectionCondition(
        actualMinutes: Int,
        signal: BehaviorSignal
    ) -> TemplateCondition {
        if signal.totalSessions7d < 3 {
            return .newUser
        }
        if actualMinutes >= 40 {
            return .longSession
        }
        if actualMinutes < 15 {
            return .shortSession
        }
        if signal.abandonRate7d > 0.3 {
            return .highAbandon
        }
        if signal.completionRate7d < 0.5 {
            return .lowCompletion
        }
        if signal.completionRate7d >= 0.8 {
            return .highCompletion
        }
        return .default
    }

    private static func recentTemplateIDs(
        featureType: AIFeatureType,
        limit: Int,
        in context: ModelContext
    ) -> Set<String> {
        let targetType = featureType
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
}
