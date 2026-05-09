import SwiftData
import SwiftUI

struct JournalView: View {
    let language: AppLanguage

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DiaryEntry.diaryDate, order: .reverse) private var entries: [DiaryEntry]
    @State private var editingEntry: DiaryEntry?

    var body: some View {
        NavigationStack {
            AppPageContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        PageHeader(
                            L10n.t(.journal, language),
                            subtitle: Date().diaryDateString(),
                            systemImage: "book.closed"
                        )

                        if entries.isEmpty {
                            EmptyStateView(
                                title: L10n.t(.noEntries, language),
                                subtitle: L10n.t(.noEntriesHint, language),
                                systemImage: "moon.stars"
                            )
                        } else {
                            LazyVStack(spacing: 14) {
                                ForEach(entries) { entry in
                                    NavigationLink {
                                        DiaryDetailView(entry: entry, language: language)
                                    } label: {
                                        DiaryRowView(entry: entry, language: language)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button {
                                            entry.isFavorite.toggle()
                                            entry.updatedAt = Date()
                                        } label: {
                                            Label(L10n.t(.favorite, language), systemImage: "star")
                                        }

                                        Button(role: .destructive) {
                                            modelContext.delete(entry)
                                        } label: {
                                            Label(L10n.t(.delete, language), systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: 980)
                }
            }
            .navigationTitle(L10n.t(.journal, language))
            .toolbar {
                ToolbarItem {
                    Button {
                        createEntry()
                    } label: {
                        Label(L10n.t(.newEntry, language), systemImage: "square.and.pencil")
                    }
                }
            }
            .sheet(item: $editingEntry) { entry in
                NavigationStack {
                    EditDiaryView(entry: entry, language: language, deleteEmptyDraftOnCancel: true)
                }
            }
        }
    }

    private func createEntry() {
        let entry = DiaryEntry(
            title: "",
            markdownContent: "",
            plainTextContent: "",
            diaryDate: Date(),
            mood: MoodOption.calm.rawValue
        )
        modelContext.insert(entry)
        editingEntry = entry
    }
}

struct DiaryRowView: View {
    let entry: DiaryEntry
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.diaryDate.diaryDateString())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)

                Spacer()

                if entry.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(AppTheme.gold)
                }
            }

            Text(rowTitle)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)

            if !entry.plainTextContent.isEmpty {
                Text(entry.plainTextContent)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(2)
            }

            HStack(spacing: 12) {
                MoodPill(moodRaw: entry.mood, language: language)

                if !entry.attachments.isEmpty {
                    Label("\(entry.attachments.count)", systemImage: "paperclip")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()
            }

            if !entry.tagNames.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(entry.tagNames, id: \.self) { tag in
                            TagChip(text: tag)
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(AppTheme.panel, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.border)
        )
    }

    private var rowTitle: String {
        if !entry.title.isEmpty {
            return entry.title
        }

        if !entry.plainTextContent.isEmpty {
            return entry.plainTextContent
        }

        return L10n.t(.newEntry, language)
    }
}

struct DiaryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var entry: DiaryEntry
    let language: AppLanguage
    @State private var isEditing = false
    @State private var showingDeleteConfirmation = false
    @State private var pdfURL: URL?
    @State private var exportError: String?

    var body: some View {
        AppPageContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    PageHeader(
                        entry.title.isEmpty ? L10n.t(.journal, language) : entry.title,
                        subtitle: entry.diaryDate.diaryDateString(),
                        systemImage: "doc.text"
                    )

                    AppPanel {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                MoodPill(moodRaw: entry.mood, language: language)

                                if entry.isFavorite {
                                    Label(L10n.t(.favorite, language), systemImage: "star.fill")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.gold)
                                }

                                Spacer()
                            }

                            if !entry.tagNames.isEmpty {
                                HStack {
                                    ForEach(entry.tagNames, id: \.self) { tag in
                                        TagChip(text: tag)
                                    }
                                }
                            }
                        }
                    }

                    AppPanel {
                        Text(MarkdownTools.attributedString(from: entry.markdownContent.isEmpty ? " " : entry.markdownContent))
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(maxWidth: .infinity, minHeight: 240, alignment: .topLeading)
                    }

                    if hasContentDrawers {
                        AppPanel {
                            VStack(alignment: .leading, spacing: 14) {
                                if !imageAttachments.isEmpty {
                                    Text(L10n.t(.photos, language))
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.textPrimary)

                                    ImageAttachmentGrid(
                                        attachments: imageAttachments,
                                        language: language
                                    )
                                }

                                if !audioAttachments.isEmpty {
                                    Text(L10n.t(.audio, language))
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.textPrimary)

                                    AudioAttachmentList(
                                        attachments: audioAttachments,
                                        language: language
                                    )
                                }

                                if !videoAttachments.isEmpty {
                                    Text(L10n.t(.video, language))
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.textPrimary)

                                    VideoAttachmentList(
                                        attachments: videoAttachments,
                                        language: language
                                    )
                                }

                                if !entry.locationName.isEmpty {
                                    Text(L10n.t(.location, language))
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.textPrimary)

                                    LocationDrawerRow(
                                        locationName: entry.locationName,
                                        latitude: entry.latitude,
                                        longitude: entry.longitude,
                                        language: language
                                    )
                                }
                            }
                        }
                    }

                    AppPanel {
                        VStack(alignment: .leading, spacing: 10) {
                            Button {
                                prepareEntryPDF()
                            } label: {
                                Label(L10n.t(.exportEntryPDF, language), systemImage: "doc.richtext")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.bordered)
                            .tint(AppTheme.sage)

                            if let pdfURL {
                                ShareLink(item: pdfURL) {
                                    Label(L10n.t(.shareExport, language), systemImage: "square.and.arrow.up")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.bordered)
                            }

                            if let exportError {
                                Text(exportError)
                                    .font(.caption)
                                    .foregroundStyle(.red.opacity(0.85))
                            }
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: 980)
            }
        }
        .navigationTitle(entry.title.isEmpty ? L10n.t(.journal, language) : entry.title)
        .toolbar {
            ToolbarItem {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label(L10n.t(.delete, language), systemImage: "trash")
                }
            }

            ToolbarItem {
                Button(L10n.t(.edit, language)) {
                    isEditing = true
                }
            }
        }
        .confirmationDialog(
            L10n.t(.delete, language),
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(L10n.t(.delete, language), role: .destructive) {
                deleteEntry()
                dismiss()
            }
            Button(L10n.t(.cancel, language), role: .cancel) {}
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                EditDiaryView(entry: entry, language: language)
            }
        }
    }

    private func deleteEntry() {
        entry.attachments.forEach { AttachmentFileStore.deleteFile(at: $0.localPath) }
        modelContext.delete(entry)
    }

    private func prepareEntryPDF() {
        do {
            pdfURL = try DiaryPDFExporter.export(
                entries: [entry],
                language: language,
                fileStem: "MemoryJournal-Entry"
            )
            exportError = nil
        } catch {
            pdfURL = nil
            exportError = L10n.t(.exportFailed, language)
        }
    }

    private var imageAttachments: [DiaryAttachment] {
        entry.attachments
            .filter { $0.type == .image }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private var audioAttachments: [DiaryAttachment] {
        entry.attachments
            .filter { $0.type == .audio }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private var videoAttachments: [DiaryAttachment] {
        entry.attachments
            .filter { $0.type == .video }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private var hasContentDrawers: Bool {
        !imageAttachments.isEmpty
            || !audioAttachments.isEmpty
            || !videoAttachments.isEmpty
            || !entry.locationName.isEmpty
    }
}
