# Memory Journal

[English](#english) | [中文](#中文)

A local-first iOS diary app prototype built with SwiftUI and SwiftData.  
一个使用 SwiftUI + SwiftData 构建的本地优先 iOS 日记应用原型。

![Memory Journal app icon](MemoryJournal/Assets.xcassets/AppIcon.appiconset/app-icon-1024.png)

---

## 中文

### 简介

Memory Journal 是一个**本地优先（local-first）**的 iOS 日记应用原型，面向私人、长期的写作与回忆整理。它支持 Markdown 写作、心情与标签组织、搜索，以及未来的 AI 增强能力规划。

产品方向很简单：**自由书写、数据只存本地、让旧回忆更容易被重新发现。**

### 亮点（Highlights）

- 使用 SwiftData 进行本地优先的日记存储
- Markdown 写作与预览
- 日记时间线：心情、标签、收藏、附件等元数据
- 往事（Memories）页面：电影感夜空视觉
- 支持按标题、正文、地点、标签、心情搜索
- 分类（Library）入口：标签、心情、收藏、照片、音频、视频、地点
- 双语导航与文案：简体中文 / English
- 深色、安静的视觉系统，更贴近私密日记氛围
- 内容抽屉概念：照片 / 音频 / 视频 / 位置
- 面向未来的 AI 规划：摘要、标签提取、生成回忆配图等

### 视觉方向（Visual Direction）

整体视觉采用克制的夜空主题：深海军蓝背景、柔和月光、低饱和青绿色点缀与温暖高光。核心画面概念是一家人安静坐在草地与野花中，抬头看星空，强调“私密、安静、可长期陪伴”的感觉。

![Memories hero](MemoryJournal/Assets.xcassets/MemoriesHero.imageset/memories-hero.png)

### 导航（Navigation）

应用分为 5 个主要 Tab：

| 中文 | English | 用途 |
| --- | --- | --- |
| 日记 | Journal | 时间线、写作、编辑、阅读 |
| 往事 | Memories | 旧条目、收藏、“这一天”回忆 |
| 搜索 | Search | 关键词与心情等维度的发现 |
| 分类 | Library | 标签/心情/收藏/媒体/地点等入口 |
| 设置 | Settings | 语言、本地存储、备份、导出、隐私 |

### 技术栈（Tech Stack）

- SwiftUI
- SwiftData
- iOS 17+
- Xcode 16+
- 本地沙盒存储
- Asset Catalog（图标与生成视觉资源）

### 当前原型范围（Current Prototype Scope）

当前原型包含：

- SwiftUI 项目结构
- 五 Tab 导航
- SwiftData 数据模型草案：
  - `DiaryEntry`
  - `DiaryAttachment`
  - `DiaryTag`
- 日记创建、编辑、详情、删除，以及空草稿清理
- Markdown 写作/预览流程
- 心情选择器
- 标签输入
- 收藏状态
- 搜索 UI
- 分类（Library）UI
- 设置 UI
- 图片、视频、语音与位置附件
- 多图浏览、视频缩略图、语音播放进度
- 单篇 / 全部 PDF 导出
- Markdown 导出
- 完整备份与恢复
- Face ID / Touch ID 隐私锁
- App 内启动动画
- 生成的应用图标
- 生成的 Memories Hero 图

### 计划功能（Planned Features）

- 更好的 SwiftData Schema 更新迁移处理
- AI 自动摘要
- AI 标签与关键词提取
- AI 生成回忆配图
- 自然语言日记搜索

### 本地数据模型（Local Data Model）

应用围绕本地持久化设计：

- 结构化日记数据由 SwiftData 保存
- 大媒体（照片/视频/音频）建议存放在 App 本地文件目录
- SwiftData 保存媒体元数据与文件引用，而不是直接存二进制大对象
- 第一版本刻意不做云同步

重要限制：

如果 App 从 iPhone 删除，本地数据会随之删除。后续会通过“备份与恢复”来降低长期使用风险。

### 运行方式（Running The App）

在 Xcode 中打开项目：

```bash
open MemoryJournal.xcodeproj
```

推荐环境：

- Xcode 16+
- iOS 17+
- 已开启开发者模式的 iPhone，或已安装 iOS 模拟器运行时

真机测试步骤：

1. 连接 iPhone 到 Mac
2. 在 Xcode 选择设备
3. 打开 `MemoryJournal` target > `Signing & Capabilities`
4. 启用 `Automatically manage signing`
5. 选择你的 Apple Developer team 或 Personal Team
6. 使用唯一的 Bundle Identifier，例如：

```text
com.yourname.MemoryJournal
```

7. `Cmd + R` 运行

### 项目结构（Project Structure）

```text
MemoryJournal/
├── MemoryJournal.xcodeproj
├── MemoryJournal/
│   ├── MemoryJournalApp.swift
│   ├── AppRootView.swift
│   ├── Models/
│   ├── Support/
│   ├── Views/
│   └── Assets.xcassets/
├── docs/
│   └── TESTING_CHECKLIST.md
├── README.md
└── .gitignore
```

### 备注（Notes）

这是一个早期产品原型，并非已完成的 App Store 成品。当前重点是验证产品方向、本地优先数据模型、核心日记流程与视觉语言。

长期目标是把 Memory Journal 做成一个私密的记忆图书馆：让书写、搜索、回望、重新发现过去都变得自然。

---

## English

### Overview

Memory Journal is a **local-first** iOS diary app prototype built with SwiftUI and SwiftData. It’s designed for private, long-term journaling with Markdown writing, mood and tag organization, search, and future AI planning.

The product direction is simple: **write freely, keep everything local, and make old memories easy to rediscover later.**

### Highlights

- Local-first diary storage with SwiftData
- Markdown writing and preview
- Journal timeline with mood, tags, favorites, and attachments metadata
- Memories page with a cinematic night-sky visual
- Search by title, body text, location, tags, and mood
- Library view for tags, moods, favorites, photos, audio, video, and location entry points
- Bilingual navigation and copy: Simplified Chinese and English
- Dark, quiet visual system for a more private diary feel
- Content drawer concept for photos, audio, video, and location
- Future-ready AI planning for summaries, tag extraction, and generated memory images

### Visual Direction

The app uses a restrained night-sky theme: deep navy backgrounds, soft moonlight, muted teal accents, and warm highlights. The main visual idea is a family sitting quietly in grass and wildflowers, looking up at the sky—private, calm, and long-lasting.

![Memories hero](MemoryJournal/Assets.xcassets/MemoriesHero.imageset/memories-hero.png)

### Navigation

The app is organized around five main tabs:

| Chinese | English | Purpose |
| --- | --- | --- |
| 日记 | Journal | Timeline, writing, editing, reading |
| 往事 | Memories | Old entries, favorites, “on this day” memories |
| 搜索 | Search | Keyword and mood-based discovery |
| 分类 | Library | Tags, moods, favorites, media, location entry points |
| 设置 | Settings | Language, local storage, backup, export, privacy |

### Tech Stack

- SwiftUI
- SwiftData
- iOS 17+
- Xcode 16+
- Local app sandbox storage
- Asset catalogs for app icon and generated visual assets

### Current Prototype Scope

This prototype currently includes:

- SwiftUI project structure
- Five-tab navigation
- SwiftData model drafts:
  - `DiaryEntry`
  - `DiaryAttachment`
  - `DiaryTag`
- Journal creation, editing, detail view, deletion, and empty draft cleanup
- Markdown write/preview flow
- Mood picker
- Tag input
- Favorite state
- Search UI
- Library UI
- Settings UI
- Photo, video, audio, and location attachments
- Multi-photo gallery, video thumbnails, and audio playback progress
- Single-entry and full PDF export
- Markdown export
- Full backup and restore
- Face ID / Touch ID privacy lock
- In-app launch animation
- Generated app icon
- Generated memories hero image

### Planned Features

- Better migration handling for SwiftData schema updates
- AI-generated summaries
- AI tag and keyword extraction
- AI-generated memory images
- Natural-language diary search

### Local Data Model

The app is designed around local persistence:

- Structured diary data is stored with SwiftData.
- Large media files such as photos, videos, and audio should be stored in the app’s local file directory.
- SwiftData should store media metadata and file references, not raw media blobs.
- Cloud sync is intentionally out of scope for the first version.

Important limitation:

If the app is deleted from the iPhone, local app data is deleted with it. A future backup and restore feature is planned to make long-term use safer.

### Running The App

Open the project in Xcode:

```bash
open MemoryJournal.xcodeproj
```

Recommended environment:

- Xcode 16+
- iOS 17+
- An iPhone with Developer Mode enabled, or an installed iOS simulator runtime

For real-device testing:

1. Connect the iPhone to the Mac.
2. Select the device in Xcode.
3. Open `MemoryJournal` target > `Signing & Capabilities`.
4. Enable `Automatically manage signing`.
5. Select your Apple Developer team or Personal Team.
6. Use a unique bundle identifier, for example:

```text
com.yourname.MemoryJournal
```

7. Run with `Cmd + R`.

### Project Structure

```text
MemoryJournal/
├── MemoryJournal.xcodeproj
├── MemoryJournal/
│   ├── MemoryJournalApp.swift
│   ├── AppRootView.swift
│   ├── Models/
│   ├── Support/
│   ├── Views/
│   └── Assets.xcassets/
├── docs/
│   └── TESTING_CHECKLIST.md
├── README.md
└── .gitignore
```

### Notes

This is an early product prototype, not a finished App Store release. The current focus is validating the product direction, local-first data model, core diary workflow, and visual language.

The long-term goal is to turn Memory Journal into a private memory library: a place where writing, searching, reflecting, and rediscovering old days all feel natural.
