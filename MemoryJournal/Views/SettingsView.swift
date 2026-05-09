import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    let language: AppLanguage

    @Environment(\.modelContext) private var modelContext
    @AppStorage("appLanguage") private var appLanguageRaw = AppLanguage.system.rawValue
    @Query(sort: \DiaryEntry.diaryDate, order: .reverse) private var entries: [DiaryEntry]
    @State private var exportURL: URL?
    @State private var pdfURL: URL?
    @State private var backupURL: URL?
    @State private var exportError: String?
    @State private var restoreMessage: String?
    @State private var showingBackupImporter = false
    @State private var showingBackupPreview = false
    @State private var pendingBackupURL: URL?
    @State private var backupPreview: JournalBackupPreview?
    @AppStorage("privacyLockEnabled") private var privacyLockEnabled = false

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
                            VStack(alignment: .leading, spacing: 12) {
                                Text(L10n.t(.backup, language))
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.textPrimary)

                                Button {
                                    prepareMarkdownExport()
                                } label: {
                                    Label(L10n.t(.exportMarkdown, language), systemImage: "doc.plaintext")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(AppTheme.teal)

                                if let exportURL {
                                    ShareLink(item: exportURL) {
                                        Label(L10n.t(.shareExport, language), systemImage: "square.and.arrow.up")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(.bordered)

                                    Label(L10n.t(.exportReady, language), systemImage: "checkmark.circle")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textSecondary)
                                }

                                if let exportError {
                                    Text(exportError)
                                        .font(.caption)
                                        .foregroundStyle(.red.opacity(0.85))
                                }

                                Divider()
                                    .overlay(AppTheme.border)

                                Button {
                                    preparePDFExport()
                                } label: {
                                    Label(L10n.t(.exportAllPDF, language), systemImage: "doc.richtext")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(AppTheme.sage)

                                if let pdfURL {
                                    ShareLink(item: pdfURL) {
                                        Label(L10n.t(.shareExport, language), systemImage: "square.and.arrow.up")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(.bordered)
                                }

                                Divider()
                                    .overlay(AppTheme.border)

                                Text(L10n.t(.fullBackup, language))
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.textPrimary)

                                Button {
                                    prepareFullBackup()
                                } label: {
                                    Label(L10n.t(.createFullBackup, language), systemImage: "externaldrive")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(AppTheme.gold)

                                if let backupURL {
                                    ShareLink(item: backupURL) {
                                        Label(L10n.t(.shareExport, language), systemImage: "square.and.arrow.up")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(.bordered)

                                    Label(L10n.t(.backupReady, language), systemImage: "checkmark.circle")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textSecondary)
                                }

                                Button {
                                    showingBackupImporter = true
                                } label: {
                                    Label(L10n.t(.importBackup, language), systemImage: "arrow.down.doc")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.bordered)

                                if let restoreMessage {
                                    Text(restoreMessage)
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textSecondary)
                                }

                                Divider()
                                    .overlay(AppTheme.border)
                            }
                        }

                        AppPanel {
                            Toggle(isOn: $privacyLockEnabled) {
                                Label(L10n.t(.privacyLock, language), systemImage: "lock")
                                    .foregroundStyle(AppTheme.textPrimary)
                            }
                            .tint(AppTheme.teal)

                            if privacyLockEnabled {
                                Text(L10n.t(.privacyLockEnabled, language))
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .padding(.top, 6)
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: 980)
                }
            }
            .navigationTitle(L10n.t(.settings, language))
        }
        .fileImporter(
            isPresented: $showingBackupImporter,
            allowedContentTypes: [.json]
        ) { result in
            prepareBackupPreview(from: result)
        }
        .alert(L10n.t(.backupPreview, language), isPresented: $showingBackupPreview) {
            Button(L10n.t(.confirmRestore, language)) {
                if let pendingBackupURL {
                    restoreBackup(from: pendingBackupURL)
                }
            }
            Button(L10n.t(.cancel, language), role: .cancel) {}
        } message: {
            if let backupPreview {
                Text(
                    "\(L10n.t(.entriesCount, language)): \(backupPreview.entryCount)\n"
                    + "\(L10n.t(.attachmentsCount, language)): \(backupPreview.attachmentCount)\n"
                    + "\(L10n.t(.newEntriesCount, language)): \(backupPreview.newEntryCount)"
                )
            }
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

    private func prepareMarkdownExport() {
        do {
            exportURL = try DiaryMarkdownExporter.export(entries: entries, language: language)
            exportError = nil
        } catch {
            exportURL = nil
            exportError = L10n.t(.exportFailed, language)
        }
    }

    private func preparePDFExport() {
        do {
            pdfURL = try DiaryPDFExporter.export(
                entries: entries,
                language: language,
                fileStem: "MemoryJournal-All"
            )
            exportError = nil
        } catch {
            pdfURL = nil
            exportError = L10n.t(.exportFailed, language)
        }
    }

    private func prepareFullBackup() {
        do {
            backupURL = try DiaryBackupManager.export(entries: entries)
            exportError = nil
        } catch {
            backupURL = nil
            exportError = L10n.t(.exportFailed, language)
        }
    }

    private func prepareBackupPreview(from result: Result<URL, Error>) {
        do {
            let url = try result.get()
            let shouldStopAccessing = url.startAccessingSecurityScopedResource()
            defer {
                if shouldStopAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            let data = try Data(contentsOf: url)

            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("MemoryJournal-Import-\(UUID().uuidString).memoryjournal.json")
            try data.write(to: tempURL, options: [.atomic])

            backupPreview = try DiaryBackupManager.preview(from: tempURL, existingEntries: entries)
            pendingBackupURL = tempURL
            showingBackupPreview = true
        } catch {
            restoreMessage = L10n.t(.restoreFailed, language)
        }
    }

    private func restoreBackup(from url: URL) {
        do {
            let restoredCount = try DiaryBackupManager.restore(
                from: url,
                existingEntries: entries,
                modelContext: modelContext
            )
            restoreMessage = "\(L10n.t(.restoreComplete, language)): \(restoredCount)"
            pendingBackupURL = nil
            backupPreview = nil
        } catch {
            restoreMessage = L10n.t(.restoreFailed, language)
        }
    }
}
