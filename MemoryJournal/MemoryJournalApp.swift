import SwiftData
import SwiftUI

@main
struct MemoryJournalApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [
            DiaryEntry.self,
            DiaryAttachment.self,
            DiaryTag.self
        ])
    }
}
