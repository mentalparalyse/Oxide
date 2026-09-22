import Foundation
import ImageProcessor
import Testing
@testable import Editor

@MainActor
struct SavedLookApplicationTests {
    @Test func applyingAcrossPhotosReplacesLookOnlyAndOneUndoRestoresLiveEdits() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let interactor = EditorInteractor(history: EditorHistoryStore(persistence: .init(rootDirectory: root)))
        let asset = EditorAsset(
            id: "target", imageURI: root.appendingPathComponent("target.jpg"), createdAt: Date(),
            rotationDegrees: 90, crop: ImageEditCrop(x: 0.1, y: 0.2, width: 0.6, height: 0.5)
        )
        await interactor.beginHistory(for: asset)
        var before = EditorDraft(asset: asset)
        before.adjustments.exposure = 0.8
        before.effects = ImageEffects(bloom: ImageBloom(amount: 0.4))
        var source = EditorDraft(asset: EditorAsset(id: "source", imageURI: root, createdAt: Date()))
        source.selectedFilterID = "cinematic"
        source.filterIntensity = 0.72
        source.adjustments.exposure = 1.2
        source.effects = ImageEffects(filmGrain: ImageFilmGrain(amount: 0.5))
        let look = SavedLook(name: "Film", draft: source)

        let applied = try await interactor.applyLook(look, to: before)
        let result = try #require(applied.currentDraft)
        #expect(result.asset == asset)
        #expect(result.crop == before.crop)
        #expect(result.rotationDegrees == 90)
        #expect(result.selectedFilterID == source.selectedFilterID)
        #expect(result.filterIntensity == source.filterIntensity)
        #expect(result.adjustments == source.adjustments)
        #expect(result.effects == source.effects)
        #expect(applied.canUndo)
        #expect(await interactor.undo().currentDraft == before)
        #expect(await interactor.undo().currentDraft == EditorDraft(asset: asset))
    }

    @Test func alreadyRecordedDraftAndIdenticalLookDoNotAddRedundantUndoSteps() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let interactor = EditorInteractor(history: EditorHistoryStore(persistence: .init(rootDirectory: root)))
        let asset = EditorAsset(id: "asset", imageURI: root, createdAt: Date())
        await interactor.beginHistory(for: asset)
        let original = EditorDraft(asset: asset)
        let unchanged = try await interactor.applyLook(SavedLook(name: "Same", draft: original), to: original)
        #expect(!unchanged.canUndo)
        var source = original
        source.adjustments.exposure = 1
        _ = try await interactor.applyLook(SavedLook(name: "Bright", draft: source), to: original)
        let undone = await interactor.undo()
        #expect(undone.currentDraft == original)
        #expect(!undone.canUndo)
    }

    @Test func unavailableFilterAndFailedHistoryWriteDoNotCommitLook() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let interactor = EditorInteractor(history: EditorHistoryStore(persistence: .init(rootDirectory: root)))
        let asset = EditorAsset(id: "asset", imageURI: root, createdAt: Date())
        await interactor.beginHistory(for: asset)
        let original = EditorDraft(asset: asset)
        var source = original
        source.selectedFilterID = "missing"
        await #expect(throws: SavedLookApplicationError.unavailableFilter) {
            try await interactor.applyLook(SavedLook(name: "Missing", draft: source), to: original)
        }
        // A directory at the next snapshot path forces the actual atomic write to fail.
        try FileManager.default.createDirectory(
            at: root.appendingPathComponent("OxideEditHistory/asset/1.json"), withIntermediateDirectories: true
        )
        source.selectedFilterID = "cinematic"
        await #expect(throws: EditorHistoryStore.HistoryError.recordingFailed) {
            try await interactor.applyLook(SavedLook(name: "Film", draft: source), to: original)
        }
        let state = await interactor.undo()
        #expect(state.currentDraft == original)
        #expect(!state.canUndo)
    }
}
