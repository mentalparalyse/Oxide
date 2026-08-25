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

    func beginHistory(for asset: EditorAsset) async {}
    func sourceImageSize(for imageURL: URL) -> CGSize? { nil }
    func preloadFilterPreviews(filters: [GalleryFilter]) {}

    func record(_ draft: EditorDraft) async -> EditorHistoryState {
        recordedDrafts.append(draft)
        return EditorHistoryState(currentDraft: draft, canUndo: true)
    }

    func undo() async -> EditorHistoryState {
        EditorHistoryState(currentDraft: nil, canUndo: false)
    }
}
