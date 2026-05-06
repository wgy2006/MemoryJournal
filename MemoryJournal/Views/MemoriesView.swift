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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle(L10n.t(.memories, language))
        }
    }
}

struct StarryMemoryHero: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let language: AppLanguage

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    private var heroHeight: CGFloat {
        isCompact ? 230 : 280
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                Image("MemoriesHero")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: heroHeight)
                    .clipped()

                LinearGradient(
                    colors: [
                        .black.opacity(isCompact ? 0.72 : 0.55),
                        .black.opacity(0.24),
                        .black.opacity(isCompact ? 0.68 : 0.62)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )

                LinearGradient(
                    colors: [
                        .black.opacity(0.06),
                        .black.opacity(0.50)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: isCompact ? 8 : 12) {
                    Text(L10n.t(.memoriesHeroTitle, language))
                        .font(.system(size: isCompact ? 42 : 58, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(L10n.t(.memoriesHeroSubtitle, language))
                        .font(isCompact ? .subheadline.weight(.semibold) : .title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.80))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: max(proxy.size.width - (isCompact ? 44 : 68), 120), alignment: .leading)
                }
                .padding(isCompact ? 22 : 34)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.10))
            )
        }
        .frame(height: heroHeight)
        .frame(maxWidth: .infinity)
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
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 14)], spacing: 14) {
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
