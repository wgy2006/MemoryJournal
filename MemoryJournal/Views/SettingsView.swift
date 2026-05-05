import SwiftUI

struct SettingsView: View {
    let language: AppLanguage

    @AppStorage("appLanguage") private var appLanguageRaw = AppLanguage.system.rawValue

    var body: some View {
        NavigationStack {
            AppPageContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        PageHeader(
                            L10n.t(.settings, language),
                            subtitle: L10n.t(.localStorage, language),
                            systemImage: "gearshape"
                        )

                        AppPanel {
                            VStack(alignment: .leading, spacing: 14) {
                                Text(L10n.t(.language, language))
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.textPrimary)

                                Picker(L10n.t(.language, language), selection: $appLanguageRaw) {
                                    Text(L10n.t(.systemLanguage, language)).tag(AppLanguage.system.rawValue)
                                    Text(L10n.t(.simplifiedChinese, language)).tag(AppLanguage.zhHans.rawValue)
                                    Text(L10n.t(.english, language)).tag(AppLanguage.english.rawValue)
                                }
                                .pickerStyle(.segmented)
                            }
                        }

                        AppPanel {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(L10n.t(.localStorage, language))
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.textPrimary)

                                Text(localStorageDescription)
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        AppPanel {
                            VStack(spacing: 6) {
                                CompactInfoRow(title: L10n.t(.backup, language), value: L10n.t(.comingSoon, language), systemImage: "externaldrive")
                                CompactInfoRow(title: L10n.t(.restore, language), value: L10n.t(.comingSoon, language), systemImage: "arrow.down.doc")
                                CompactInfoRow(title: L10n.t(.exportPDF, language), value: L10n.t(.comingSoon, language), systemImage: "doc.richtext")
                            }
                        }

                        AppPanel {
                            CompactInfoRow(title: L10n.t(.privacyLock, language), value: L10n.t(.comingSoon, language), systemImage: "lock")
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: 980)
                }
            }
            .navigationTitle(L10n.t(.settings, language))
        }
    }

    private var localStorageDescription: String {
        switch language {
        case .zhHans:
            "日记正文、标签、心情等会保存在本机。图片、语音、视频等媒体将使用本地文件目录，并在后续版本支持备份和恢复。"
        case .english:
            "Entries, tags, and moods are stored on this device. Photos, audio, and videos will use the local app directory, with backup and restore planned for later versions."
        case .system:
            L10n.t(.localStorage, language)
        }
    }
}
