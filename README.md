# Memory Journal

Memory Journal is a local-first iOS diary app prototype built with SwiftUI and SwiftData. It is designed for private, long-term journaling with Markdown writing, mood and tag organization, search, and a quiet “memories” experience.

The product direction is simple: write freely, keep everything local, and make old memories easy to rediscover later.

![Memory Journal app icon](MemoryJournal/Assets.xcassets/AppIcon.appiconset/app-icon-1024.png)

## Highlights

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

## Visual Direction

The app uses a restrained night-sky theme: deep navy backgrounds, soft moonlight, muted teal accents, and warm highlights. The main visual idea is a family sitting quietly in grass and wildflowers, looking up at the stars.

![Memories hero](MemoryJournal/Assets.xcassets/MemoriesHero.imageset/memories-hero.png)

## Navigation

The app is organized around five main tabs:

| Chinese | English | Purpose |
| --- | --- | --- |
| 日记 | Journal | Timeline, writing, editing, reading |
| 往事 | Memories | Old entries, favorites, “on this day” memories |
| 搜索 | Search | Keyword and mood-based discovery |
| 分类 | Library | Tags, moods, favorites, media, location entry points |
| 设置 | Settings | Language, local storage, backup, export, privacy |

## Tech Stack

- SwiftUI
- SwiftData
- iOS 17+
- Xcode 16+
- Local app sandbox storage
- Asset catalogs for app icon and generated visual assets

## Current Prototype Scope

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
- Generated app icon
- Generated memories hero image

## Planned Features

- Image drawer support
- Audio note drawer
- Video attachment drawer
- Location drawer with map preview
- PDF export
- Backup and restore
- Face ID / Touch ID app lock
- Better migration handling for SwiftData schema updates
- AI-generated summaries
- AI tag and keyword extraction
- AI-generated memory images
- Natural-language diary search

## Local Data Model

The app is designed around local persistence:

- Structured diary data is stored with SwiftData.
- Large media files such as photos, videos, and audio should be stored in the app’s local file directory.
- SwiftData should store media metadata and file references, not raw media blobs.
- Cloud sync is intentionally out of scope for the first version.

Important limitation:

If the app is deleted from the iPhone, local app data is deleted with it. A future backup and restore feature is planned to make long-term use safer.

## Running The App

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

## Project Structure

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
├── README.md
└── .gitignore
```

## Notes

This is an early product prototype, not a finished App Store release. The current focus is validating the product direction, local-first data model, core diary workflow, and visual language.

The long-term goal is to turn Memory Journal into a private memory library: a place where writing, searching, reflecting, and rediscovering old days all feel natural.

