import AVFoundation
import CoreLocation
import MapKit
import PhotosUI
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct EditDiaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var entry: DiaryEntry
    let language: AppLanguage
    var deleteEmptyDraftOnCancel = false

    @State private var showingPreview = false
    @State private var tagText = ""
    @State private var showingDeleteConfirmation = false
    @State private var selectedMediaItems: [PhotosPickerItem] = []
    @State private var photoImportError: String?
    @State private var audioError: String?
    @State private var showingLocationPicker = false
    @State private var locationDraft = ""
    @State private var locationLatitudeDraft: Double?
    @State private var locationLongitudeDraft: Double?
    @StateObject private var audioRecorder = DiaryAudioRecorder()

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
                                    .onChange(of: entry.title) { _, _ in
                                        touchEntry()
                                    }
                            }

                            HStack(alignment: .top, spacing: 14) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(entry.diaryDate.diaryDateString())
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(AppTheme.textSecondary)

                                    DatePicker("", selection: $entry.diaryDate, displayedComponents: .date)
                                        .labelsHidden()
                                        .tint(AppTheme.teal)
                                        .onChange(of: entry.diaryDate) { _, _ in
                                            touchEntry()
                                        }
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
                                    .onChange(of: entry.mood) { _, _ in
                                        touchEntry()
                                    }
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
                                        touchEntry()
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
                                PhotosPicker(
                                    selection: $selectedMediaItems,
                                    maxSelectionCount: 12,
                                    matching: .any(of: [.images, .videos])
                                ) {
                                    PlaceholderDrawerButton(
                                        title: "\(L10n.t(.photos, language)) / \(L10n.t(.video, language))",
                                        systemImage: "photo.on.rectangle.angled",
                                        subtitle: L10n.t(.addMedia, language)
                                    )
                                }
                                .buttonStyle(.plain)

                                Button {
                                    toggleAudioRecording()
                                } label: {
                                    PlaceholderDrawerButton(
                                        title: L10n.t(.audio, language),
                                        systemImage: audioRecorder.isRecording ? "stop.circle" : "waveform",
                                        subtitle: audioRecorder.isRecording
                                            ? L10n.t(.stopRecording, language)
                                            : L10n.t(.recordAudio, language)
                                    )
                                }
                                .buttonStyle(.plain)

                                Button {
                                    locationDraft = entry.locationName
                                    locationLatitudeDraft = entry.latitude
                                    locationLongitudeDraft = entry.longitude
                                    showingLocationPicker = true
                                } label: {
                                    PlaceholderDrawerButton(
                                        title: L10n.t(.location, language),
                                        systemImage: "mappin.and.ellipse",
                                        subtitle: entry.locationName.isEmpty
                                            ? L10n.t(.chooseLocation, language)
                                            : entry.locationName
                                    )
                                }
                                .buttonStyle(.plain)
                            }

                            if !imageAttachments.isEmpty {
                                ImageAttachmentGrid(
                                    attachments: imageAttachments,
                                    onDelete: deleteAttachment,
                                    language: language
                                )
                            }

                            if !audioAttachments.isEmpty {
                                AudioAttachmentList(
                                    attachments: audioAttachments,
                                    onDelete: deleteAttachment,
                                    language: language
                                )
                            }

                            if !videoAttachments.isEmpty {
                                VideoAttachmentList(
                                    attachments: videoAttachments,
                                    onDelete: deleteAttachment,
                                    language: language
                                )
                            }

                            if !entry.locationName.isEmpty {
                                LocationDrawerRow(
                                    locationName: entry.locationName,
                                    latitude: entry.latitude,
                                    longitude: entry.longitude,
                                    onDelete: removeLocation,
                                    language: language
                                )
                            }

                            if let photoImportError {
                                Text(photoImportError)
                                    .font(.caption)
                                    .foregroundStyle(.red.opacity(0.85))
                            }

                            if let audioError {
                                Text(audioError)
                                    .font(.caption)
                                    .foregroundStyle(.red.opacity(0.85))
                            }

                            Label(L10n.t(.savedLocally, language), systemImage: "checkmark.circle")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
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
                        deleteEntry()
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
                deleteEntry()
                dismiss()
            }
            Button(L10n.t(.cancel, language), role: .cancel) {}
        }
        .onChange(of: selectedMediaItems) { _, newItems in
            importMedia(newItems)
        }
        .onDisappear {
            if audioRecorder.isRecording {
                _ = audioRecorder.stopRecording()
            }
        }
        .sheet(isPresented: $showingLocationPicker) {
            NavigationStack {
                LocationPickerSheet(
                    locationName: $locationDraft,
                    latitude: $locationLatitudeDraft,
                    longitude: $locationLongitudeDraft,
                    language: language
                ) {
                    entry.locationName = locationDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                    entry.latitude = locationLatitudeDraft
                    entry.longitude = locationLongitudeDraft
                    touchEntry()
                    showingLocationPicker = false
                }
            }
        }
    }

    private func save() {
        entry.plainTextContent = MarkdownTools.plainText(from: entry.markdownContent)
        entry.updatedAt = Date()
    }

    private func touchEntry() {
        entry.updatedAt = Date()
    }

    private func importMedia(_ items: [PhotosPickerItem]) {
        guard !items.isEmpty else { return }
        photoImportError = nil

        Task {
            for item in items {
                do {
                    guard let data = try await item.loadTransferable(type: Data.self) else {
                        continue
                    }

                    let isVideo = item.supportedContentTypes.contains { contentType in
                        contentType.conforms(to: .movie)
                            || contentType.conforms(to: .video)
                            || contentType.conforms(to: .audiovisualContent)
                    }
                    let fileExtension = item.supportedContentTypes.first?.preferredFilenameExtension ?? (isVideo ? "mov" : "jpg")
                    let relativePath = try AttachmentFileStore.save(data: data, fileExtension: fileExtension)

                    await MainActor.run {
                        let nextSortOrder = (entry.attachments.map(\.sortOrder).max() ?? -1) + 1
                        let attachment = DiaryAttachment(
                            type: isVideo ? .video : .image,
                            localPath: relativePath,
                            displayName: "\(L10n.t(isVideo ? .video : .photos, language)) \(nextSortOrder + 1)",
                            sortOrder: nextSortOrder
                        )
                        modelContext.insert(attachment)
                        entry.attachments.append(attachment)
                        touchEntry()
                    }
                } catch {
                    await MainActor.run {
                        photoImportError = L10n.t(.mediaImportFailed, language)
                    }
                }
            }

            await MainActor.run {
                selectedMediaItems.removeAll()
            }
        }
    }

    private func toggleAudioRecording() {
        audioError = nil

        if audioRecorder.isRecording {
            guard let relativePath = audioRecorder.stopRecording() else {
                audioError = L10n.t(.audioImportFailed, language)
                return
            }

            let nextSortOrder = (entry.attachments.map(\.sortOrder).max() ?? -1) + 1
            let attachment = DiaryAttachment(
                type: .audio,
                localPath: relativePath,
                displayName: "\(L10n.t(.audio, language)) \(nextSortOrder + 1)",
                sortOrder: nextSortOrder
            )
            modelContext.insert(attachment)
            entry.attachments.append(attachment)
            touchEntry()
            return
        }

        Task {
            let canRecord = await audioRecorder.requestPermission()
            await MainActor.run {
                guard canRecord else {
                    audioError = L10n.t(.audioImportFailed, language)
                    return
                }

                do {
                    try audioRecorder.startRecording()
                } catch {
                    audioError = L10n.t(.audioImportFailed, language)
                }
            }
        }
    }

    private func deleteAttachment(_ attachment: DiaryAttachment) {
        AttachmentFileStore.deleteFile(at: attachment.localPath)
        entry.attachments.removeAll { $0.id == attachment.id }
        modelContext.delete(attachment)
        touchEntry()
    }

    private func removeLocation() {
        entry.locationName = ""
        entry.latitude = nil
        entry.longitude = nil
        touchEntry()
    }

    private func deleteEntry() {
        entry.attachments.forEach { AttachmentFileStore.deleteFile(at: $0.localPath) }
        modelContext.delete(entry)
    }

    private var imageAttachments: [DiaryAttachment] {
        entry.attachments
            .filter { $0.type == .image }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private var audioAttachments: [DiaryAttachment] {
        entry.attachments
            .filter { $0.type == .audio }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private var videoAttachments: [DiaryAttachment] {
        entry.attachments
            .filter { $0.type == .video }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private var isEntryBlank: Bool {
        entry.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && entry.markdownContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && entry.tagNames.isEmpty
    }
}

private final class DiaryAudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false

    private var recorder: AVAudioRecorder?
    private var currentRelativePath: String?

    func requestPermission() async -> Bool {
        #if os(iOS)
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { isAllowed in
                continuation.resume(returning: isAllowed)
            }
        }
        #else
        true
        #endif
    }

    func startRecording() throws {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default)
        try session.setActive(true)
        #endif

        let reservedFile = try AttachmentFileStore.reserveFile(fileExtension: "m4a")
        currentRelativePath = reservedFile.relativePath

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let recorder = try AVAudioRecorder(url: reservedFile.url, settings: settings)
        recorder.prepareToRecord()
        recorder.record()
        self.recorder = recorder
        isRecording = true
    }

    func stopRecording() -> String? {
        recorder?.stop()
        recorder = nil
        isRecording = false

        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false)
        #endif

        let relativePath = currentRelativePath
        currentRelativePath = nil
        return relativePath
    }
}

private struct LocationPickerSheet: View {
    @Binding var locationName: String
    @Binding var latitude: Double?
    @Binding var longitude: Double?
    let language: AppLanguage
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationFinder = DiaryLocationFinder()
    @State private var searchText = ""
    @State private var searchResults: [DiaryLocationResult] = []
    @State private var locationError: String?
    @State private var isSearching = false
    @State private var isLocating = false
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        AppPageContainer {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 12) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppTheme.teal)
                        .frame(width: 36, height: 36)
                        .background(AppTheme.teal.opacity(0.13), in: RoundedRectangle(cornerRadius: 8))

                    Text(L10n.t(.chooseLocation, language))
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Spacer()
                }

                AppPanel {
                    VStack(alignment: .leading, spacing: 14) {
                        Button {
                            useCurrentLocation()
                        } label: {
                            Label(
                                isLocating ? L10n.t(.currentLocation, language) : L10n.t(.currentLocation, language),
                                systemImage: "location.fill"
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.teal)
                        .disabled(isLocating)

                        Divider()
                            .overlay(AppTheme.border)

                        Text(L10n.t(.searchMap, language))
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)

                        HStack(alignment: .center, spacing: 10) {
                            TextField(L10n.t(.locationSearchPlaceholder, language), text: $searchText)
                                .textFieldStyle(.plain)
                                .foregroundStyle(AppTheme.textPrimary)
                                .focused($isSearchFieldFocused)
                                .submitLabel(.search)
                                .onSubmit {
                                    searchMap()
                                }
                                .padding(12)
                                .background(AppTheme.elevatedPanel, in: RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppTheme.border)
                                )

                            Image(systemName: "magnifyingglass")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                                .frame(width: 52, height: 48)
                                .background(
                                    canSearchMap ? AppTheme.teal.opacity(0.55) : AppTheme.elevatedPanel,
                                    in: RoundedRectangle(cornerRadius: 8)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppTheme.border)
                                )
                                .contentShape(Rectangle())
                                .opacity(canSearchMap ? 1 : 0.55)
                                .onTapGesture {
                                    submitMapSearch()
                                }
                                .accessibilityLabel(L10n.t(.searchMap, language))
                                .accessibilityAddTraits(.isButton)
                        }

                        if !searchResults.isEmpty {
                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(searchResults) { result in
                                        Button {
                                            applyAndSave(result)
                                        } label: {
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(result.name)
                                                    .font(.subheadline.weight(.semibold))
                                                    .foregroundStyle(AppTheme.textPrimary)
                                                    .lineLimit(2)
                                                if !result.subtitle.isEmpty {
                                                    Text(result.subtitle)
                                                        .font(.caption)
                                                        .foregroundStyle(AppTheme.textSecondary)
                                                        .lineLimit(1)
                                                }
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(12)
                                            .background(AppTheme.elevatedPanel, in: RoundedRectangle(cornerRadius: 8))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .frame(maxHeight: 320)
                        }

                        Divider()
                            .overlay(AppTheme.border)

                        TextField(L10n.t(.locationName, language), text: $locationName)
                            .textFieldStyle(.plain)
                            .font(.title3.weight(.medium))
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding(12)
                            .background(AppTheme.elevatedPanel, in: RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppTheme.border)
                            )

                        if let latitude, let longitude {
                            Text(String(format: "%.5f, %.5f", latitude, longitude))
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        if let locationError {
                            Text(locationError)
                                .font(.caption)
                                .foregroundStyle(.red.opacity(0.85))
                        }
                    }
                }

                Spacer()
            }
            .padding(24)
        }
        .navigationTitle(L10n.t(.chooseLocation, language))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(L10n.t(.cancel, language)) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(L10n.t(.saveLocation, language)) {
                    onSave()
                }
            }
        }
    }

    private func useCurrentLocation() {
        isLocating = true
        locationError = nil

        Task {
            do {
                let result = try await locationFinder.currentLocation()
                await MainActor.run {
                    applyAndSave(result)
                    isLocating = false
                }
            } catch {
                await MainActor.run {
                    locationError = L10n.t(.locationFailed, language)
                    isLocating = false
                }
            }
        }
    }

    private func searchMap() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty, !isSearching else { return }

        isSearching = true
        isSearchFieldFocused = false
        locationError = nil

        Task {
            do {
                let results = try await locationFinder.search(query: query)
                await MainActor.run {
                    searchResults = results
                    isSearching = false
                }
            } catch {
                await MainActor.run {
                    locationError = L10n.t(.locationFailed, language)
                    searchResults = []
                    isSearching = false
                }
            }
        }
    }

    private func submitMapSearch() {
        guard canSearchMap else { return }
        searchMap()
    }

    private var canSearchMap: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSearching
    }

    private func apply(_ result: DiaryLocationResult) {
        locationName = result.name
        latitude = result.coordinate.latitude
        longitude = result.coordinate.longitude
    }

    private func applyAndSave(_ result: DiaryLocationResult) {
        apply(result)
        onSave()
        dismiss()
    }
}

private struct DiaryLocationResult: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
}

private final class DiaryLocationFinder: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func currentLocation() async throws -> DiaryLocationResult {
        let location = try await requestLocation()
        let placemarks = try? await CLGeocoder().reverseGeocodeLocation(location)
        let placemark = placemarks?.first
        let name = [
            placemark?.name,
            placemark?.locality,
            placemark?.administrativeArea
        ]
            .compactMap { $0 }
            .removeDuplicates()
            .joined(separator: " · ")

        return DiaryLocationResult(
            name: name.isEmpty ? "Current Location" : name,
            subtitle: "",
            coordinate: location.coordinate
        )
    }

    func search(query: String) async throws -> [DiaryLocationResult] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let response = try await MKLocalSearch(request: request).start()

        return response.mapItems.prefix(12).map { item in
            DiaryLocationResult(
                name: item.name ?? query,
                subtitle: [item.placemark.locality, item.placemark.administrativeArea]
                    .compactMap { $0 }
                    .joined(separator: " · "),
                coordinate: item.placemark.coordinate
            )
        }
    }

    private func requestLocation() async throws -> CLLocation {
        try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation

            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                manager.requestLocation()
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            default:
                finishLocationRequest(with: .failure(CLError(.denied)))
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied, .restricted:
            finishLocationRequest(with: .failure(CLError(.denied)))
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            finishLocationRequest(with: .success(location))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finishLocationRequest(with: .failure(error))
    }

    private func finishLocationRequest(with result: Result<CLLocation, Error>) {
        guard let continuation = locationContinuation else { return }
        locationContinuation = nil

        switch result {
        case .success(let location):
            continuation.resume(returning: location)
        case .failure(let error):
            continuation.resume(throwing: error)
        }
    }
}

private extension Array where Element: Hashable {
    func removeDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
