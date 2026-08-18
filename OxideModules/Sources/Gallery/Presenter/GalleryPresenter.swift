// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation
import ImageProcessor

@MainActor
public final class GalleryPresenter: ObservableObject {
    @Published public private(set) var photos: [GalleryPhoto]
    @Published public private(set) var screen: GalleryScreen = .gallery
    @Published public private(set) var draft: GalleryDraft?
    @Published public private(set) var cameraAuthorization: CameraAuthorizationState = .notDetermined
    @Published public var isDeleteConfirmationPresented = false
    @Published public var isInfoPresented = false
    @Published public private(set) var canUndoEdit = false
    @Published public private(set) var toast: GalleryToast?
    @Published public private(set) var editingSourceSize: CGSize?
    @Published public private(set) var previewSaveState: GalleryPreviewSaveState = .idle
    @Published public private(set) var isPreparingShare = false

    public let filters = GalleryFilter.all
    private let interactor: GalleryInteractorProtocol
    private let router: GalleryRouterProtocol
    private let imageExporter: GalleryImageExporting

    init(
        interactor: GalleryInteractorProtocol,
        router: GalleryRouterProtocol,
        imageExporter: GalleryImageExporting = GalleryImageExporter()
    ) {
        self.interactor = interactor
        self.router = router
        self.imageExporter = imageExporter
        self.photos = interactor.loadPhotos()
    }

    public var selectedPhoto: GalleryPhoto? {
        guard case .preview(let id) = screen else { return nil }
        return photos.first { $0.id == id }
    }

    public var editingPhoto: GalleryPhoto? {
        guard case .editing(let id) = screen else { return nil }
        return photos.first { $0.id == id } ?? draft?.photo
    }

    public var lastPhoto: GalleryPhoto? {
        photos.first
    }

    public var selectedPhotoInfo: GalleryPhotoInfo? {
        guard let selectedPhoto else { return nil }
        return GalleryPhotoInfo(
            photo: selectedPhoto,
            filter: filter(for: selectedPhoto.filterID),
            sourceSize: interactor.sourceImageSize(for: selectedPhoto.imageURI)
        )
    }

    public func openCapture() {
        screen = .capture
    }

    public func closeCapture() {
        screen = .gallery
    }

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
        } catch {
            previewSaveState = .idle
            toast = .error("Save failed")
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
        } catch {
            toast = .error("Share failed")
        }
    }

    public func startEditingSelectedPhoto() async {
        guard let selectedPhoto else { return }
        await beginEditing(photo: selectedPhoto)
        screen = .editing(selectedPhoto.id)
    }

    public func startEditingCapturedPhoto(uri: URL, now: Date = Date(), id: String = UUID().uuidString) async {
        let photo = GalleryPhoto(id: id, imageURI: uri, createdAt: now)
        await beginEditing(photo: photo)
        interactor.preloadFilterPreviews(for: uri, filters: filters)
        screen = .editing(photo.id)
    }

    public func startEditingImportedPhoto(data: Data, now: Date = Date(), id: String = UUID().uuidString) async {
        do {
            let url = try await interactor.storeImportedImage(data: data, id: id)
            await startEditingCapturedPhoto(uri: url, now: now, id: id)
        } catch {
            toast = .error("Import failed")
        }
    }

    public func cancelEditing() {
        let previousPhotoID = draft?.photo.id
        draft = nil
        editingSourceSize = nil
        canUndoEdit = false

        if let previousPhotoID, photos.contains(where: { $0.id == previousPhotoID }) {
            screen = .preview(previousPhotoID)
        } else {
            screen = .gallery
        }
    }

    public func selectFilter(_ filterID: String) async {
        guard filters.contains(where: { $0.id == filterID }) else {
            toast = .error("Filter unavailable")
            return
        }

        guard draft?.selectedFilterID != filterID else { return }
        draft?.selectedFilterID = filterID
        draft?.filterIntensity = 0.5
        await recordCurrentEditStep()
    }

    public func setFilterIntensity(_ intensity: Double) {
        draft?.filterIntensity = min(max(intensity, 0), 1)
    }

    public func commitFilterIntensity() async {
        await recordCurrentEditStep()
    }

    public func rotateDraft(by degrees: Int) async {
        draft?.rotationDegrees = ImageEditRotation.normalized((draft?.rotationDegrees ?? 0) + degrees)
        await recordCurrentEditStep()
    }

    public func setCropAspectRatio(_ aspectRatio: Double?) async {
        guard let currentDraft = draft else { return }

        if let aspectRatio {
            guard let sourceSize = interactor.sourceImageSize(for: currentDraft.photo.imageURI) else {
                toast = .error("Crop unavailable")
                return
            }

            draft?.crop = ImageEditCropper.centeredCrop(sourceSize: sourceSize, aspectRatio: aspectRatio)
            draft?.cropAspectRatio = aspectRatio
        } else {
            draft?.crop = nil
            draft?.cropAspectRatio = nil
        }

        await recordCurrentEditStep()
    }

    public func resizeCrop(
        edge: ImageEditCropEdge,
        baseCrop: ImageEditCrop?,
        horizontalDelta: Double,
        verticalDelta: Double
    ) {
        draft?.crop = ImageEditCropper.resized(
            baseCrop,
            edge: edge,
            horizontalDelta: horizontalDelta,
            verticalDelta: verticalDelta
        )
        draft?.cropAspectRatio = nil
    }

    public func commitCropResize() async {
        await recordCurrentEditStep()
    }

    public func setAdjustment(
        _ kind: ImageAdjustmentKind,
        value: Double
    ) {
        guard var adjustments = draft?.adjustments else { return }

        switch kind {
        case .exposure:
            adjustments.exposure = min(max(value, -2), 2)
        case .contrast:
            adjustments.contrast = min(max(value, 0.5), 1.5)
        case .saturation:
            adjustments.saturation = min(max(value, 0), 2)
        case .brightness:
            adjustments.brightness = min(max(value, -0.5), 0.5)
        case .monochrome:
            return
        }

        draft?.adjustments = adjustments
    }

    public func toggleMonochrome() async {
        draft?.adjustments.isMonochrome.toggle()
        await recordCurrentEditStep()
    }

    public func commitAdjustment() async {
        await recordCurrentEditStep()
    }

    public func setFilmGrainAmount(_ amount: Double) {
        draft?.effects.filmGrain.amount = min(max(amount, 0), 1)
    }
    public func setFilmGrainSize(_ size: Double) {
        draft?.effects.filmGrain.size = min(max(size, 0.5), 4)
    }
    public func commitFilmGrain() async { await recordCurrentEditStep() }

    public func undoLastEdit() async {
        let state = await interactor.undoEditStep()
        draft = state.currentDraft
        canUndoEdit = state.canUndo
    }

    public func saveDraft() {
        guard let draft else { return }

        photos = interactor.save(draft.committed())
        self.draft = nil
        editingSourceSize = nil
        canUndoEdit = false
        screen = .gallery
        toast = .success("Photo saved")
    }

    public func showSelectedPhotoInfo() {
        guard selectedPhoto != nil else { return }
        isInfoPresented = true
    }

    public func requestDeleteSelectedPhoto() {
        guard selectedPhoto != nil else { return }
        isDeleteConfirmationPresented = true
    }

    public func cancelDelete() {
        isDeleteConfirmationPresented = false
    }

    public func confirmDeleteSelectedPhoto() {
        guard let selectedPhoto else { return }

        photos = interactor.delete(photoID: selectedPhoto.id)
        isDeleteConfirmationPresented = false
        screen = .gallery
        toast = .success("Photo deleted")
    }

    public func clearToast() {
        toast = nil
    }

    private func beginEditing(photo: GalleryPhoto) async {
        let draft = GalleryDraft(photo: photo)
        self.draft = draft
        editingSourceSize = interactor.sourceImageSize(for: photo.imageURI)
        await interactor.beginEditHistory(for: photo)
        canUndoEdit = false
    }

    private func recordCurrentEditStep() async {
        guard let draft else { return }
        let state = await interactor.recordEditStep(draft)
        canUndoEdit = state.canUndo
    }

    private func filter(for filterID: String?) -> GalleryFilter? {
        guard let filterID else { return nil }
        return filters.first { $0.id == filterID }
    }
}
