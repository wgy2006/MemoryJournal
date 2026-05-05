import SwiftData
import SwiftUI

struct SearchView: View {
    let language: AppLanguage

    @Query(sort: \DiaryEntry.diaryDate, order: .reverse) private var entries: [DiaryEntry]
    @State private var query = ""
    @State private var selectedMood = "all"

    private var filteredEntries: [DiaryEntry] {
        entries.filter { entry in
            let matchesQuery = query.isEmpty
                || entry.title.localizedCaseInsensitiveContains(query)
                || entry.plainTextContent.localizedCaseInsensitiveContains(query)
                || entry.locationName.localizedCaseInsensitiveContains(query)
                || entry.tagNames.contains { $0.localizedCaseInsensitiveContains(query) }

            let matchesMood = selectedMood == "all" || entry.mood == selectedMood

            return matchesQuery && matchesMood
        }
    }

    var body: some View {
        NavigationStack {
            AppPageContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        PageHeader(
                            L10n.t(.search, language),
                            subtitle: L10n.t(.searchPlaceholder, language),
                            systemImage: "magnifyingglass"
                        )

                        AppPanel {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(AppTheme.textMuted)

                                    TextField(L10n.t(.searchPlaceholder, language), text: $query)
                                        .textFieldStyle(.plain)
                                        .foregroundStyle(AppTheme.textPrimary)
                                }
                                .padding(12)
                                .background(AppTheme.elevatedPanel, in: RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppTheme.border)
                                )

                                Picker(L10n.t(.mood, language), selection: $selectedMood) {
                                    Text(L10n.t(.allMoods, language)).tag("all")
                                    ForEach(MoodOption.allCases) { mood in
                                        Text(L10n.t(mood.l10nKey, language)).tag(mood.rawValue)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }

                        if filteredEntries.isEmpty {
                            EmptyStateView(
                                title: L10n.t(.noResults, language),
                                subtitle: L10n.t(.searchPlaceholder, language),
                                systemImage: "doc.text.magnifyingglass"
                            )
                        } else {
                            LazyVStack(spacing: 14) {
                                ForEach(filteredEntries) { entry in
                                    NavigationLink {
                                        DiaryDetailView(entry: entry, language: language)
                                    } label: {
                                        DiaryRowView(entry: entry, language: language)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: 980)
                }
            }
            .navigationTitle(L10n.t(.search, language))
        }
    }
}
