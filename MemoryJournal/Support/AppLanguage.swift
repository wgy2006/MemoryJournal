import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case zhHans
    case english

    var id: String { rawValue }
}

enum L10nKey {
    case journal
    case memories
    case search
    case library
    case settings
    case newEntry
    case title
    case body
    case mood
    case tags
    case favorite
    case edit
    case delete
    case preview
    case write
    case save
    case cancel
    case photos
    case audio
    case video
    case location
    case noEntries
    case noEntriesHint
    case memoriesHeroTitle
    case memoriesHeroSubtitle
    case todayInPast
    case randomMemory
    case favoriteMemories
    case searchPlaceholder
    case allMoods
    case localStorage
    case language
    case systemLanguage
    case simplifiedChinese
    case english
    case backup
    case restore
    case exportPDF
    case exportAllPDF
    case exportEntryPDF
    case privacyLock
    case unlockJournal
    case privacyLockEnabled
    case privacyLockFailed
    case comingSoon
    case calm
    case happy
    case tired
    case sad
    case grateful
    case excited
    case relaxed
    case anxious
    case angry
    case bored
    case focused
    case inspired
    case lonely
    case sick
    case sleepy
    case stressed
    case proud
    case noResults
    case markdownHint
    case addTagPlaceholder
    case contentDrawers
    case addPhoto
    case removePhoto
    case addMedia
    case removeVideo
    case playVideo
    case mediaImportFailed
    case exportMarkdown
    case shareExport
    case exportReady
    case exportFailed
    case savedLocally
    case photoImportFailed
    case fullBackup
    case createFullBackup
    case importBackup
    case backupReady
    case restoreComplete
    case restoreFailed
    case backupPreview
    case backupContains
    case confirmRestore
    case entriesCount
    case attachmentsCount
    case newEntriesCount
    case recordAudio
    case stopRecording
    case playAudio
    case removeAudio
    case audioImportFailed
    case chooseLocation
    case locationName
    case saveLocation
    case removeLocation
    case openInMaps
    case currentLocation
    case searchMap
    case locationSearchPlaceholder
    case useThisLocation
    case locationFailed
    case dateRange
    case startDate
    case endDate
    case allTags
    case locationFilter
}

enum L10n {
    static func t(_ key: L10nKey, _ language: AppLanguage) -> String {
        let resolved = resolve(language)
        switch resolved {
        case .zhHans:
            return zhHans[key] ?? english[key] ?? ""
        case .english, .system:
            return english[key] ?? ""
        }
    }

    private static func resolve(_ language: AppLanguage) -> AppLanguage {
        if language != .system {
            return language
        }

        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        return languageCode.hasPrefix("zh") ? .zhHans : .english
    }

    private static let zhHans: [L10nKey: String] = [
        .journal: "日记",
        .memories: "往事",
        .search: "搜索",
        .library: "分类",
        .settings: "设置",
        .newEntry: "新建",
        .title: "标题",
        .body: "正文",
        .mood: "心情",
        .tags: "标签",
        .favorite: "收藏",
        .edit: "编辑",
        .delete: "删除",
        .preview: "预览",
        .write: "写作",
        .save: "保存",
        .cancel: "取消",
        .photos: "图片",
        .audio: "语音",
        .video: "视频",
        .location: "位置",
        .noEntries: "还没有日记",
        .noEntriesHint: "写下今天的一点点，它以后会变成线索。",
        .memoriesHeroTitle: "往事",
        .memoriesHeroSubtitle: "有些夜晚，会替我们把过去照亮。",
        .todayInPast: "往年今日",
        .randomMemory: "随机回忆",
        .favoriteMemories: "收藏回忆",
        .searchPlaceholder: "搜索关键词、地点或事件",
        .allMoods: "全部心情",
        .localStorage: "本地存储",
        .language: "语言",
        .systemLanguage: "跟随系统",
        .simplifiedChinese: "简体中文",
        .english: "English",
        .backup: "备份",
        .restore: "恢复",
        .exportPDF: "导出 PDF",
        .exportAllPDF: "导出全部 PDF",
        .exportEntryPDF: "导出本篇 PDF",
        .privacyLock: "隐私锁",
        .unlockJournal: "解锁日记",
        .privacyLockEnabled: "已开启隐私锁",
        .privacyLockFailed: "解锁失败，请再试一次",
        .comingSoon: "后续加入",
        .calm: "平静",
        .happy: "开心",
        .tired: "疲惫",
        .sad: "低落",
        .grateful: "感恩",
        .excited: "激动",
        .relaxed: "放松",
        .anxious: "焦虑",
        .angry: "生气",
        .bored: "无聊",
        .focused: "专注",
        .inspired: "有灵感",
        .lonely: "孤独",
        .sick: "不舒服",
        .sleepy: "困了",
        .stressed: "压力大",
        .proud: "自豪",
        .noResults: "没有找到相关日记",
        .markdownHint: "支持 Markdown。图片、语音、位置会以内容抽屉形式加入。",
        .addTagPlaceholder: "标签，用逗号分隔",
        .contentDrawers: "内容抽屉",
        .addPhoto: "添加图片",
        .removePhoto: "删除图片",
        .addMedia: "添加图片或视频",
        .removeVideo: "删除视频",
        .playVideo: "播放视频",
        .mediaImportFailed: "媒体导入失败，请换一个文件再试",
        .exportMarkdown: "导出 Markdown",
        .shareExport: "分享导出文件",
        .exportReady: "导出文件已准备好",
        .exportFailed: "导出失败，请稍后再试",
        .savedLocally: "已保存在本机",
        .photoImportFailed: "图片导入失败，请换一张再试",
        .fullBackup: "完整备份",
        .createFullBackup: "创建完整备份",
        .importBackup: "导入备份",
        .backupReady: "完整备份已准备好",
        .restoreComplete: "恢复完成",
        .restoreFailed: "恢复失败，请检查备份文件",
        .backupPreview: "备份预览",
        .backupContains: "备份内容",
        .confirmRestore: "确认恢复",
        .entriesCount: "日记数",
        .attachmentsCount: "附件数",
        .newEntriesCount: "可导入",
        .recordAudio: "开始录音",
        .stopRecording: "停止录音",
        .playAudio: "播放语音",
        .removeAudio: "删除语音",
        .audioImportFailed: "录音保存失败，请稍后再试",
        .chooseLocation: "选择位置",
        .locationName: "位置名称",
        .saveLocation: "保存位置",
        .removeLocation: "移除位置",
        .openInMaps: "在地图中打开",
        .currentLocation: "当前位置",
        .searchMap: "从地图中搜索",
        .locationSearchPlaceholder: "搜索地点、店名或地址",
        .useThisLocation: "使用这个位置",
        .locationFailed: "位置获取失败，请检查权限或换关键词",
        .dateRange: "日期范围",
        .startDate: "开始日期",
        .endDate: "结束日期",
        .allTags: "全部标签",
        .locationFilter: "地点筛选"
    ]

    private static let english: [L10nKey: String] = [
        .journal: "Journal",
        .memories: "Memories",
        .search: "Search",
        .library: "Library",
        .settings: "Settings",
        .newEntry: "New",
        .title: "Title",
        .body: "Body",
        .mood: "Mood",
        .tags: "Tags",
        .favorite: "Favorite",
        .edit: "Edit",
        .delete: "Delete",
        .preview: "Preview",
        .write: "Write",
        .save: "Save",
        .cancel: "Cancel",
        .photos: "Photos",
        .audio: "Audio",
        .video: "Video",
        .location: "Location",
        .noEntries: "No entries yet",
        .noEntriesHint: "Write a little from today. It will become a clue later.",
        .memoriesHeroTitle: "Memories",
        .memoriesHeroSubtitle: "Some nights quietly light up the past.",
        .todayInPast: "On This Day",
        .randomMemory: "Random Memory",
        .favoriteMemories: "Favorites",
        .searchPlaceholder: "Search keywords, places, or events",
        .allMoods: "All moods",
        .localStorage: "Local Storage",
        .language: "Language",
        .systemLanguage: "System",
        .simplifiedChinese: "Simplified Chinese",
        .english: "English",
        .backup: "Backup",
        .restore: "Restore",
        .exportPDF: "Export PDF",
        .exportAllPDF: "Export All PDF",
        .exportEntryPDF: "Export Entry PDF",
        .privacyLock: "Privacy Lock",
        .unlockJournal: "Unlock Journal",
        .privacyLockEnabled: "Privacy lock enabled",
        .privacyLockFailed: "Unlock failed. Please try again.",
        .comingSoon: "Coming soon",
        .calm: "Calm",
        .happy: "Happy",
        .tired: "Tired",
        .sad: "Low",
        .grateful: "Grateful",
        .excited: "Excited",
        .relaxed: "Relaxed",
        .anxious: "Anxious",
        .angry: "Angry",
        .bored: "Bored",
        .focused: "Focused",
        .inspired: "Inspired",
        .lonely: "Lonely",
        .sick: "Sick",
        .sleepy: "Sleepy",
        .stressed: "Stressed",
        .proud: "Proud",
        .noResults: "No matching entries",
        .markdownHint: "Markdown is supported. Photos, audio, and locations will appear as content drawers.",
        .addTagPlaceholder: "Tags, separated by commas",
        .contentDrawers: "Content Drawers",
        .addPhoto: "Add Photos",
        .removePhoto: "Remove Photo",
        .addMedia: "Add Photos or Videos",
        .removeVideo: "Remove Video",
        .playVideo: "Play Video",
        .mediaImportFailed: "Media import failed. Please try another file.",
        .exportMarkdown: "Export Markdown",
        .shareExport: "Share Export",
        .exportReady: "Export file is ready",
        .exportFailed: "Export failed. Please try again.",
        .savedLocally: "Saved locally",
        .photoImportFailed: "Photo import failed. Please try another image.",
        .fullBackup: "Full Backup",
        .createFullBackup: "Create Full Backup",
        .importBackup: "Import Backup",
        .backupReady: "Full backup is ready",
        .restoreComplete: "Restore complete",
        .restoreFailed: "Restore failed. Please check the backup file.",
        .backupPreview: "Backup Preview",
        .backupContains: "Backup Contains",
        .confirmRestore: "Confirm Restore",
        .entriesCount: "Entries",
        .attachmentsCount: "Attachments",
        .newEntriesCount: "New Entries",
        .recordAudio: "Record Audio",
        .stopRecording: "Stop Recording",
        .playAudio: "Play Audio",
        .removeAudio: "Remove Audio",
        .audioImportFailed: "Audio could not be saved. Please try again.",
        .chooseLocation: "Choose Location",
        .locationName: "Location Name",
        .saveLocation: "Save Location",
        .removeLocation: "Remove Location",
        .openInMaps: "Open in Maps",
        .currentLocation: "Current Location",
        .searchMap: "Search on Map",
        .locationSearchPlaceholder: "Search a place, venue, or address",
        .useThisLocation: "Use This Location",
        .locationFailed: "Could not get that location. Check permission or try another keyword.",
        .dateRange: "Date Range",
        .startDate: "Start Date",
        .endDate: "End Date",
        .allTags: "All Tags",
        .locationFilter: "Location Filter"
    ]
}

enum MoodOption: String, CaseIterable, Identifiable {
    case calm
    case happy
    case tired
    case sad
    case grateful
    case excited
    case relaxed
    case anxious
    case angry
    case bored
    case focused
    case inspired
    case lonely
    case sick
    case sleepy
    case stressed
    case proud

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .calm: "😌"
        case .happy: "😊"
        case .tired: "😮‍💨"
        case .sad: "😔"
        case .grateful: "🙏"
        case .excited: "🤩"
        case .relaxed: "🌿"
        case .anxious: "😟"
        case .angry: "😠"
        case .bored: "😶"
        case .focused: "🧠"
        case .inspired: "💡"
        case .lonely: "🌙"
        case .sick: "🤧"
        case .sleepy: "😴"
        case .stressed: "😵‍💫"
        case .proud: "😎"
        }
    }

    var iconName: String {
        switch self {
        case .calm: "moon.stars"
        case .happy: "sun.max"
        case .tired: "cloud"
        case .sad: "drop"
        case .grateful: "heart"
        case .excited: "sparkles"
        case .relaxed: "leaf"
        case .anxious: "exclamationmark.circle"
        case .angry: "flame"
        case .bored: "ellipsis.bubble"
        case .focused: "brain.head.profile"
        case .inspired: "lightbulb"
        case .lonely: "moon"
        case .sick: "cross.case"
        case .sleepy: "bed.double"
        case .stressed: "bolt.heart"
        case .proud: "star"
        }
    }

    var l10nKey: L10nKey {
        switch self {
        case .calm: .calm
        case .happy: .happy
        case .tired: .tired
        case .sad: .sad
        case .grateful: .grateful
        case .excited: .excited
        case .relaxed: .relaxed
        case .anxious: .anxious
        case .angry: .angry
        case .bored: .bored
        case .focused: .focused
        case .inspired: .inspired
        case .lonely: .lonely
        case .sick: .sick
        case .sleepy: .sleepy
        case .stressed: .stressed
        case .proud: .proud
        }
    }

    func displayName(language: AppLanguage) -> String {
        "\(emoji) \(L10n.t(l10nKey, language))"
    }
}
