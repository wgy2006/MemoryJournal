import SwiftData
import SwiftUI

struct LibraryView: View {
    let language: AppLanguage

    @Query(sort: \DiaryEntry.diaryDate, order: .reverse) private var entries: [DiaryEntry]

    private var allTags: [String] {
        Array(Set(entries.flatMap(\.tagNames))).sorted()
    }

    private var favoriteCount: Int {
        entries.filter(\.isFavorite).count
    }

    private var imageEntryCount: Int {
        entries.filter { entry in
            entry.attachments.contains { $0.type == .image }
        }.count
    }

    var body: some View {
        NavigationStack {
            AppPageContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        PageHeader(
                            L10n.t(.library, language),
                            subtitle: "\(entries.count) \(L10n.t(.journal, language))",
                            systemImage: "square.grid.2x2"
                        )

                        AppPanel {
                            VStack(alignment: .leading, spacing: 14) {
                                Text(L10n.t(.tags, language))
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.textPrimary)

                                if allTags.isEmpty {
                                    Text(L10n.t(.noEntries, language))
                                        .foregroundStyle(AppTheme.textSecondary)
                                } else {
                                    FlowTags(tags: allTags)
                                }
                            }
                        }

                        AppPanel {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(L10n.t(.mood, language))
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.textPrimary)

                                ForEach(MoodOption.allCases) { mood in
                                    CompactInfoRow(
                                        title: mood.displayName(language: language),
                                        value: "\(entries.filter { $0.mood == mood.rawValue }.count)",
                                        systemImage: mood.iconName
                                    )
                                }
                            }
                        }

                        AppPanel {
                            VStack(spacing: 6) {
                                CompactInfoRow(title: L10n.t(.favorite, language), value: "\(favoriteCount)", systemImage: "star")
                                CompactInfoRow(title: L10n.t(.photos, language), value: "\(imageEntryCount)", systemImage: "photo")
                                CompactInfoRow(title: L10n.t(.audio, language), value: L10n.t(.comingSoon, language), systemImage: "waveform")
                                CompactInfoRow(title: L10n.t(.video, language), value: L10n.t(.comingSoon, language), systemImage: "video")
                                CompactInfoRow(title: L10n.t(.location, language), value: L10n.t(.comingSoon, language), systemImage: "mappin.and.ellipse")
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: 980)
                }
            }
            .navigationTitle(L10n.t(.library, language))
        }
    }
}

struct FlowTags: View {
    let tags: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                TagChip(text: tag)
            }
        }
    }
}
