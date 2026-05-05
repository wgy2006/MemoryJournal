import Foundation
import SwiftData

enum DiaryAttachmentType: String, CaseIterable, Identifiable {
    case image
    case video
    case audio
    case location

    var id: String { rawValue }
}

@Model
final class DiaryAttachment {
    @Attribute(.unique) var id: UUID
    var typeRaw: String
    var localPath: String
    var displayName: String
    var createdAt: Date
    var duration: Double?
    var width: Double?
    var height: Double?
    var sortOrder: Int
    var entry: DiaryEntry?

    init(
        id: UUID = UUID(),
        type: DiaryAttachmentType = .image,
        localPath: String = "",
        displayName: String = "",
        createdAt: Date = Date(),
        duration: Double? = nil,
        width: Double? = nil,
        height: Double? = nil,
        sortOrder: Int = 0,
        entry: DiaryEntry? = nil
    ) {
        self.id = id
        self.typeRaw = type.rawValue
        self.localPath = localPath
        self.displayName = displayName
        self.createdAt = createdAt
        self.duration = duration
        self.width = width
        self.height = height
        self.sortOrder = sortOrder
        self.entry = entry
    }

    var type: DiaryAttachmentType {
        get { DiaryAttachmentType(rawValue: typeRaw) ?? .image }
        set { typeRaw = newValue.rawValue }
    }
}
