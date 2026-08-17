import Foundation
import ImageProcessor
import Testing
import UIKit
@testable import Gallery

@MainActor
struct GalleryPreviewExportTests {
    @Test func saveTransitionsToSavedAndResetsWhenClosed() async {
        let exporter = ImageExporterSpy()
        let presenter = makePresenter(exporter: exporter)

        await presenter.saveSelectedPhotoToLibrary()

        #expect(presenter.previewSaveState == .saved)
        let savedFileURLCount = await exporter.savedFileURLCount
        #expect(savedFileURLCount == 1)
        presenter.dismissPreview()
        #expect(presenter.previewSaveState == .idle)
    }

    @Test func exportFailureReturnsSaveToIdleForRetry() async {
        let presenter = makePresenter(exporter: ImageExporterSpy(failure: .export))

        await presenter.saveSelectedPhotoToLibrary()

        #expect(presenter.previewSaveState == .idle)
        #expect(presenter.toast == .error("Save failed"))
    }

    @Test func photoLibraryFailureAllowsSaveRetry() async {
        let exporter = ImageExporterSpy(failure: .photoLibrary)
        let presenter = makePresenter(exporter: exporter)

        await presenter.saveSelectedPhotoToLibrary()

        #expect(presenter.previewSaveState == .idle)
        #expect(presenter.toast == .error("Save failed"))
        let counts = await exporter.callCounts
        #expect(counts.export == 1)
        #expect(counts.save == 1)
    }

    @Test func savedPreviewCannotBeSavedTwice() async {
        let exporter = ImageExporterSpy()
        let presenter = makePresenter(exporter: exporter)

        await presenter.saveSelectedPhotoToLibrary()
        await presenter.saveSelectedPhotoToLibrary()

        let counts = await exporter.callCounts
        #expect(counts.export == 1)
        #expect(counts.save == 1)
    }

    @Test func saveWithoutSelectedPreviewDoesNotExport() async {
        let exporter = ImageExporterSpy()
        let presenter = GalleryPresenter(
            interactor: GalleryInteractor(photos: [], persistsChanges: false),
            router: RouterSpy(),
            imageExporter: exporter
        )

        await presenter.saveSelectedPhotoToLibrary()

        #expect(presenter.previewSaveState == .idle)
        let counts = await exporter.callCounts
        #expect(counts.export == 0)
        #expect(counts.save == 0)
    }

    @Test func shareExportsAllEditMetadataAndRoutesSheet() async {
        var photo = makePhoto()
        photo.filterID = "01_brooklyn"
        photo.filterIntensity = 0.4
        photo.rotationDegrees = 90
        photo.crop = ImageEditCrop(x: 0.1, y: 0.2, width: 0.7, height: 0.6)
        let router = RouterSpy()
        let exporter = ImageExporterSpy()
        let presenter = makePresenter(photo: photo, router: router, exporter: exporter)

        await presenter.shareSelectedPhoto()

        #expect(router.sharedFileURLs.count == 1)
        #expect(presenter.isPreparingShare == false)
        let exportedPhotos = await exporter.exportedPhotos
        #expect(exportedPhotos == [photo])
    }

    @Test func shareFailureRestoresAvailabilityAndShowsError() async {
        let router = RouterSpy()
        let presenter = makePresenter(
            router: router,
            exporter: ImageExporterSpy(failure: .export)
        )

        await presenter.shareSelectedPhoto()

        #expect(presenter.isPreparingShare == false)
        #expect(presenter.toast == .error("Share failed"))
        #expect(router.sharedFileURLs.isEmpty)
    }

    @Test func shareWithoutSelectedPreviewDoesNotExport() async {
        let exporter = ImageExporterSpy()
        let presenter = GalleryPresenter(
            interactor: GalleryInteractor(photos: [], persistsChanges: false),
            router: RouterSpy(),
            imageExporter: exporter
        )

        await presenter.shareSelectedPhoto()

        let exportCallCount = await exporter.exportCallCount
        #expect(exportCallCount == 0)
        #expect(presenter.isPreparingShare == false)
    }

    @Test func exporterRejectsMissingSourceImage() async {
        let photo = GalleryPhoto(
            id: UUID().uuidString,
            imageURI: FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("jpg"),
            createdAt: Date()
        )

        do {
            _ = try await GalleryImageExporter().exportFile(for: photo)
            Issue.record("Expected rendering to fail for a missing image")
        } catch ImageExportError.renderingFailed {
        } catch {
            Issue.record("Unexpected export error: \(error)")
        }
    }

    @Test func exporterRendersCropAndRotationToJPEG() async throws {
        let sourceURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("png")
        let source = makeSolidImage(size: CGSize(width: 80, height: 40), color: .red)
        try #require(source.pngData()).write(to: sourceURL, options: .atomic)
        defer { try? FileManager.default.removeItem(at: sourceURL) }
        let photo = GalleryPhoto(
            id: UUID().uuidString,
            imageURI: sourceURL,
            createdAt: Date(),
            rotationDegrees: 90,
            crop: ImageEditCrop(x: 0, y: 0, width: 0.75, height: 1)
        )

        let exportURL = try await GalleryImageExporter().exportFile(for: photo)
        defer { try? FileManager.default.removeItem(at: exportURL) }
        let exportedImage = try #require(UIImage(data: Data(contentsOf: exportURL)))

        #expect(exportURL.pathExtension == "jpg")
        #expect(exportedImage.size == CGSize(width: 40, height: 60))
    }

    private func makePhoto() -> GalleryPhoto {
        GalleryPhoto(
            id: "photo",
            imageURI: URL(fileURLWithPath: "/tmp/photo.jpg"),
            createdAt: Date()
        )
    }

    private func makeSolidImage(size: CGSize, color: UIColor) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            color.setFill()
            context.cgContext.fill(CGRect(origin: .zero, size: size))
        }
    }

    private func makePresenter(
        photo: GalleryPhoto? = nil,
        router: GalleryRouterProtocol = RouterSpy(),
        exporter: GalleryImageExporting
    ) -> GalleryPresenter {
        let photo = photo ?? makePhoto()
        let presenter = GalleryPresenter(
            interactor: GalleryInteractor(photos: [photo], persistsChanges: false),
            router: router,
            imageExporter: exporter
        )
        presenter.selectPhoto(photo)
        return presenter
    }
}

@MainActor
private final class RouterSpy: GalleryRouterProtocol {
    private(set) var sharedFileURLs: [URL] = []

    func presentShareSheet(for fileURL: URL) {
        sharedFileURLs.append(fileURL)
    }
}

private actor ImageExporterSpy: GalleryImageExporting {
    enum Failure { case export, photoLibrary }

    private let failure: Failure?
    private var savedFileURLs: [URL] = []
    private(set) var exportedPhotos: [GalleryPhoto] = []
    var savedFileURLCount: Int { savedFileURLs.count }
    var exportCallCount: Int { exportedPhotos.count }
    var saveCallCount: Int { savedFileURLs.count }
    var callCounts: (export: Int, save: Int) {
        (exportedPhotos.count, savedFileURLs.count)
    }

    init(failure: Failure? = nil) {
        self.failure = failure
    }

    func exportFile(for photo: GalleryPhoto) async throws -> URL {
        exportedPhotos.append(photo)
        if failure == .export { throw ImageExportError.renderingFailed }
        return URL(fileURLWithPath: "/tmp/export-\(photo.id).jpg")
    }

    func saveToPhotoLibrary(_ fileURL: URL) async throws {
        savedFileURLs.append(fileURL)
        if failure == .photoLibrary { throw PhotoLibraryStoreError.accessDenied }
    }
}
