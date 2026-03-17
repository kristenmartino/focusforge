import Foundation
import SwiftData

struct BehaviorSignal {
    let completionRate7d: Double     // 0...1
    let abandonRate7d: Double        // 0...1
    let avgActualFocusMinutes: Double
    let streakRiskScore: Double      // 0...1
    let totalSessions7d: Int
    let dominantTaskKeywords: [String]
}

enum BehaviorSignalComputer {

    private static let stopWords: Set<String> = [
        "the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for",
        "of", "with", "by", "from", "is", "it", "my", "do", "some", "this",
        "that", "i", "me", "we", "up", "out", "get", "go", "work", "thing",
    ]

    static func compute(in context: ModelContext) -> BehaviorSignal {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: .now)!
        let focusType = SessionType.focus

        let descriptor = FetchDescriptor<SessionLog>(
            predicate: #Predicate<SessionLog> {
                $0.startedAt >= sevenDaysAgo && $0.sessionType == focusType
            }
        )
        let sessions = (try? context.fetch(descriptor)) ?? []

        let completedOutcome = SessionOutcome.completed
        let completed = sessions.filter { $0.outcome == completedOutcome }
        let abandoned = sessions.filter { $0.outcome != completedOutcome }

        let totalCount = sessions.count
        let completionRate = totalCount > 0 ? Double(completed.count) / Double(totalCount) : 0.5
        let abandonRate = totalCount > 0 ? Double(abandoned.count) / Double(totalCount) : 0.0

        let totalFocusSeconds = completed.reduce(0) { $0 + $1.actualDurationSeconds }
        let avgFocusMinutes = completed.isEmpty ? 25.0 : Double(totalFocusSeconds) / Double(completed.count) / 60.0

        let streakState = StreakManager.fetchOrCreateStreakState(in: context)
        let riskScore = streakRiskScore(streakState: streakState, calendar: calendar)

        let keywords = extractKeywords(from: sessions)

        return BehaviorSignal(
            completionRate7d: completionRate,
            abandonRate7d: abandonRate,
            avgActualFocusMinutes: avgFocusMinutes,
            streakRiskScore: riskScore,
            totalSessions7d: totalCount,
            dominantTaskKeywords: keywords
        )
    }

    static func streakRiskScore(streakState: StreakState, calendar: Calendar) -> Double {
        let now = Date.now
        let today = calendar.startOfDay(for: now)
        let currentHour = calendar.component(.hour, from: now)

        guard let lastDate = streakState.lastCompletedDate else {
            // No sessions ever — no streak to protect
            return 0.0
        }

        let lastDay = calendar.startOfDay(for: lastDate)
        let daysBetween = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

        if daysBetween == 0 {
            // Completed today — safe
            return 0.0
        }

        var baseRisk: Double

        if daysBetween == 1 {
            // Yesterday — risk rises through the evening
            if currentHour < 12 {
                baseRisk = 0.1
            } else if currentHour < 18 {
                baseRisk = 0.2
            } else {
                baseRisk = 0.3 + Double(currentHour - 18) * 0.1
            }
        } else {
            // 2+ days missed
            if streakState.freezesAvailable > 0 {
                baseRisk = 0.5
            } else {
                baseRisk = 1.0
            }
        }

        // Longer streaks get a slight boost to make nudge more protective
        let streakBoost = min(Double(streakState.currentStreakDays) * 0.02, 0.2)
        return min(1.0, baseRisk + streakBoost)
    }

    private static func extractKeywords(from sessions: [SessionLog]) -> [String] {
        var wordCounts: [String: Int] = [:]

        for session in sessions {
            let words = session.taskName
                .lowercased()
                .components(separatedBy: .alphanumerics.inverted)
                .filter { $0.count >= 3 && !stopWords.contains($0) }

            for word in words {
                wordCounts[word, default: 0] += 1
            }
        }

        return wordCounts
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map(\.key)
    }
}
