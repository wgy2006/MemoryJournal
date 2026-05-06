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
    case privacyLock
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
        .privacyLock: "隐私锁",
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
        .contentDrawers: "内容抽屉"
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
        .privacyLock: "Privacy Lock",
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
        .contentDrawers: "Content Drawers"
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
