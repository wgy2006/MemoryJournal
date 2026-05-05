import Foundation
import SwiftData

@Model
final class DiaryEntry {
    @Attribute(.unique) var id: UUID
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

    @Relationship(deleteRule: .cascade, inverse: \DiaryAttachment.entry)
    var attachments: [DiaryAttachment]

    init(
        id: UUID = UUID(),
        title: String = "",
        markdownContent: String = "",
        plainTextContent: String = "",
        diaryDate: Date = Date(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        mood: String = "calm",
        weather: String = "",
        locationName: String = "",
        latitude: Double? = nil,
        longitude: Double? = nil,
        isFavorite: Bool = false,
        isArchived: Bool = false,
        tagNamesText: String = "",
        attachments: [DiaryAttachment] = []
    ) {
        self.id = id
        self.title = title
        self.markdownContent = markdownContent
        self.plainTextContent = plainTextContent
        self.diaryDate = diaryDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.mood = mood
        self.weather = weather
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.isFavorite = isFavorite
        self.isArchived = isArchived
        self.tagNamesText = tagNamesText
        self.attachments = attachments
    }

    var tagNames: [String] {
        get {
            tagNamesText
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        set {
            tagNamesText = newValue
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: ",")
        }
    }
}
