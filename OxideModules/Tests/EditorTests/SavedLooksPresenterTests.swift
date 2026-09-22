import Foundation
import Testing
@testable import Editor

@MainActor
struct SavedLooksPresenterTests {
    @Test func savingUsesCapturedSettingsAndPersistsAcrossLibrarySessions() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        var draft = makeDraft()
        draft.adjustments.exposure = 0.8
        let presenter = makePresenter(draft: draft, interactor: SavedLooksInteractor(store: SavedLookStore(directory: root)))
        draft.adjustments.exposure = -1
        await presenter.load()
        presenter.beginNaming()
        presenter.name = " \n "
        #expect(!presenter.canSave)
        await presenter.save()
        #expect(presenter.looks.isEmpty)
        presenter.name = "  Film  "
        await presenter.save()
        #expect(!presenter.isNamingLook)
        #expect(presenter.looks.first?.name == "Film")
        #expect(presenter.looks.first?.adjustments.exposure == 0.8)
        let reopened = makePresenter(interactor: SavedLooksInteractor(store: SavedLookStore(directory: root)))
        await reopened.load()
        #expect(reopened.looks == presenter.looks)
    }

    @Test func loadAndSaveFailuresSupportRetryWithoutLosingNameOrClaimingSuccess() async {
        let interactor = SavedLooksInteractorStub()
        let presenter = makePresenter(interactor: interactor)
        interactor.failure = CocoaError(.fileReadUnknown)
        await presenter.load()
        #expect(presenter.loadState == .failed)
        #expect(presenter.errorMessage != nil)
        presenter.name = "Film"
        #expect(!presenter.canSave)
        interactor.failure = nil
        await presenter.load()
        presenter.beginNaming()
        presenter.name = "Film"
        interactor.failure = CocoaError(.fileWriteUnknown)
        await presenter.save()
        #expect(presenter.isNamingLook)
        #expect(presenter.name == "Film")
        #expect(presenter.looks.isEmpty)
        #expect(presenter.errorMessage != nil)
        #expect(!presenter.isBusy)
        interactor.failure = nil
        await presenter.save()
        #expect(!presenter.isNamingLook)
        #expect(presenter.errorMessage == nil)
        #expect(presenter.looks.count == 1)
    }

    @Test func failedApplicationKeepsLibraryOpenAndSuccessfulApplicationClosesIt() async {
        let actions = SavedLooksActionsSpy()
        let presenter = SavedLooksPresenter(
            draft: makeDraft(), interactor: SavedLooksInteractorStub(),
            onApply: { _ in if actions.shouldFail { throw SavedLookApplicationError.unavailableFilter } },
            onClose: { actions.closed = true }
        )
        await presenter.load()
        let look = SavedLook(name: "Film", draft: makeDraft())
        await presenter.apply(look)
        #expect(!actions.closed)
        #expect(presenter.errorMessage == "This look’s filter is unavailable.")
        #expect(!presenter.isBusy)
        actions.shouldFail = false
        await presenter.apply(look)
        #expect(actions.closed)
        #expect(presenter.errorMessage == nil)
    }

    @Test func canceledLoadingCanRetryWithoutShowingAnError() async {
        let interactor = SavedLooksInteractorStub()
        interactor.failure = CancellationError()
        let presenter = makePresenter(interactor: interactor)
        await presenter.load()
        #expect(presenter.loadState == .idle)
        #expect(presenter.errorMessage == nil)
        interactor.failure = nil
        await presenter.load()
        #expect(presenter.loadState == .loaded)
    }

    private func makeDraft() -> EditorDraft {
        EditorDraft(asset: EditorAsset(id: "photo", imageURI: URL(fileURLWithPath: "/tmp/photo.jpg"), createdAt: Date()))
    }

    private func makePresenter(
        draft: EditorDraft? = nil,
        interactor: any SavedLooksInteractorProtocol
    ) -> SavedLooksPresenter {
        SavedLooksPresenter(draft: draft ?? makeDraft(), interactor: interactor, onApply: { _ in }, onClose: {})
    }
}

@MainActor
private final class SavedLooksActionsSpy {
    var shouldFail = true
    var closed = false
}

@MainActor
private final class SavedLooksInteractorStub: SavedLooksInteractorProtocol {
    var failure: (any Error)?
    func loadLooks() async throws -> [SavedLook] {
        if let failure { throw failure }
        return []
    }
    func saveLook(named name: String, draft: EditorDraft) async throws -> [SavedLook] {
        if let failure { throw failure }
        return [SavedLook(name: name, draft: draft)]
    }
}
