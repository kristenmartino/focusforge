import SwiftUI
import SwiftData

struct QuestListView: View {
    @Query(sort: \QuestProgress.createdAt)
    private var allQuests: [QuestProgress]
    @Environment(\.modelContext) private var modelContext

    private var activeQuests: [QuestProgress] {
        allQuests.filter { $0.expiresAt > .now }
    }

    private var dailyQuests: [QuestProgress] {
        activeQuests.filter { $0.questType == .daily }
    }

    private var weeklyQuests: [QuestProgress] {
        activeQuests.filter { $0.questType == .weekly }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FFTheme.Background.primary.ignoresSafeArea()

                Group {
                    if activeQuests.isEmpty {
                        ContentUnavailableView(
                            "No Active Quests",
                            systemImage: "scroll",
                            description: Text("New quests appear daily at midnight.")
                        )
                    } else {
                        List {
                            if !dailyQuests.isEmpty {
                                Section("Daily Quests") {
                                    ForEach(dailyQuests, id: \.questID) { quest in
                                        QuestRowView(quest: quest) {
                                            QuestManager.claimReward(
                                                questID: quest.questID,
                                                in: modelContext
                                            )
                                        }
                                    }
                                    .listRowBackground(Color.white.opacity(0.04))
                                }
                            }
                            if !weeklyQuests.isEmpty {
                                Section("Weekly Quests") {
                                    ForEach(weeklyQuests, id: \.questID) { quest in
                                        QuestRowView(quest: quest) {
                                            QuestManager.claimReward(
                                                questID: quest.questID,
                                                in: modelContext
                                            )
                                        }
                                    }
                                    .listRowBackground(Color.white.opacity(0.04))
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Quests")
            .navigationBarTitleDisplayMode(.inline)
            .darkNavigationAppearance()
        }
    }
}
