import SwiftData
import SwiftUI

struct SearchView: View {
    let language: AppLanguage

    @Query(sort: \DiaryEntry.diaryDate, order: .reverse) private var entries: [DiaryEntry]
    @State private var query = ""
    @State private var selectedMood = "all"
    @State private var selectedTag = "all"
    @State private var useDateRange = false
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var locationFilter = ""

    private var filteredEntries: [DiaryEntry] {
        entries.filter { entry in
            let matchesQuery = query.isEmpty
                || entry.title.localizedCaseInsensitiveContains(query)
                || entry.plainTextContent.localizedCaseInsensitiveContains(query)
                || entry.locationName.localizedCaseInsensitiveContains(query)
                || entry.tagNames.contains { $0.localizedCaseInsensitiveContains(query) }

            let matchesMood = selectedMood == "all" || entry.mood == selectedMood
            let matchesTag = selectedTag == "all" || entry.tagNames.contains(selectedTag)
            let matchesLocation = locationFilter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || entry.locationName.localizedCaseInsensitiveContains(locationFilter)
            let matchesDate = !useDateRange || dateRangeContains(entry.diaryDate)

            return matchesQuery && matchesMood && matchesTag && matchesLocation && matchesDate
        }
    }

    private var allTags: [String] {
        Array(Set(entries.flatMap(\.tagNames))).sorted()
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
                                        Text(mood.displayName(language: language)).tag(mood.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(AppTheme.teal)

                                Picker(L10n.t(.tags, language), selection: $selectedTag) {
                                    Text(L10n.t(.allTags, language)).tag("all")
                                    ForEach(allTags, id: \.self) { tag in
                                        Text(tag).tag(tag)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(AppTheme.teal)

                                HStack(spacing: 12) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundStyle(AppTheme.textMuted)

                                    TextField(L10n.t(.locationFilter, language), text: $locationFilter)
                                        .textFieldStyle(.plain)
                                        .foregroundStyle(AppTheme.textPrimary)
                                }
                                .padding(12)
                                .background(AppTheme.elevatedPanel, in: RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppTheme.border)
                                )

                                Toggle(isOn: $useDateRange) {
                                    Label(L10n.t(.dateRange, language), systemImage: "calendar")
                                        .foregroundStyle(AppTheme.textPrimary)
                                }
                                .tint(AppTheme.teal)

                                if useDateRange {
                                    HStack(spacing: 14) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(L10n.t(.startDate, language))
                                                .font(.caption)
                                                .foregroundStyle(AppTheme.textSecondary)
                                            DatePicker("", selection: $startDate, displayedComponents: .date)
                                                .labelsHidden()
                                                .tint(AppTheme.teal)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(L10n.t(.endDate, language))
                                                .font(.caption)
                                                .foregroundStyle(AppTheme.textSecondary)
                                            DatePicker("", selection: $endDate, displayedComponents: .date)
                                                .labelsHidden()
                                                .tint(AppTheme.teal)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
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

    private func dateRangeContains(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: min(startDate, endDate))
        let end = calendar.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: max(startDate, endDate)
        ) ?? max(startDate, endDate)

        return date >= start && date <= end
    }
}
