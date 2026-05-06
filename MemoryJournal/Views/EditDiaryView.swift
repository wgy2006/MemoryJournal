import SwiftData
import SwiftUI

struct EditDiaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var entry: DiaryEntry
    let language: AppLanguage
    var deleteEmptyDraftOnCancel = false

    @State private var showingPreview = false
    @State private var tagText = ""
    @State private var showingDeleteConfirmation = false

    var body: some View {
        AppPageContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    PageHeader(
                        L10n.t(.edit, language),
                        subtitle: L10n.t(.markdownHint, language),
                        systemImage: "square.and.pencil"
                    )

                    AppPanel {
                        VStack(alignment: .leading, spacing: 18) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(L10n.t(.title, language))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppTheme.textSecondary)

                                TextField(L10n.t(.title, language), text: $entry.title)
                                    .textFieldStyle(.plain)
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .padding(12)
                                    .background(AppTheme.elevatedPanel, in: RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppTheme.border)
                                    )
                            }

                            HStack(alignment: .top, spacing: 14) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(entry.diaryDate.diaryDateString())
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(AppTheme.textSecondary)

                                    DatePicker("", selection: $entry.diaryDate, displayedComponents: .date)
                                        .labelsHidden()
                                        .tint(AppTheme.teal)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(L10n.t(.mood, language))
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(AppTheme.textSecondary)

                                    Picker(L10n.t(.mood, language), selection: $entry.mood) {
                                        ForEach(MoodOption.allCases) { mood in
                                            Text(mood.displayName(language: language))
                                                .tag(mood.rawValue)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(AppTheme.teal)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text(L10n.t(.tags, language))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppTheme.textSecondary)

                                TextField(L10n.t(.addTagPlaceholder, language), text: $tagText)
                                    .textFieldStyle(.plain)
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .padding(12)
                                    .background(AppTheme.elevatedPanel, in: RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppTheme.border)
                                    )
                                    .onAppear {
                                        tagText = entry.tagNames.joined(separator: ", ")
                                    }
                                    .onChange(of: tagText) { _, newValue in
                                        entry.tagNames = newValue
                                            .split(separator: ",")
                                            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                                    }
                            }
                        }
                    }

                    AppPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text(L10n.t(.body, language))
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.textPrimary)

                                Spacer()

                                Picker("", selection: $showingPreview) {
                                    Text(L10n.t(.write, language)).tag(false)
                                    Text(L10n.t(.preview, language)).tag(true)
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 220)
                            }

                            if showingPreview {
                                MarkdownPreview(markdown: entry.markdownContent)
                                    .frame(minHeight: 360)
                                    .padding(14)
                                    .background(AppTheme.elevatedPanel, in: RoundedRectangle(cornerRadius: 8))
                            } else {
                                TextEditor(text: $entry.markdownContent)
                                    .font(.body)
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .scrollContentBackground(.hidden)
                                    .frame(minHeight: 360)
                                    .padding(10)
                                    .background(AppTheme.elevatedPanel, in: RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppTheme.border)
                                    )
                                    .onChange(of: entry.markdownContent) { _, newValue in
                                        entry.plainTextContent = MarkdownTools.plainText(from: newValue)
                                        entry.updatedAt = Date()
                                    }
                            }
                        }
                    }

                    AppPanel {
                        VStack(alignment: .leading, spacing: 14) {
                            Text(L10n.t(.contentDrawers, language))
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 12)], spacing: 12) {
                                PlaceholderDrawerButton(
                                    title: L10n.t(.photos, language),
                                    systemImage: "photo.on.rectangle",
                                    subtitle: L10n.t(.comingSoon, language)
                                )
                                PlaceholderDrawerButton(
                                    title: L10n.t(.audio, language),
                                    systemImage: "waveform",
                                    subtitle: L10n.t(.comingSoon, language)
                                )
                                PlaceholderDrawerButton(
                                    title: L10n.t(.location, language),
                                    systemImage: "mappin.and.ellipse",
                                    subtitle: L10n.t(.comingSoon, language)
                                )
                            }
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: 980)
            }
        }
        .navigationTitle(L10n.t(.edit, language))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(L10n.t(.cancel, language)) {
                    if deleteEmptyDraftOnCancel && isEntryBlank {
                        modelContext.delete(entry)
                    }
                    dismiss()
                }
            }

            ToolbarItem {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label(L10n.t(.delete, language), systemImage: "trash")
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(L10n.t(.save, language)) {
                    save()
                    dismiss()
                }
            }
        }
        .confirmationDialog(
            L10n.t(.delete, language),
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(L10n.t(.delete, language), role: .destructive) {
                modelContext.delete(entry)
                dismiss()
            }
            Button(L10n.t(.cancel, language), role: .cancel) {}
        }
    }

    private func save() {
        entry.plainTextContent = MarkdownTools.plainText(from: entry.markdownContent)
        entry.updatedAt = Date()
    }

    private var isEntryBlank: Bool {
        entry.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && entry.markdownContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && entry.tagNames.isEmpty
    }
}
