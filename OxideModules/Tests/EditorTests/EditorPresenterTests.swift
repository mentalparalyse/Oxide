import Foundation
import ImageProcessor
import Testing
@testable import Editor

@MainActor
struct EditorPresenterTests {
    @Test func filterDragUpdatesLiveAndRecordsOnlyOnCommit() async throws {
        let interactor = EditorInteractorSpy()
        let presenter = makePresenter(interactor: interactor)

        await presenter.selectFilter("cinematic")
        presenter.setFilterIntensity(0.8)
        presenter.setFilterIntensity(0.2)

        #expect(presenter.draft.filterIntensity == 0.2)
        #expect(interactor.recordedDrafts.count == 1)

        await presenter.commitFilterIntensity()
        #expect(interactor.recordedDrafts.count == 2)
    }

    @Test func adjustmentValuesAreClampedBeforeCommit() async {
        let interactor = EditorInteractorSpy()
        let presenter = makePresenter(interactor: interactor)

        presenter.setAdjustment(.exposure, value: 4)
        presenter.setAdjustment(.contrast, value: 0)
        await presenter.commitAdjustment()

        #expect(presenter.draft.adjustments.exposure == 2)
        #expect(presenter.draft.adjustments.contrast == 0.5)
        #expect(interactor.recordedDrafts.count == 1)
    }

    @Test func unknownFilterReportsFailureWithoutChangingDraft() async {
        var errors: [String] = []
        let presenter = makePresenter(onError: { errors.append($0) })

        await presenter.selectFilter("missing")

        #expect(presenter.draft.selectedFilterID == GalleryFilter.original.id)
        #expect(errors == ["Filter unavailable"])
    }

    @Test func saveReturnsCommittedEditorAsset() async {
        var savedAsset: EditorAsset?
        let presenter = makePresenter(onSave: { savedAsset = $0 })
        await presenter.rotate(by: 90)

        presenter.save()

        #expect(savedAsset?.id == "asset")
        #expect(savedAsset?.rotationDegrees == 90)
    }

    @Test func cropIsSavedAndRecordedOnCommit() async {
        let interactor = EditorInteractorSpy()
        var saved: EditorAsset?
        let presenter = makePresenter(interactor: interactor, onSave: { saved = $0 })
        let crop = ImageEditCrop(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
        presenter.setCrop(crop)
        #expect(interactor.recordedDrafts.isEmpty)
        await presenter.finishCropping()
        presenter.save()
        #expect(interactor.recordedDrafts.map(\.crop) == [crop])
        #expect(saved?.crop == crop)
    }

    @Test func invalidCropDoesNotReplaceSelection() {
        var errors: [String] = []
        let presenter = makePresenter(onError: { errors.append($0) })
        presenter.setCrop(ImageEditCrop(x: .nan, y: 0, width: 1, height: 1))
        presenter.setCrop(ImageEditCrop(x: 0.8, y: 0, width: 0.5, height: 1))
        presenter.setCrop(ImageEditCrop(x: 0, y: 0, width: 0, height: 1))
        #expect(presenter.draft.crop == nil)
        #expect(errors.count == 3)
    }

    @Test func rotatedAspectRatioMatchesDisplayedImage() async {
        let interactor = EditorInteractorSpy()
        interactor.imageSize = CGSize(width: 400, height: 600)
        let presenter = makePresenter(interactor: interactor)
        await presenter.rotate(by: 90)
        presenter.setCropAspectRatio(4.0 / 3.0)
        let crop = presenter.cropDraft!.crop!
        #expect(abs((600 * crop.height) / (400 * crop.width) - 4.0 / 3.0) < 1e-9)
    }

    @Test func cropAdjustmentsCreateOnlyOneHistoryStepOnDone() async {
        let interactor = EditorInteractorSpy()
        interactor.imageSize = CGSize(width: 400, height: 600)
        let presenter = makePresenter(interactor: interactor)
        presenter.beginCropping()
        presenter.setCropAspectRatio(1)
        presenter.setCropAspectRatio(4.0 / 3.0)
        let crop = ImageEditCrop(x: 0.2, y: 0.2, width: 0.5, height: 0.5)
        presenter.setCrop(crop)
        #expect(presenter.draft.crop == nil)
        #expect(interactor.recordedDrafts.isEmpty)
        await presenter.finishCropping()
        await presenter.finishCropping()
        #expect(interactor.recordedDrafts.map(\.crop) == [crop])
        #expect(presenter.draft.crop == crop)
        #expect(presenter.cropDraft == nil)
        #expect(presenter.canUndo)
    }

    @Test func leavingCropDiscardsPendingChangesAndSaveUsesAppliedCrop() {
        let interactor = EditorInteractorSpy()
        var saved: EditorAsset?
        let presenter = makePresenter(interactor: interactor, onSave: { saved = $0 })
        presenter.beginCropping()
        presenter.setCrop(ImageEditCrop(x: 0.2, y: 0.2, width: 0.5, height: 0.5))
        presenter.save()
        #expect(saved?.crop == nil)
        presenter.cancelCropping()
        presenter.beginCropping()
        #expect(presenter.cropDraft?.crop == nil)
        #expect(interactor.recordedDrafts.isEmpty)
    }

    @Test func doneWithoutChangesDoesNotAddHistory() async {
        let interactor = EditorInteractorSpy()
        let presenter = makePresenter(interactor: interactor)
        presenter.beginCropping()
        await presenter.finishCropping()
        #expect(interactor.recordedDrafts.isEmpty)
        #expect(!presenter.isApplyingCrop)
    }

    @Test func oneUndoRestoresImageBeforeTheWholeCropSession() async {
        let interactor = EditorInteractorSpy()
        let presenter = makePresenter(interactor: interactor)
        await presenter.rotate(by: 90)
        presenter.beginCropping()
        presenter.setCrop(ImageEditCrop(x: 0.1, y: 0.1, width: 0.8, height: 0.8))
        presenter.setCrop(ImageEditCrop(x: 0.2, y: 0.2, width: 0.5, height: 0.5))
        await presenter.finishCropping()
        await presenter.undo()
        #expect(presenter.draft.crop == nil)
        #expect(presenter.draft.rotationDegrees == 90)
        #expect(presenter.canUndo)
    }

    @Test func unavailableCropDoesNotAddUndoStep() async {
        let interactor = EditorInteractorSpy()
        var errors: [String] = []
        let presenter = makePresenter(interactor: interactor, onError: { errors.append($0) })
        presenter.beginCropping()
        presenter.setCropAspectRatio(1)
        await presenter.finishCropping()
        #expect(errors == ["Crop unavailable"])
        #expect(interactor.recordedDrafts.isEmpty)
    }

    @Test func returningToFullImageDoesNotCreateRedundantCropStep() async {
        let interactor = EditorInteractorSpy()
        let presenter = makePresenter(interactor: interactor)
        presenter.beginCropping()
        presenter.setCrop(ImageEditCrop(x: 0.25, y: 0.25, width: 0.5, height: 0.5))
        presenter.setCrop(GalleryCropGeometry.fullImage)
        await presenter.finishCropping()
        #expect(interactor.recordedDrafts.isEmpty)
        #expect(presenter.draft.crop == nil)
    }

    private func makePresenter(
        interactor: EditorInteractorProtocol? = nil,
        onSave: @escaping @MainActor (EditorAsset) -> Void = { _ in },
        onError: @escaping @MainActor (String) -> Void = { _ in }
    ) -> EditorPresenter {
        EditorPresenter(
            asset: EditorAsset(
                id: "asset",
                imageURI: URL(fileURLWithPath: "/tmp/asset.jpg"),
                createdAt: Date(timeIntervalSince1970: 10)
            ),
            interactor: interactor ?? EditorInteractorSpy(),
            onCancel: {},
            onSave: onSave,
            onError: onError
        )
    }
}

@MainActor
private final class EditorInteractorSpy: EditorInteractorProtocol {
    var recordedDrafts: [EditorDraft] = []
    var imageSize: CGSize?

    private var history: [EditorDraft] = []

    func beginHistory(for asset: EditorAsset) async { history = [EditorDraft(asset: asset)] }
    func sourceImageSize(for imageURL: URL) -> CGSize? { imageSize }
    func preloadFilterPreviews(filters: [GalleryFilter]) {}

    func record(_ draft: EditorDraft) async -> EditorHistoryState {
        recordedDrafts.append(draft)
        history.append(draft)
        return EditorHistoryState(currentDraft: draft, canUndo: true)
    }

    func undo() async -> EditorHistoryState {
        if history.count > 1 { history.removeLast() }
        return EditorHistoryState(currentDraft: history.last, canUndo: history.count > 1)
    }
}
