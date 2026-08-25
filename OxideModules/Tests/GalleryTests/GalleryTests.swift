// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Editor
import Foundation
import Testing
@testable import Gallery

@MainActor
struct GalleryTests {
    @Test func interactorSortsPhotosByNewestDate() throws {
        let older = try photo(id: "older", timestamp: 10)
        let newer = try photo(id: "newer", timestamp: 20)
        let interactor = GalleryInteractor(photos: [older, newer], persistsChanges: false)

        #expect(interactor.loadPhotos().map(\.id) == ["newer", "older"])
    }

    @Test func saveUpdatesExistingPhotoWithoutDuplicatingIt() throws {
        let original = try photo(id: "photo", timestamp: 10)
        let interactor = GalleryInteractor(photos: [original], persistsChanges: false)
        var updated = original
        updated.filterID = "01_brooklyn"
        updated.rotationDegrees = 90

        let photos = interactor.save(updated)

        #expect(photos.count == 1)
        #expect(photos.first?.filterID == "01_brooklyn")
        #expect(photos.first?.rotationDegrees == 90)
    }

    @Test func capturedPhotoLaunchesEditorWithoutPersistingDraft() async throws {
        let presenter = makePresenter()
        let uri = try #require(URL(string: "https://example.com/capture.jpg"))

        await presenter.startEditingCapturedPhoto(uri: uri, now: Date(timeIntervalSince1970: 100), id: "capture")

        #expect(presenter.screen == .editing("capture"))
        #expect(presenter.editorPresenter?.draft.asset.imageURI == uri)
        #expect(presenter.photos.isEmpty)
    }

    @Test func editorSaveMapsAssetBackIntoGalleryPersistence() async throws {
        let presenter = makePresenter()
        await presenter.startEditingCapturedPhoto(
            uri: try #require(URL(string: "https://example.com/capture.jpg")),
            id: "capture"
        )
        let editor = try #require(presenter.editorPresenter)
        await editor.selectFilter("cinematic")
        await editor.rotate(by: 90)

        editor.save()

        #expect(presenter.screen == .gallery)
        #expect(presenter.editorPresenter == nil)
        #expect(presenter.photos.first?.filterID == "cinematic")
        #expect(presenter.photos.first?.rotationDegrees == 90)
        #expect(presenter.toast == .success("Photo saved"))
    }

    @Test func editorCancelReturnsNewCaptureToGallery() async throws {
        let presenter = makePresenter()
        await presenter.startEditingCapturedPhoto(
            uri: try #require(URL(string: "https://example.com/capture.jpg")),
            id: "capture"
        )

        presenter.editorPresenter?.cancel()

        #expect(presenter.screen == .gallery)
        #expect(presenter.editorPresenter == nil)
        #expect(presenter.photos.isEmpty)
    }

    @Test func presenterShowsImportFailureToast() async {
        let presenter = GalleryPresenter(interactor: FailingImportInteractor(), router: GalleryRouter())

        await presenter.startEditingImportedPhoto(data: Data(), id: "import")

        #expect(presenter.screen == .gallery)
        #expect(presenter.editorPresenter == nil)
        #expect(presenter.toast == .error("Import failed"))
    }

    @Test func presenterDeletesSelectedPhoto() throws {
        let existing = try photo(id: "photo", timestamp: 10)
        let presenter = makePresenter(photos: [existing])
        presenter.selectPhoto(existing)
        presenter.requestDeleteSelectedPhoto()

        presenter.confirmDeleteSelectedPhoto()

        #expect(presenter.photos.isEmpty)
        #expect(presenter.screen == .gallery)
        #expect(!presenter.isDeleteConfirmationPresented)
    }

    @Test func localPhotoEncodingStoresOnlyStableFilename() throws {
        let local = GalleryPhoto(
            id: "photo",
            imageURI: URL(fileURLWithPath: "/var/mobile/Containers/Data/Application/OLD/photo.jpg"),
            createdAt: Date(timeIntervalSince1970: 10)
        )

        let json = try #require(String(data: JSONEncoder().encode(local), encoding: .utf8))

        #expect(json.contains("\"imageURI\":\"photo.jpg\""))
        #expect(!json.contains("/var/mobile/Containers"))
    }

    private func makePresenter(photos: [GalleryPhoto] = []) -> GalleryPresenter {
        GalleryPresenter(
            interactor: GalleryInteractor(photos: photos, persistsChanges: false),
            router: GalleryRouter()
        )
    }

    private func photo(id: String, timestamp: TimeInterval) throws -> GalleryPhoto {
        GalleryPhoto(
            id: id,
            imageURI: try #require(URL(string: "https://example.com/\(id).jpg")),
            createdAt: Date(timeIntervalSince1970: timestamp)
        )
    }
}

@MainActor
private struct FailingImportInteractor: GalleryInteractorProtocol {
    func loadPhotos() -> [GalleryPhoto] { [] }
    func save(_ photo: GalleryPhoto) -> [GalleryPhoto] { [photo] }
    func delete(photoID: GalleryPhoto.ID) -> [GalleryPhoto] { [] }
    func sourceImageSize(for imageURL: URL) -> CGSize? { nil }
    func storeImportedImage(data: Data, id: String) async throws -> URL {
        throw CocoaError(.fileWriteUnknown)
    }
}
