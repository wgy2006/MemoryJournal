import SwiftUI

struct AppRootView: View {
    @AppStorage("appLanguage") private var appLanguageRaw = AppLanguage.system.rawValue

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguageRaw) ?? .system
    }

    var body: some View {
        TabView {
            JournalView(language: language)
                .tabItem {
                    Label(L10n.t(.journal, language), systemImage: "book.closed")
                }

            MemoriesView(language: language)
                .tabItem {
                    Label(L10n.t(.memories, language), systemImage: "sparkles")
                }

            SearchView(language: language)
                .tabItem {
                    Label(L10n.t(.search, language), systemImage: "magnifyingglass")
                }

            LibraryView(language: language)
                .tabItem {
                    Label(L10n.t(.library, language), systemImage: "square.grid.2x2")
                }

            SettingsView(language: language)
                .tabItem {
                    Label(L10n.t(.settings, language), systemImage: "gearshape")
                }
        }
        .tint(AppTheme.teal)
        .preferredColorScheme(.dark)
    }
}
