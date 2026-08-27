// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import AppCore
import Editor
import Foundation
import ImageProcessor

@MainActor
public final class GalleryPresenter: ObservableObject {
    @Published public private(set) var photos: [GalleryPhoto]
    @Published public private(set) var screen: GalleryScreen = .gallery
    @Published public private(set) var editorPresenter: EditorPresenter?
    @Published public private(set) var cameraAuthorization: CameraAuthorizationState = .notDetermined
    @Published public var isDeleteConfirmationPresented = false
    @Published public var isInfoPresented = false
    @Published public private(set) var toast: GalleryToast?
    @Published public private(set) var previewSaveState: GalleryPreviewSaveState = .idle
    @Published public private(set) var isPreparingShare = false

    private let interactor: GalleryInteractorProtocol
    private let router: GalleryRouterProtocol
    private let imageExporter: GalleryImageExporting
    private let analytics: any AppAnalyticsTracking

    init(
        interactor: GalleryInteractorProtocol,
        router: GalleryRouterProtocol,
        analytics: any AppAnalyticsTracking = NoOpAppAnalyticsTracker(),
        imageExporter: GalleryImageExporting = GalleryImageExporter()
    ) {
        self.interactor = interactor
        self.router = router
        self.imageExporter = imageExporter
        self.analytics = analytics
        photos = interactor.loadPhotos()
        analytics.track(.galleryViewed)
    }

    public var selectedPhoto: GalleryPhoto? {
        guard case .preview(let id) = screen else { return nil }
        return photos.first { $0.id == id }
    }

    public var lastPhoto: GalleryPhoto? { photos.first }

    public var selectedPhotoInfo: GalleryPhotoInfo? {
        guard let selectedPhoto else { return nil }
        return GalleryPhotoInfo(
            photo: selectedPhoto,
            filter: GalleryFilter.all.first { $0.id == selectedPhoto.filterID },
            sourceSize: interactor.sourceImageSize(for: selectedPhoto.imageURI)
        )
    }

    public func openCapture() { screen = .capture }
    public func closeCapture() { screen = .gallery }

    public func selectPhoto(_ photo: GalleryPhoto) {
        previewSaveState = .idle
        screen = .preview(photo.id)
    }

    public func dismissPreview() {
        isDeleteConfirmationPresented = false
        isInfoPresented = false
        previewSaveState = .idle
        isPreparingShare = false
        screen = .gallery
    }

    public func saveSelectedPhotoToLibrary() async {
        guard let selectedPhoto, previewSaveState == .idle else { return }
        previewSaveState = .saving
        do {
            let url = try await imageExporter.exportFile(for: selectedPhoto)
            try await imageExporter.saveToPhotoLibrary(url)
            guard self.selectedPhoto?.id == selectedPhoto.id else { return }
            previewSaveState = .saved
            toast = .success("Saved to Photos")
            analytics.track(.photoExported(destination: "photo_library"))
        } catch {
            previewSaveState = .idle
            toast = .error("Save failed")
            analytics.track(.operationFailed(operation: "photo_export", reason: "save_failed"))
        }
    }

    public func shareSelectedPhoto() async {
        guard let selectedPhoto, !isPreparingShare else { return }
        isPreparingShare = true
        defer { isPreparingShare = false }
        do {
            let url = try await imageExporter.exportFile(for: selectedPhoto)
            guard self.selectedPhoto?.id == selectedPhoto.id else { return }
            router.presentShareSheet(for: url)
            analytics.track(.photoExported(destination: "share_sheet"))
        } catch {
            toast = .error("Share failed")
            analytics.track(.operationFailed(operation: "photo_export", reason: "share_failed"))
        }
    }

    public func startEditingSelectedPhoto() async {
        guard let selectedPhoto else { return }
        beginEditing(photo: selectedPhoto)
    }

    public func startEditingCapturedPhoto(uri: URL, now: Date = Date(), id: String = UUID().uuidString) async {
        beginEditing(photo: GalleryPhoto(id: id, imageURI: uri, createdAt: now))
    }

    public func startEditingImportedPhoto(data: Data, now: Date = Date(), id: String = UUID().uuidString) async {
        do {
            let url = try await interactor.storeImportedImage(data: data, id: id)
            beginEditing(photo: GalleryPhoto(id: id, imageURI: url, createdAt: now))
        } catch {
            toast = .error("Import failed")
            analytics.track(.operationFailed(operation: "photo_import", reason: "storage_failed"))
        }
    }

    public func showSelectedPhotoInfo() {
        guard selectedPhoto != nil else { return }
        isInfoPresented = true
    }

    public func requestDeleteSelectedPhoto() {
        guard selectedPhoto != nil else { return }
        isDeleteConfirmationPresented = true
    }

    public func cancelDelete() { isDeleteConfirmationPresented = false }

    public func confirmDeleteSelectedPhoto() {
        guard let selectedPhoto else { return }
        photos = interactor.delete(photoID: selectedPhoto.id)
        isDeleteConfirmationPresented = false
        screen = .gallery
        toast = .success("Photo deleted")
        analytics.track(.photoDeleted)
    }

    public func clearToast() { toast = nil }

    private func beginEditing(photo: GalleryPhoto) {
        let photoID = photo.id
        editorPresenter = EditorBuilder.makePresenter(
            asset: EditorAsset(photo),
            analytics: analytics,
            onCancel: { [weak self] in self?.finishEditingWithoutSaving(photoID: photoID) },
            onSave: { [weak self] asset in self?.finishEditing(with: asset) },
            onError: { [weak self] message in self?.toast = .error(message) }
        )
        screen = .editing(photoID)
        analytics.track(.editorStarted(source: photos.contains { $0.id == photoID } ? "gallery" : "capture_or_import"))
    }

    private func finishEditingWithoutSaving(photoID: GalleryPhoto.ID) {
        editorPresenter = nil
        screen = photos.contains { $0.id == photoID } ? .preview(photoID) : .gallery
    }

    private func finishEditing(with asset: EditorAsset) {
        photos = interactor.save(GalleryPhoto(asset))
        editorPresenter = nil
        screen = .gallery
        toast = .success("Photo saved")
    }
}

private extension EditorAsset {
    init(_ photo: GalleryPhoto) {
        self.init(id: photo.id, imageURI: photo.imageURI, createdAt: photo.createdAt, filterID: photo.filterID, filterIntensity: photo.filterIntensity, rotationDegrees: photo.rotationDegrees, crop: photo.crop, adjustments: photo.adjustments, effects: photo.effects)
    }
}

private extension GalleryPhoto {
    init(_ asset: EditorAsset) {
        self.init(id: asset.id, imageURI: asset.imageURI, createdAt: asset.createdAt, filterID: asset.filterID, filterIntensity: asset.filterIntensity, rotationDegrees: asset.rotationDegrees, crop: asset.crop, adjustments: asset.adjustments, effects: asset.effects)
    }
}
