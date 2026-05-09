import AVFoundation
import AVKit
import MapKit
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum AppTheme {
    static let background = LinearGradient(
        colors: [
            Color(red: 0.025, green: 0.030, blue: 0.050),
            Color(red: 0.045, green: 0.060, blue: 0.095),
            Color(red: 0.075, green: 0.090, blue: 0.105)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let panel = Color(red: 0.075, green: 0.086, blue: 0.115)
    static let elevatedPanel = Color(red: 0.105, green: 0.119, blue: 0.150)
    static let border = Color.white.opacity(0.08)
    static let textPrimary = Color.white.opacity(0.94)
    static let textSecondary = Color.white.opacity(0.62)
    static let textMuted = Color.white.opacity(0.42)
    static let teal = Color(red: 0.260, green: 0.780, blue: 0.760)
    static let gold = Color(red: 0.900, green: 0.700, blue: 0.360)
    static let sage = Color(red: 0.560, green: 0.690, blue: 0.610)
}

struct AppPageContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            content
        }
    }
}

struct PageHeader: View {
    let title: String
    let subtitle: String?
    let systemImage: String?

    init(_ title: String, subtitle: String? = nil, systemImage: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.teal)
                    .frame(width: 38, height: 38)
                    .background(AppTheme.teal.opacity(0.13), in: RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            Spacer()
        }
    }
}

struct AppPanel<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .background(AppTheme.panel, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.border)
            )
    }
}

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        AppPanel {
            VStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(AppTheme.teal)

                Text(title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 360)
            }
            .frame(maxWidth: .infinity, minHeight: 260)
        }
    }
}

struct TagChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(AppTheme.teal)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AppTheme.teal.opacity(0.14), in: Capsule())
    }
}

struct MoodPill: View {
    let moodRaw: String
    let language: AppLanguage

    var body: some View {
        let mood = MoodOption(rawValue: moodRaw) ?? .calm

        Text(mood.displayName(language: language))
            .font(.caption)
            .foregroundStyle(AppTheme.textSecondary)
    }
}

struct PlaceholderDrawerButton: View {
    let title: String
    let systemImage: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .frame(width: 24, height: 24)
                .foregroundStyle(AppTheme.teal)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.down")
                .font(.caption)
                .foregroundStyle(AppTheme.textMuted)
        }
        .padding(14)
        .background(AppTheme.elevatedPanel, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.border)
        )
    }
}

struct ImageAttachmentGrid: View {
    let attachments: [DiaryAttachment]
    var onDelete: ((DiaryAttachment) -> Void)? = nil
    let language: AppLanguage
    @State private var selectedIndex = 0
    @State private var isShowingGallery = false

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 138), spacing: 12)], spacing: 12) {
            ForEach(Array(attachments.enumerated()), id: \.element.id) { index, attachment in
                ImageAttachmentTile(
                    attachment: attachment,
                    onDelete: onDelete,
                    onOpen: {
                        selectedIndex = index
                        isShowingGallery = true
                    },
                    language: language
                )
            }
        }
        .sheet(isPresented: $isShowingGallery) {
            FullScreenImageGallery(
                attachments: attachments,
                selectedIndex: selectedIndex,
                language: language
            )
        }
    }
}

struct AudioAttachmentList: View {
    let attachments: [DiaryAttachment]
    var onDelete: ((DiaryAttachment) -> Void)? = nil
    let language: AppLanguage

    var body: some View {
        VStack(spacing: 10) {
            ForEach(attachments) { attachment in
                AudioAttachmentRow(
                    attachment: attachment,
                    onDelete: onDelete,
                    language: language
                )
            }
        }
    }
}

struct VideoAttachmentList: View {
    let attachments: [DiaryAttachment]
    var onDelete: ((DiaryAttachment) -> Void)? = nil
    let language: AppLanguage

    var body: some View {
        VStack(spacing: 10) {
            ForEach(attachments) { attachment in
                VideoAttachmentRow(
                    attachment: attachment,
                    onDelete: onDelete,
                    language: language
                )
            }
        }
    }
}

private struct VideoAttachmentRow: View {
    let attachment: DiaryAttachment
    var onDelete: ((DiaryAttachment) -> Void)?
    let language: AppLanguage

    @State private var isShowingPlayer = false
    @State private var thumbnail: Image?

    var body: some View {
        HStack(spacing: 12) {
            Button {
                isShowingPlayer = true
            } label: {
                ZStack {
                    if let thumbnail {
                        thumbnail
                            .resizable()
                            .scaledToFill()
                    } else {
                        AppTheme.teal.opacity(0.13)
                        Image(systemName: "video")
                            .font(.title3)
                            .foregroundStyle(AppTheme.teal)
                    }

                    Image(systemName: "play.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(.black.opacity(0.52), in: Circle())
                }
                .frame(width: 68, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.t(.playVideo, language))

            VStack(alignment: .leading, spacing: 3) {
                Text(attachment.displayName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(attachment.createdAt.diaryDateString())
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            if let onDelete {
                Button(role: .destructive) {
                    onDelete(attachment)
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.t(.removeVideo, language))
            }
        }
        .padding(12)
        .background(AppTheme.elevatedPanel, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.border)
        )
        .sheet(isPresented: $isShowingPlayer) {
            VideoPlayer(player: AVPlayer(url: AttachmentFileStore.fileURL(for: attachment.localPath)))
                .ignoresSafeArea()
        }
        .onAppear {
            loadThumbnail()
        }
    }

    private func loadThumbnail() {
        guard thumbnail == nil else { return }

        let url = AttachmentFileStore.fileURL(for: attachment.localPath)
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true

            do {
                let cgImage = try generator.copyCGImage(
                    at: CMTime(seconds: 0.25, preferredTimescale: 600),
                    actualTime: nil
                )
                #if canImport(UIKit)
                let image = Image(uiImage: UIImage(cgImage: cgImage))
                #elseif canImport(AppKit)
                let image = Image(nsImage: NSImage(cgImage: cgImage, size: .zero))
                #endif

                DispatchQueue.main.async {
                    thumbnail = image
                }
            } catch {
                DispatchQueue.main.async {
                    thumbnail = nil
                }
            }
        }
    }
}

private struct AudioAttachmentRow: View {
    let attachment: DiaryAttachment
    var onDelete: ((DiaryAttachment) -> Void)?
    let language: AppLanguage

    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0

    var body: some View {
        HStack(spacing: 12) {
            Button {
                togglePlayback()
            } label: {
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(AppTheme.teal.opacity(0.82), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.t(.playAudio, language))

            VStack(alignment: .leading, spacing: 6) {
                Text(attachment.displayName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textPrimary)

                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(AppTheme.teal)

                HStack(spacing: 6) {
                    Text(formatTime(currentTime))

                    Text("/")

                    Text(formatTime(duration))

                    Text("·")

                    Text(attachment.createdAt.diaryDateString())
                }
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            if let onDelete {
                Button(role: .destructive) {
                    stopPlayback()
                    onDelete(attachment)
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.t(.removeAudio, language))
            }
        }
        .padding(12)
        .background(AppTheme.elevatedPanel, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.border)
        )
        .onAppear {
            loadDuration()
        }
        .onDisappear {
            stopPlayback()
        }
        .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
            if isPlaying, let player {
                currentTime = player.currentTime
                duration = player.duration
            }

            if isPlaying && player?.isPlaying == false {
                stopPlayback()
            }
        }
    }

    private func togglePlayback() {
        if isPlaying {
            stopPlayback()
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: AttachmentFileStore.fileURL(for: attachment.localPath))
            self.player = player
            duration = player.duration
            currentTime = 0
            player.play()
            isPlaying = true
        } catch {
            isPlaying = false
        }
    }

    private func stopPlayback() {
        player?.stop()
        player = nil
        isPlaying = false
        currentTime = 0
    }

    private func loadDuration() {
        guard duration == 0 else { return }

        do {
            let probe = try AVAudioPlayer(contentsOf: AttachmentFileStore.fileURL(for: attachment.localPath))
            duration = probe.duration
        } catch {
            duration = 0
        }
    }

    private var progress: Double {
        guard duration > 0 else { return 0 }
        return min(max(currentTime / duration, 0), 1)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite, time > 0 else { return "0:00" }

        let totalSeconds = Int(time.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct LocationDrawerRow: View {
    let locationName: String
    var latitude: Double? = nil
    var longitude: Double? = nil
    var onDelete: (() -> Void)? = nil
    let language: AppLanguage

    var body: some View {
        HStack(spacing: 12) {
            Button {
                openInMaps()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundStyle(AppTheme.gold)
                        .frame(width: 28, height: 28)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(locationName)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineLimit(2)

                        HStack(spacing: 6) {
                            Text(L10n.t(.openInMaps, language))

                            if let coordinateText {
                                Text("·")
                                Text(coordinateText)
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.textMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.t(.openInMaps, language))

            if let onDelete {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.t(.removeLocation, language))
            }
        }
        .padding(12)
        .background(AppTheme.elevatedPanel, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.border)
        )
    }

    private var coordinateText: String? {
        guard let latitude, let longitude else { return nil }
        return String(format: "%.4f, %.4f", latitude, longitude)
    }

    private func openInMaps() {
        if let latitude, let longitude {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = locationName
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate),
                MKLaunchOptionsMapSpanKey: NSValue(
                    mkCoordinateSpan: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            ])
            return
        }

        guard let encodedQuery = locationName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://maps.apple.com/?q=\(encodedQuery)") else {
            return
        }

        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #elseif canImport(AppKit)
        NSWorkspace.shared.open(url)
        #endif
    }
}

private struct ImageAttachmentTile: View {
    let attachment: DiaryAttachment
    var onDelete: ((DiaryAttachment) -> Void)?
    let onOpen: () -> Void
    let language: AppLanguage

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                if localImage != nil {
                    onOpen()
                }
            } label: {
                Group {
                    if let image = localImage {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundStyle(AppTheme.teal)
                            Text(attachment.displayName)
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppTheme.elevatedPanel)
                    }
                }
                .frame(height: 128)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.border)
                )
            }
            .buttonStyle(.plain)

            if let onDelete {
                Button(role: .destructive) {
                    onDelete(attachment)
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(.black.opacity(0.58), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.t(.removePhoto, language))
                .padding(8)
            }
        }
    }

    private var localImage: Image? {
        let url = AttachmentFileStore.fileURL(for: attachment.localPath)

        #if canImport(UIKit)
        if let image = UIImage(contentsOfFile: url.path) {
            return Image(uiImage: image)
        }
        #elseif canImport(AppKit)
        if let image = NSImage(contentsOf: url) {
            return Image(nsImage: image)
        }
        #endif

        return nil
    }
}

private struct FullScreenImageGallery: View {
    let attachments: [DiaryAttachment]
    @State var selectedIndex: Int
    let language: AppLanguage

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            TabView(selection: $selectedIndex) {
                ForEach(Array(attachments.enumerated()), id: \.element.id) { index, attachment in
                    GalleryImagePage(attachment: attachment)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: attachments.count > 1 ? .automatic : .never))
            .ignoresSafeArea()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.14), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.t(.cancel, language))
            .padding()
        }
    }
}

private struct GalleryImagePage: View {
    let attachment: DiaryAttachment

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 42))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Text(attachment.displayName)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(.black.opacity(0.42), in: Capsule())
                .padding()
        }
    }

    private var image: Image? {
        let url = AttachmentFileStore.fileURL(for: attachment.localPath)

        #if canImport(UIKit)
        if let image = UIImage(contentsOfFile: url.path) {
            return Image(uiImage: image)
        }
        #elseif canImport(AppKit)
        if let image = NSImage(contentsOf: url) {
            return Image(nsImage: image)
        }
        #endif

        return nil
    }
}

struct MarkdownPreview: View {
    let markdown: String

    var body: some View {
        ScrollView {
            Text(MarkdownTools.attributedString(from: markdown.isEmpty ? " " : markdown))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
        }
    }
}

struct CompactInfoRow: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(AppTheme.gold)
                .frame(width: 24)

            Text(title)
                .foregroundStyle(AppTheme.textPrimary)

            Spacer()

            Text(value)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .font(.subheadline)
        .padding(.vertical, 8)
    }
}

extension Date {
    func diaryDateString() -> String {
        formatted(.dateTime.year().month().day())
    }

    func diaryMonthDayString() -> String {
        formatted(.dateTime.month().day())
    }
}
