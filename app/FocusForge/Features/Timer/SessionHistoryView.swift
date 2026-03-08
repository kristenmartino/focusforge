import SwiftUI
import SwiftData

struct SessionHistoryView: View {
    @Query(sort: \SessionLog.startedAt, order: .reverse)
    private var sessions: [SessionLog]

    var body: some View {
        List {
            if sessions.isEmpty {
                ContentUnavailableView(
                    "No Sessions Yet",
                    systemImage: "clock",
                    description: Text("Complete a focus session to see your history.")
                )
            } else {
                ForEach(groupedSessions, id: \.date) { group in
                    Section(group.dateLabel) {
                        ForEach(group.sessions) { session in
                            SessionRowView(session: session)
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
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
                Text(durationLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 12) {
                if session.xpEarned > 0 {
                    Label("\(session.xpEarned)", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }

                Image(systemName: outcomeIcon)
                    .foregroundStyle(outcomeColor)
            }
        }
        .padding(.vertical, 2)
    }

    private var sessionTypeLabel: String {
        switch session.sessionType {
        case .focus: return "Focus Session"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
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

    private var outcomeIcon: String {
        session.outcome == .completed ? "checkmark.circle.fill" : "xmark.circle.fill"
    }

    private var outcomeColor: Color {
        session.outcome == .completed ? .green : .red
    }
}

#Preview {
    NavigationStack {
        SessionHistoryView()
    }
    .modelContainer(for: SessionLog.self, inMemory: true)
}
