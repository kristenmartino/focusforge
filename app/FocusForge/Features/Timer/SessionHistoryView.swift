import SwiftUI
import SwiftData

struct SessionHistoryView: View {
    @Query(sort: \SessionLog.startedAt, order: .reverse)
    private var sessions: [SessionLog]

    var body: some View {
        ZStack {
            FFTheme.Background.primary.ignoresSafeArea()

            Group {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        "No Sessions Yet",
                        systemImage: "clock",
                        description: Text("Complete a focus session to see your history.")
                    )
                } else {
                    List {
                        ForEach(groupedSessions, id: \.date) { group in
                            Section {
                                ForEach(group.sessions) { session in
                                    SessionRowView(session: session)
                                }
                                .listRowBackground(Color.white.opacity(0.04))
                            } header: {
                                Text(group.dateLabel)
                                    .foregroundStyle(FFTheme.Text.tertiary)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("History")
        .darkNavigationAppearance()
    }

    private var groupedSessions: [DayGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.startedAt)
        }
        return grouped
            .map { DayGroup(date: $0.key, sessions: $0.value) }
            .sorted { $0.date > $1.date }
    }
}

private struct DayGroup {
    let date: Date
    let sessions: [SessionLog]

    var dateLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(.dateTime.month(.wide).day().year())
        }
    }
}

private struct SessionRowView: View {
    let session: SessionLog

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.taskName.isEmpty ? sessionTypeLabel : session.taskName)
                    .font(.body)
                    .foregroundStyle(FFTheme.Text.primary)
                // Time-of-day · duration so older sessions are anchored in time (P2-9)
                Text("\(timeOfDayLabel) · \(durationLabel)")
                    .font(.caption)
                    .foregroundStyle(FFTheme.Text.tertiary)
            }

            Spacer()

            HStack(spacing: 12) {
                if session.xpEarned > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .accessibilityHidden(true)
                        Text("\(session.xpEarned)")
                            .font(.caption)
                    }
                    .foregroundStyle(FFTheme.Accent.gold)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(session.xpEarned) XP")
                }

                Image(systemName: outcomeIcon)
                    .foregroundStyle(outcomeColor)
                    .font(.subheadline)
                    .accessibilityLabel(session.outcome == .completed ? "Completed" : "Abandoned")
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }

    private var sessionTypeLabel: String {
        switch session.sessionType {
        case .focus: "Focus Session"
        case .shortBreak: "Short Break"
        case .longBreak: "Long Break"
        }
    }

    private var durationLabel: String {
        let minutes = session.actualDurationSeconds / 60
        let seconds = session.actualDurationSeconds % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }

    private var timeOfDayLabel: String {
        session.startedAt.formatted(date: .omitted, time: .shortened)
    }

    private var outcomeIcon: String {
        session.outcome == .completed ? "checkmark.circle.fill" : "xmark.circle.fill"
    }

    private var outcomeColor: Color {
        session.outcome == .completed ? FFTheme.Accent.green : FFTheme.Accent.red
    }
}

#Preview {
    NavigationStack {
        SessionHistoryView()
    }
    .modelContainer(for: SessionLog.self, inMemory: true)
}
