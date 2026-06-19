// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Testing
import Foundation
import ImageProcessor
@testable import Gallery

@MainActor
struct GalleryTests {

    @Test func interactorSortsPhotosByNewestDate() async throws {
        let older = GalleryPhoto(
            id: "older",
            imageURI: try #require(URL(string: "https://example.com/older.jpg")),
            createdAt: Date(timeIntervalSince1970: 10)
        )
        let newer = GalleryPhoto(
            id: "newer",
            imageURI: try #require(URL(string: "https://example.com/newer.jpg")),
            createdAt: Date(timeIntervalSince1970: 20)
        )
        let interactor = GalleryInteractor(
            photos: [older, newer],
            persistsChanges: false
        )

        #expect(interactor.loadPhotos().map(\.id) == ["newer", "older"])
    }

    @Test func saveUpdatesExistingPhotoWithoutDuplicatingIt() async throws {
        let photo = GalleryPhoto(
            id: "photo",
            imageURI: try #require(URL(string: "https://example.com/photo.jpg")),
            createdAt: Date(timeIntervalSince1970: 10)
        )
        let interactor = GalleryInteractor(
            photos: [photo],
            persistsChanges: false
        )
        var updated = photo
        updated.filterID = "01_brooklyn"
        updated.rotationDegrees = 90

        let photos = interactor.save(updated)

        #expect(photos.count == 1)
        #expect(photos.first?.filterID == "01_brooklyn")
        #expect(photos.first?.rotationDegrees == 90)
    }

    @Test func deleteMissingPhotoIsNoOp() async throws {
        let photo = GalleryPhoto(
            id: "photo",
            imageURI: try #require(URL(string: "https://example.com/photo.jpg")),
            createdAt: Date()
        )
        let interactor = GalleryInteractor(
            photos: [photo],
            persistsChanges: false
        )

        let photos = interactor.delete(photoID: "missing")

        #expect(photos == [photo])
    }

    @Test func presenterMovesCapturedPhotoIntoEditingDraft() async throws {
        let presenter = makePresenter()
        let uri = try #require(URL(string: "https://example.com/capture.jpg"))

        presenter.startEditingCapturedPhoto(
            uri: uri,
            now: Date(timeIntervalSince1970: 100),
            id: "capture"
        )

        #expect(presenter.screen == .editing("capture"))
        #expect(presenter.draft?.photo.imageURI == uri)
        #expect(presenter.photos.isEmpty)
    }

    @Test func presenterSavesDraftAndReturnsToGallery() async throws {
        let presenter = makePresenter()
        presenter.startEditingCapturedPhoto(
            uri: try #require(URL(string: "https://example.com/capture.jpg")),
            now: Date(timeIntervalSince1970: 100),
            id: "capture"
        )
        presenter.selectFilter("01_brooklyn")
        presenter.rotateDraft(by: 90)

        presenter.saveDraft()

        #expect(presenter.screen == .gallery)
        #expect(presenter.photos.count == 1)
        #expect(presenter.photos.first?.filterID == "01_brooklyn")
        #expect(presenter.photos.first?.rotationDegrees == 90)
        #expect(presenter.draft == nil)
        #expect(presenter.toast == .success("Photo saved"))
    }

    @Test func draftCommitsFilterIntensityOnlyWhenFilterIsApplied() async throws {
        let photo = GalleryPhoto(
            id: "photo",
            imageURI: try #require(URL(string: "https://example.com/photo.jpg")),
            createdAt: Date(),
            filterID: "01_brooklyn",
            filterIntensity: 0.4
        )
        var draft = GalleryDraft(photo: photo)

        draft.filterIntensity = 0.65
        #expect(draft.committed().filterIntensity == 0.65)

        draft.selectedFilterID = GalleryFilter.original.id
        #expect(draft.committed().filterID == nil)
        #expect(draft.committed().filterIntensity == 1.0)
    }

    @Test func draftCommitsCropMetadata() async throws {
        let photo = GalleryPhoto(
            id: "photo",
            imageURI: try #require(URL(string: "https://example.com/photo.jpg")),
            createdAt: Date()
        )
        var draft = GalleryDraft(photo: photo)
        let crop = ImageEditCrop(x: 0.125, y: 0, width: 0.75, height: 1)

        draft.crop = crop

        #expect(draft.committed().crop == crop)
    }

    @Test func presenterTracksFilterIntensityAndInfo() async throws {
        let presenter = makePresenter()
        presenter.startEditingCapturedPhoto(
            uri: try #require(URL(string: "https://example.com/capture.jpg")),
            now: Date(timeIntervalSince1970: 100),
            id: "capture"
        )
        presenter.selectFilter("01_brooklyn")
        presenter.setFilterIntensity(0.42)
        presenter.saveDraft()

        let saved = try #require(presenter.photos.first)
        presenter.selectPhoto(saved)
        let info = try #require(presenter.selectedPhotoInfo)

        #expect(saved.filterIntensity == 0.42)
        #expect(info.filterName == "Brooklyn")
        #expect(info.filterIntensity == 0.42)
    }

    @Test func presenterResetsFilterIntensityWhenFilterChanges() async throws {
        let presenter = makePresenter()
        let firstFilter = try #require(presenter.filters.first { $0.id != GalleryFilter.original.id })
        let secondFilter = try #require(presenter.filters.first { $0.id != GalleryFilter.original.id && $0.id != firstFilter.id })
        presenter.startEditingCapturedPhoto(
            uri: try #require(URL(string: "https://example.com/capture.jpg")),
            now: Date(timeIntervalSince1970: 100),
            id: "capture"
        )

        presenter.selectFilter(firstFilter.id)
        presenter.setFilterIntensity(0.2)
        presenter.selectFilter(secondFilter.id)

        #expect(presenter.draft?.selectedFilterID == secondFilter.id)
        #expect(presenter.draft?.filterIntensity == 1)
    }

    @Test func intensityDragRecordsHistoryOnlyWhenCommitted() async throws {
        let presenter = makePresenter()
        presenter.startEditingCapturedPhoto(
            uri: try #require(URL(string: "https://example.com/capture.jpg")),
            id: "capture"
        )
        presenter.selectFilter("01_brooklyn")

        presenter.setFilterIntensity(0.8)
        presenter.setFilterIntensity(0.5)
        presenter.setFilterIntensity(0.2)
        presenter.commitFilterIntensity()
        presenter.undoLastEdit()

        #expect(presenter.draft?.selectedFilterID == "01_brooklyn")
        #expect(presenter.draft?.filterIntensity == 1)
    }

    @Test func cropDragRecordsHistoryOnlyWhenCommitted() async throws {
        let presenter = makePresenter()
        presenter.startEditingCapturedPhoto(
            uri: try #require(URL(string: "https://example.com/capture.jpg")),
            id: "capture"
        )

        presenter.resizeCrop(
            edge: .leading,
            baseCrop: nil,
            horizontalDelta: 0.1,
            verticalDelta: 0
        )
        presenter.resizeCrop(
            edge: .leading,
            baseCrop: nil,
            horizontalDelta: 0.2,
            verticalDelta: 0
        )
        presenter.commitCropResize()
        presenter.undoLastEdit()

        #expect(presenter.draft?.crop == nil)
    }

    @Test func presenterRejectsUnknownFilter() async throws {
        let presenter = makePresenter()
        presenter.startEditingCapturedPhoto(
            uri: try #require(URL(string: "https://example.com/capture.jpg")),
            now: Date(),
            id: "capture"
        )

        presenter.selectFilter("unknown")

        #expect(presenter.draft?.selectedFilterID == GalleryFilter.original.id)
        #expect(presenter.toast == .error("Filter unavailable"))
    }

    @Test func editHistoryUndoReturnsPreviousStep() async throws {
        let photo = GalleryPhoto(
            id: UUID().uuidString,
            imageURI: try #require(URL(string: "https://example.com/photo.jpg")),
            createdAt: Date()
        )
        let store = GalleryEditHistoryStore()
        var draft = GalleryDraft(photo: photo)

        store.reset(for: photo.id)
        _ = store.record(draft)
        draft.selectedFilterID = "01_brooklyn"
        _ = store.record(draft)

        let state = store.undo()

        #expect(state.currentDraft?.selectedFilterID == GalleryFilter.original.id)
        #expect(state.canUndo == false)
    }

    @Test func editHistoryPrunesRedoStepsAfterNewEdit() async throws {
        let photo = GalleryPhoto(
            id: UUID().uuidString,
            imageURI: try #require(URL(string: "https://example.com/photo.jpg")),
            createdAt: Date()
        )
        let store = GalleryEditHistoryStore()
        var draft = GalleryDraft(photo: photo)

        store.reset(for: photo.id)
        _ = store.record(draft)
        draft.selectedFilterID = "01_brooklyn"
        _ = store.record(draft)
        draft.selectedFilterID = "02_poprocket"
        _ = store.record(draft)
        _ = store.undo()

        draft.selectedFilterID = "03_nashville"
        let replacementState = store.record(draft)
        let undoState = store.undo()

        #expect(replacementState.canUndo == true)
        #expect(undoState.currentDraft?.selectedFilterID == "01_brooklyn")
        #expect(store.undo().currentDraft?.selectedFilterID == GalleryFilter.original.id)
    }

    @Test func presenterShowsImportFailureToast() async throws {
        let presenter = GalleryPresenter(
            interactor: FailingImportInteractor(),
            router: GalleryRouter()
        )

        await presenter.startEditingImportedPhoto(data: Data(), now: Date(), id: "import")

        #expect(presenter.screen == .gallery)
        #expect(presenter.draft == nil)
        #expect(presenter.toast == .error("Import failed"))
    }

    @Test func presenterCancelsNewDraftBackToGallery() async throws {
        let presenter = makePresenter()
        presenter.startEditingCapturedPhoto(
            uri: try #require(URL(string: "https://example.com/capture.jpg")),
            now: Date(),
            id: "capture"
        )

        presenter.cancelEditing()

        #expect(presenter.screen == .gallery)
        #expect(presenter.draft == nil)
        #expect(presenter.photos.isEmpty)
    }

    @Test func presenterDeletesSelectedPhoto() async throws {
        let photo = GalleryPhoto(
            id: "photo",
            imageURI: try #require(URL(string: "https://example.com/photo.jpg")),
            createdAt: Date()
        )
        let presenter = makePresenter(photos: [photo])
        presenter.selectPhoto(photo)
        presenter.requestDeleteSelectedPhoto()

        presenter.confirmDeleteSelectedPhoto()

        #expect(presenter.photos.isEmpty)
        #expect(presenter.screen == .gallery)
        #expect(presenter.isDeleteConfirmationPresented == false)
        #expect(presenter.toast == .success("Photo deleted"))
    }

    @Test func localPhotoEncodingStoresOnlyStableFilename() throws {
        let oldContainerURL = URL(
            fileURLWithPath: "/var/mobile/Containers/Data/Application/OLD/Library/Application Support/OxidePhotoLibrary/photo.jpg"
        )
        let photo = GalleryPhoto(
            id: "photo",
            imageURI: oldContainerURL,
            createdAt: Date(timeIntervalSince1970: 10)
        )

        let data = try JSONEncoder().encode(photo)
        let json = try #require(String(data: data, encoding: .utf8))

        #expect(json.contains("\"imageURI\":\"photo.jpg\""))
        #expect(!json.contains("/var/mobile/Containers"))
    }

    @Test func draftCommitsAdjustments() {
        let photo = GalleryPhoto(
            id: "photo",
            imageURI: URL(fileURLWithPath: "/tmp/photo.jpg"),
            createdAt: Date()
        )
        var draft = GalleryDraft(photo: photo)
        draft.adjustments.exposure = 1.25
        draft.adjustments.contrast = 1.2
        draft.adjustments.isMonochrome = true

        let committed = draft.committed()

        #expect(committed.adjustments.exposure == 1.25)
        #expect(committed.adjustments.contrast == 1.2)
        #expect(committed.adjustments.isMonochrome)
    }

    @Test func adjustmentDragClampsAndRecordsOneUndoStep() async throws {
        let presenter = makePresenter()
        presenter.startEditingCapturedPhoto(
            uri: try #require(URL(string: "https://example.com/capture.jpg")),
            id: "capture"
        )

        presenter.setAdjustment(.exposure, value: 1)
        presenter.setAdjustment(.exposure, value: 4)
        presenter.commitAdjustment()
        #expect(presenter.draft?.adjustments.exposure == 2)

        presenter.undoLastEdit()
        #expect(presenter.draft?.adjustments == .neutral)
    }

    @Test func editorGeometryUsesUncroppedAspectDuringCropEditing() {
        let crop = ImageEditCrop(x: 0.25, y: 0, width: 0.5, height: 1)

        let cropEditingSize = GalleryEditorImageGeometry.effectiveSize(
            sourceSize: CGSize(width: 4000, height: 3000),
            crop: crop,
            rotationDegrees: 0,
            appliesCrop: false
        )
        let committedSize = GalleryEditorImageGeometry.effectiveSize(
            sourceSize: CGSize(width: 4000, height: 3000),
            crop: crop,
            rotationDegrees: 90,
            appliesCrop: true
        )

        #expect(cropEditingSize == CGSize(width: 4000, height: 3000))
        #expect(committedSize == CGSize(width: 3000, height: 2000))
    }

    @Test func legacyAbsolutePhotoPathMigratesToCurrentContainer() throws {
        let oldPath = "file:///var/mobile/Containers/Data/Application/OLD/Library/Application%20Support/OxidePhotoLibrary/photo.jpg"
        let json = """
        {
          "id": "photo",
          "imageURI": "\(oldPath)",
          "createdAt": 10,
          "filterIntensity": 1,
          "rotationDegrees": 0
        }
        """

        let photo = try JSONDecoder().decode(
            GalleryPhoto.self,
            from: Data(json.utf8)
        )

        #expect(photo.imageURI.isFileURL)
        #expect(photo.imageURI.lastPathComponent == "photo.jpg")
        #expect(photo.imageURI.path.contains("OxidePhotoLibrary"))
        #expect(!photo.imageURI.absoluteString.contains("/OLD/"))
    }

    private func makePresenter(photos: [GalleryPhoto] = []) -> GalleryPresenter {
        GalleryPresenter(
            interactor: GalleryInteractor(
                photos: photos,
                persistsChanges: false
            ),
            router: GalleryRouter()
        )
    }

}

@MainActor
private struct FailingImportInteractor: GalleryInteractorProtocol {
    func loadPhotos() -> [GalleryPhoto] { [] }
    func save(_ photo: GalleryPhoto) -> [GalleryPhoto] { [photo] }
    func delete(photoID: GalleryPhoto.ID) -> [GalleryPhoto] { [] }
    func beginEditHistory(for photo: GalleryPhoto) { }
    func recordEditStep(_ draft: GalleryDraft) -> GalleryEditHistoryState {
        GalleryEditHistoryState(currentDraft: draft, canUndo: true)
    }
    func undoEditStep() -> GalleryEditHistoryState {
        GalleryEditHistoryState(currentDraft: nil, canUndo: false)
    }
    func preloadFilterPreviews(for imageURL: URL, filters: [GalleryFilter]) { }
    func sourceImageSize(for imageURL: URL) -> CGSize? { nil }

    func storeImportedImage(data: Data, id: String) async throws -> URL {
        throw CocoaError(.fileWriteUnknown)
    }
}
