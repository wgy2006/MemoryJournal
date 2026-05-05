import SwiftData
import SwiftUI

struct MemoriesView: View {
    let language: AppLanguage

    @Query(sort: \DiaryEntry.diaryDate, order: .reverse) private var entries: [DiaryEntry]

    private var favoriteEntries: [DiaryEntry] {
        entries.filter(\.isFavorite)
    }

    private var onThisDayEntries: [DiaryEntry] {
        let calendar = Calendar.current
        let today = Date()
        return entries.filter {
            !calendar.isDate($0.diaryDate, inSameDayAs: today)
                && calendar.component(.month, from: $0.diaryDate) == calendar.component(.month, from: today)
                && calendar.component(.day, from: $0.diaryDate) == calendar.component(.day, from: today)
        }
    }

    var body: some View {
        NavigationStack {
            AppPageContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {
                        StarryMemoryHero(language: language)

                        MemorySection(
                            title: L10n.t(.todayInPast, language),
                            entries: onThisDayEntries,
                            language: language
                        )

                        MemorySection(
                            title: L10n.t(.randomMemory, language),
                            entries: Array(entries.shuffled().prefix(3)),
                            language: language
                        )

                        MemorySection(
                            title: L10n.t(.favoriteMemories, language),
                            entries: Array(favoriteEntries.prefix(3)),
                            language: language
                        )
                    }
                    .padding(24)
                    .frame(maxWidth: 1180)
                }
            }
            .navigationTitle(L10n.t(.memories, language))
        }
    }
}

struct StarryMemoryHero: View {
    let language: AppLanguage

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("MemoriesHero")
                .resizable()
                .scaledToFill()

            LinearGradient(
                colors: [
                    .black.opacity(0.55),
                    .black.opacity(0.18),
                    .black.opacity(0.62)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )

            LinearGradient(
                colors: [
                    .black.opacity(0.05),
                    .black.opacity(0.46)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.t(.memoriesHeroTitle, language))
                    .font(.system(size: 58, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(L10n.t(.memoriesHeroSubtitle, language))
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white.opacity(0.78))
                    .lineLimit(2)
            }
            .padding(34)
        }
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.10))
        )
    }
}

struct MemorySection: View {
    let title: String
    let entries: [DiaryEntry]
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)

            if entries.isEmpty {
                AppPanel {
                    Text(L10n.t(.noEntries, language))
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 14)], spacing: 14) {
                    ForEach(entries) { entry in
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
    }
}
