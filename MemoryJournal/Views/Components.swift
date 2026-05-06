import SwiftUI

enum AppTheme {
    static let background = LinearGradient(
        colors: [
            Color(red: 0.025, green: 0.030, blue: 0.050),
            Color(red: 0.045, green: 0.060, blue: 0.095),
            Color(red: 0.075, green: 0.090, blue: 0.105)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let panel = Color(red: 0.075, green: 0.086, blue: 0.115)
    static let elevatedPanel = Color(red: 0.105, green: 0.119, blue: 0.150)
    static let border = Color.white.opacity(0.08)
    static let textPrimary = Color.white.opacity(0.94)
    static let textSecondary = Color.white.opacity(0.62)
    static let textMuted = Color.white.opacity(0.42)
    static let teal = Color(red: 0.260, green: 0.780, blue: 0.760)
    static let gold = Color(red: 0.900, green: 0.700, blue: 0.360)
    static let sage = Color(red: 0.560, green: 0.690, blue: 0.610)
}

struct AppPageContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            content
        }
    }
}

struct PageHeader: View {
    let title: String
    let subtitle: String?
    let systemImage: String?

    init(_ title: String, subtitle: String? = nil, systemImage: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.teal)
                    .frame(width: 38, height: 38)
                    .background(AppTheme.teal.opacity(0.13), in: RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            Spacer()
        }
    }
}

struct AppPanel<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .background(AppTheme.panel, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.border)
            )
    }
}

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        AppPanel {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(AppTheme.teal)

                Text(title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 360)
            }
            .frame(maxWidth: .infinity, minHeight: 260)
        }
    }
}

struct TagChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(AppTheme.teal)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AppTheme.teal.opacity(0.14), in: Capsule())
    }
}

struct MoodPill: View {
    let moodRaw: String
    let language: AppLanguage

    var body: some View {
        let mood = MoodOption(rawValue: moodRaw) ?? .calm

        Text(mood.displayName(language: language))
            .font(.caption)
            .foregroundStyle(AppTheme.textSecondary)
    }
}

struct PlaceholderDrawerButton: View {
    let title: String
    let systemImage: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .frame(width: 24, height: 24)
                .foregroundStyle(AppTheme.teal)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.down")
                .font(.caption)
                .foregroundStyle(AppTheme.textMuted)
        }
        .padding(14)
        .background(AppTheme.elevatedPanel, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.border)
        )
    }
}

struct MarkdownPreview: View {
    let markdown: String

    var body: some View {
        ScrollView {
            Text(MarkdownTools.attributedString(from: markdown.isEmpty ? " " : markdown))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
        }
    }
}

struct CompactInfoRow: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(AppTheme.gold)
                .frame(width: 24)

            Text(title)
                .foregroundStyle(AppTheme.textPrimary)

            Spacer()

            Text(value)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .font(.subheadline)
        .padding(.vertical, 8)
    }
}

extension Date {
    func diaryDateString() -> String {
        formatted(.dateTime.year().month().day())
    }

    func diaryMonthDayString() -> String {
        formatted(.dateTime.month().day())
    }
}
