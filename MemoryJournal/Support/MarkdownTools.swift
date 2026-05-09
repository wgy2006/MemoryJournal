import Foundation
import SwiftData

#if canImport(UIKit)
import UIKit
#endif

enum MarkdownTools {
    static func plainText(from markdown: String) -> String {
        markdown
            .replacingOccurrences(of: #"!\[[^\]]*\]\([^\)]*\)"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"\[[^\]]+\]\([^\)]*\)"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"[#>*_`~\-]"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func attributedString(from markdown: String) -> AttributedString {
        if let rendered = try? AttributedString(markdown: markdown) {
            return rendered
        }

        return AttributedString(markdown)
    }
}

enum AttachmentFileStore {
    private static let appFolderName = "MemoryJournal"
    private static let attachmentsFolderName = "Attachments"

    static func save(data: Data, fileExtension: String) throws -> String {
        let sanitizedExtension = fileExtension.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let safeExtension = sanitizedExtension.isEmpty ? "jpg" : sanitizedExtension
        let fileName = "\(UUID().uuidString).\(safeExtension)"
        let relativePath = "\(attachmentsFolderName)/\(fileName)"
        let url = fileURL(for: relativePath)

        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: url, options: [.atomic])

        return relativePath
    }

    static func reserveFile(fileExtension: String) throws -> (relativePath: String, url: URL) {
        let sanitizedExtension = fileExtension.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let safeExtension = sanitizedExtension.isEmpty ? "dat" : sanitizedExtension
        let fileName = "\(UUID().uuidString).\(safeExtension)"
        let relativePath = "\(attachmentsFolderName)/\(fileName)"
        let url = fileURL(for: relativePath)

        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        return (relativePath, url)
    }

    static func fileURL(for relativePath: String) -> URL {
        rootDirectory.appendingPathComponent(relativePath)
    }

    static func deleteFile(at relativePath: String) {
        try? FileManager.default.removeItem(at: fileURL(for: relativePath))
    }

    private static var rootDirectory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent(appFolderName, isDirectory: true)
    }
}

struct JournalBackupFile: Codable {
    var version: Int
    var exportedAt: Date
    var entries: [JournalEntryBackup]
}

struct JournalEntryBackup: Codable {
    var id: UUID
    var title: String
    var markdownContent: String
    var plainTextContent: String
    var diaryDate: Date
    var createdAt: Date
    var updatedAt: Date
    var mood: String
    var weather: String
    var locationName: String
    var latitude: Double?
    var longitude: Double?
    var isFavorite: Bool
    var isArchived: Bool
    var tagNamesText: String
    var attachments: [JournalAttachmentBackup]
}

struct JournalAttachmentBackup: Codable {
    var id: UUID
    var typeRaw: String
    var localPath: String
    var displayName: String
    var createdAt: Date
    var duration: Double?
    var width: Double?
    var height: Double?
    var sortOrder: Int
    var dataBase64: String?
}

struct JournalBackupPreview {
    var entryCount: Int
    var attachmentCount: Int
    var newEntryCount: Int
}

enum DiaryBackupManager {
    static func export(entries: [DiaryEntry]) throws -> URL {
        let backup = JournalBackupFile(
            version: 1,
            exportedAt: Date(),
            entries: entries
                .sorted { $0.diaryDate > $1.diaryDate }
                .map(entryBackup)
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let fileName = "MemoryJournal-FullBackup-\(compactDateFormatter.string(from: Date())).memoryjournal.json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try encoder.encode(backup).write(to: url, options: [.atomic])
        return url
    }

    static func restore(
        from url: URL,
        existingEntries: [DiaryEntry],
        modelContext: ModelContext
    ) throws -> Int {
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let backup = try decoder.decode(JournalBackupFile.self, from: Data(contentsOf: url))
        let existingIDs = Set(existingEntries.map(\.id))
        var restoredCount = 0

        for item in backup.entries where !existingIDs.contains(item.id) {
            let entry = DiaryEntry(
                id: item.id,
                title: item.title,
                markdownContent: item.markdownContent,
                plainTextContent: item.plainTextContent,
                diaryDate: item.diaryDate,
                createdAt: item.createdAt,
                updatedAt: item.updatedAt,
                mood: item.mood,
                weather: item.weather,
                locationName: item.locationName,
                latitude: item.latitude,
                longitude: item.longitude,
                isFavorite: item.isFavorite,
                isArchived: item.isArchived,
                tagNamesText: item.tagNamesText
            )

            modelContext.insert(entry)

            for attachmentItem in item.attachments {
                let restoredPath = try restoreAttachmentFile(from: attachmentItem)
                let attachment = DiaryAttachment(
                    id: attachmentItem.id,
                    type: DiaryAttachmentType(rawValue: attachmentItem.typeRaw) ?? .image,
                    localPath: restoredPath,
                    displayName: attachmentItem.displayName,
                    createdAt: attachmentItem.createdAt,
                    duration: attachmentItem.duration,
                    width: attachmentItem.width,
                    height: attachmentItem.height,
                    sortOrder: attachmentItem.sortOrder
                )
                modelContext.insert(attachment)
                entry.attachments.append(attachment)
            }

            restoredCount += 1
        }

        try modelContext.save()
        return restoredCount
    }

    static func preview(from url: URL, existingEntries: [DiaryEntry]) throws -> JournalBackupPreview {
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let backup = try decoder.decode(JournalBackupFile.self, from: Data(contentsOf: url))
        let existingIDs = Set(existingEntries.map(\.id))
        let newEntryCount = backup.entries.filter { !existingIDs.contains($0.id) }.count
        let attachmentCount = backup.entries.reduce(0) { $0 + $1.attachments.count }

        return JournalBackupPreview(
            entryCount: backup.entries.count,
            attachmentCount: attachmentCount,
            newEntryCount: newEntryCount
        )
    }

    private static func entryBackup(_ entry: DiaryEntry) -> JournalEntryBackup {
        JournalEntryBackup(
            id: entry.id,
            title: entry.title,
            markdownContent: entry.markdownContent,
            plainTextContent: entry.plainTextContent,
            diaryDate: entry.diaryDate,
            createdAt: entry.createdAt,
            updatedAt: entry.updatedAt,
            mood: entry.mood,
            weather: entry.weather,
            locationName: entry.locationName,
            latitude: entry.latitude,
            longitude: entry.longitude,
            isFavorite: entry.isFavorite,
            isArchived: entry.isArchived,
            tagNamesText: entry.tagNamesText,
            attachments: entry.attachments
                .sorted { $0.sortOrder < $1.sortOrder }
                .map(attachmentBackup)
        )
    }

    private static func attachmentBackup(_ attachment: DiaryAttachment) -> JournalAttachmentBackup {
        let data = try? Data(contentsOf: AttachmentFileStore.fileURL(for: attachment.localPath))

        return JournalAttachmentBackup(
            id: attachment.id,
            typeRaw: attachment.typeRaw,
            localPath: attachment.localPath,
            displayName: attachment.displayName,
            createdAt: attachment.createdAt,
            duration: attachment.duration,
            width: attachment.width,
            height: attachment.height,
            sortOrder: attachment.sortOrder,
            dataBase64: data?.base64EncodedString()
        )
    }

    private static func restoreAttachmentFile(from backup: JournalAttachmentBackup) throws -> String {
        guard let dataBase64 = backup.dataBase64,
              let data = Data(base64Encoded: dataBase64) else {
            return backup.localPath
        }

        let fileExtension = URL(fileURLWithPath: backup.localPath).pathExtension
        return try AttachmentFileStore.save(data: data, fileExtension: fileExtension)
    }

    private static let compactDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter
    }()
}

enum DiaryPDFExporter {
    static func export(entries: [DiaryEntry], language: AppLanguage, fileStem: String = "MemoryJournal") throws -> URL {
        let sortedEntries = entries.sorted { $0.diaryDate > $1.diaryDate }
        let fileName = "\(fileStem)-\(compactDateFormatter.string(from: Date())).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        #if canImport(UIKit)
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [
            kCGPDFContextTitle as String: "MemoryJournal",
            kCGPDFContextCreator as String: "MemoryJournal"
        ]
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let margin: CGFloat = 48
        let contentWidth = pageRect.width - margin * 2

        try renderer.writePDF(to: url) { context in
            var y = margin
            let ink = UIColor(red: 0.075, green: 0.082, blue: 0.105, alpha: 1)
            let secondaryInk = UIColor(red: 0.380, green: 0.400, blue: 0.460, alpha: 1)
            let mutedInk = UIColor(red: 0.540, green: 0.560, blue: 0.620, alpha: 1)
            let tealInk = UIColor(red: 0.105, green: 0.480, blue: 0.500, alpha: 1)
            let lineInk = UIColor(red: 0.850, green: 0.870, blue: 0.900, alpha: 1)

            func beginPage() {
                context.beginPage()
                UIColor.white.setFill()
                UIBezierPath(rect: pageRect).fill()
                y = margin
            }

            func ensureSpace(_ needed: CGFloat) {
                if y + needed > pageRect.height - margin {
                    beginPage()
                }
            }

            func attributes(font: UIFont, color: UIColor, lineSpacing: CGFloat = 3) -> [NSAttributedString.Key: Any] {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .byWordWrapping
                paragraphStyle.lineSpacing = lineSpacing
                return [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraphStyle
                ]
            }

            func textHeight(_ string: String, attributes: [NSAttributedString.Key: Any]) -> CGFloat {
                let text = string.isEmpty ? " " : string
                let rect = NSString(string: text).boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
                return ceil(rect.height)
            }

            func drawSingleText(_ string: String, attributes: [NSAttributedString.Key: Any], height: CGFloat) {
                let text = string.isEmpty ? " " : string
                NSString(string: text).draw(
                    with: CGRect(x: margin, y: y, width: contentWidth, height: height + 4),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
            }

            func fittingPrefix(
                of string: String,
                attributes: [NSAttributedString.Key: Any],
                availableHeight: CGFloat
            ) -> String {
                let characters = Array(string)
                guard !characters.isEmpty else { return " " }

                var low = 1
                var high = characters.count
                var best = 1

                while low <= high {
                    let mid = (low + high) / 2
                    let candidate = String(characters.prefix(mid))
                    if textHeight(candidate, attributes: attributes) <= availableHeight {
                        best = mid
                        low = mid + 1
                    } else {
                        high = mid - 1
                    }
                }

                var prefix = Array(characters.prefix(best))
                if best < characters.count,
                   let splitIndex = prefix.lastIndex(where: { $0.isWhitespace }),
                   splitIndex > prefix.startIndex {
                    prefix = Array(prefix[...splitIndex])
                }

                return String(prefix)
            }

            func drawTextBlock(
                _ string: String,
                font: UIFont,
                color: UIColor,
                spacingAfter: CGFloat = 10,
                lineSpacing: CGFloat = 3
            ) {
                var remaining = string.isEmpty ? " " : string
                let textAttributes = attributes(font: font, color: color, lineSpacing: lineSpacing)
                let minimumLineHeight = font.lineHeight + lineSpacing + 4

                while !remaining.isEmpty {
                    var availableHeight = pageRect.height - margin - y
                    if availableHeight < minimumLineHeight {
                        beginPage()
                        availableHeight = pageRect.height - margin - y
                    }

                    let fullHeight = textHeight(remaining, attributes: textAttributes)
                    if fullHeight <= availableHeight {
                        drawSingleText(remaining, attributes: textAttributes, height: fullHeight)
                        y += fullHeight + spacingAfter
                        break
                    }

                    let prefix = fittingPrefix(
                        of: remaining,
                        attributes: textAttributes,
                        availableHeight: availableHeight
                    )
                    let prefixHeight = textHeight(prefix, attributes: textAttributes)
                    drawSingleText(prefix, attributes: textAttributes, height: prefixHeight)

                    let consumed = min(prefix.count, remaining.count)
                    remaining.removeFirst(consumed)
                    remaining = remaining.trimmingCharacters(in: .whitespacesAndNewlines)
                    beginPage()
                }
            }

            func drawRule() {
                ensureSpace(16)
                lineInk.setStroke()
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: y))
                path.addLine(to: CGPoint(x: pageRect.width - margin, y: y))
                path.lineWidth = 1
                path.stroke()
                y += 18
            }

            func drawImageAttachment(_ attachment: DiaryAttachment) {
                let url = AttachmentFileStore.fileURL(for: attachment.localPath)
                guard let image = UIImage(contentsOfFile: url.path), image.size.width > 0, image.size.height > 0 else {
                    drawTextBlock(
                        "\(L10n.t(.photos, language)): \(attachment.displayName)",
                        font: .systemFont(ofSize: 11),
                        color: mutedInk,
                        spacingAfter: 6
                    )
                    return
                }

                let maxImageSize = CGSize(width: contentWidth, height: 330)
                let scale = min(maxImageSize.width / image.size.width, maxImageSize.height / image.size.height, 1)
                let drawSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                ensureSpace(drawSize.height + 42)

                let imageRect = CGRect(
                    x: margin + (contentWidth - drawSize.width) / 2,
                    y: y,
                    width: drawSize.width,
                    height: drawSize.height
                )

                UIColor(red: 0.965, green: 0.970, blue: 0.980, alpha: 1).setFill()
                UIBezierPath(roundedRect: imageRect.insetBy(dx: -6, dy: -6), cornerRadius: 8).fill()
                image.draw(in: imageRect)
                y += drawSize.height + 14

                drawTextBlock(
                    attachment.displayName,
                    font: .systemFont(ofSize: 10),
                    color: mutedInk,
                    spacingAfter: 12
                )
            }

            beginPage()

            drawTextBlock(
                "MemoryJournal",
                font: .boldSystemFont(ofSize: 26),
                color: ink,
                spacingAfter: 2,
                lineSpacing: 1
            )
            drawTextBlock(
                "\(L10n.t(.journal, language)) · \(Date().diaryDateString())",
                font: .systemFont(ofSize: 11, weight: .medium),
                color: secondaryInk,
                spacingAfter: 20,
                lineSpacing: 1
            )
            drawRule()

            for entry in sortedEntries {
                ensureSpace(120)
                let title = entry.title.isEmpty ? L10n.t(.journal, language) : entry.title
                let mood = (MoodOption(rawValue: entry.mood) ?? .calm).displayName(language: language)
                let header = "\(entry.diaryDate.diaryDateString()) · \(title)"
                let metadata = metadataLines(for: entry, mood: mood, language: language).joined(separator: "\n")

                drawTextBlock(
                    header,
                    font: .boldSystemFont(ofSize: 17),
                    color: ink,
                    spacingAfter: 8
                )

                drawTextBlock(
                    metadata,
                    font: .systemFont(ofSize: 11),
                    color: secondaryInk,
                    spacingAfter: 16,
                    lineSpacing: 2
                )

                let body = entry.markdownContent.isEmpty ? entry.plainTextContent : entry.markdownContent
                if !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    drawTextBlock(
                        body,
                        font: .systemFont(ofSize: 13.5),
                        color: ink,
                        spacingAfter: 18,
                        lineSpacing: 4
                    )
                }

                let imageAttachments = entry.attachments
                    .filter { $0.type == .image }
                    .sorted { $0.sortOrder < $1.sortOrder }

                if !imageAttachments.isEmpty {
                    ensureSpace(40)
                    drawTextBlock(
                        L10n.t(.photos, language),
                        font: .boldSystemFont(ofSize: 14),
                        color: tealInk,
                        spacingAfter: 12
                    )
                    imageAttachments.forEach(drawImageAttachment)
                }

                let audioAttachments = entry.attachments
                    .filter { $0.type == .audio }
                    .sorted { $0.sortOrder < $1.sortOrder }
                let videoAttachments = entry.attachments
                    .filter { $0.type == .video }
                    .sorted { $0.sortOrder < $1.sortOrder }

                if !audioAttachments.isEmpty || !videoAttachments.isEmpty {
                    let attachmentLines = (audioAttachments.map { "\(L10n.t(.audio, language)): \($0.displayName)" }
                        + videoAttachments.map { "\(L10n.t(.video, language)): \($0.displayName)" })
                        .joined(separator: "\n")
                    drawTextBlock(
                        attachmentLines,
                        font: .systemFont(ofSize: 11),
                        color: secondaryInk,
                        spacingAfter: 18
                    )
                }

                drawRule()
            }
        }

        return url
        #else
        throw CocoaError(.fileWriteUnknown)
        #endif
    }

    private static func metadataLines(for entry: DiaryEntry, mood: String, language: AppLanguage) -> [String] {
        var lines = ["\(L10n.t(.mood, language)): \(mood)"]

        if !entry.tagNames.isEmpty {
            lines.append("\(L10n.t(.tags, language)): \(entry.tagNames.joined(separator: ", "))")
        }
        if !entry.locationName.isEmpty {
            lines.append("\(L10n.t(.location, language)): \(entry.locationName)")
        }

        return lines
    }

    private static let compactDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter
    }()
}

enum DiaryMarkdownExporter {
    static func export(entries: [DiaryEntry], language: AppLanguage) throws -> URL {
        let sortedEntries = entries.sorted { $0.diaryDate > $1.diaryDate }
        let fileName = "MemoryJournal-Export-\(compactDateFormatter.string(from: Date())).md"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try markdown(for: sortedEntries, language: language).write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private static func markdown(for entries: [DiaryEntry], language: AppLanguage) -> String {
        var sections: [String] = [
            "# MemoryJournal Export",
            "",
            "Generated: \(displayDateFormatter.string(from: Date()))",
            ""
        ]

        for entry in entries {
            let title = entry.title.isEmpty ? L10n.t(.journal, language) : entry.title
            let mood = (MoodOption(rawValue: entry.mood) ?? .calm).displayName(language: language)

            sections.append("## \(displayDateFormatter.string(from: entry.diaryDate)) - \(title)")
            sections.append("")
            sections.append("- \(L10n.t(.mood, language)): \(mood)")

            if !entry.tagNames.isEmpty {
                sections.append("- \(L10n.t(.tags, language)): \(entry.tagNames.joined(separator: ", "))")
            }

            let imageAttachments = entry.attachments
                .filter { $0.type == .image }
                .sorted { $0.sortOrder < $1.sortOrder }

            if !imageAttachments.isEmpty {
                sections.append("- \(L10n.t(.photos, language)): \(imageAttachments.map(\.displayName).joined(separator: ", "))")
            }

            let audioAttachments = entry.attachments
                .filter { $0.type == .audio }
                .sorted { $0.sortOrder < $1.sortOrder }

            if !audioAttachments.isEmpty {
                sections.append("- \(L10n.t(.audio, language)): \(audioAttachments.map(\.displayName).joined(separator: ", "))")
            }

            let videoAttachments = entry.attachments
                .filter { $0.type == .video }
                .sorted { $0.sortOrder < $1.sortOrder }

            if !videoAttachments.isEmpty {
                sections.append("- \(L10n.t(.video, language)): \(videoAttachments.map(\.displayName).joined(separator: ", "))")
            }

            if !entry.locationName.isEmpty {
                sections.append("- \(L10n.t(.location, language)): \(entry.locationName)")
            }

            sections.append("")
            sections.append(entry.markdownContent.isEmpty ? "_" : entry.markdownContent)
            sections.append("")
        }

        return sections.joined(separator: "\n")
    }

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()

    private static let compactDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter
    }()
}
