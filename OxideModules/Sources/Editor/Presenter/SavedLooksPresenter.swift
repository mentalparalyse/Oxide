import Combine
import Foundation

@MainActor
final class SavedLooksPresenter: ObservableObject, Identifiable {
    enum LoadState { case idle, loading, loaded, failed }
    enum Operation { case idle, saving, applying }

    let id = UUID()
    let previewDraft: EditorDraft
    @Published private(set) var looks: [SavedLook] = []
    @Published private(set) var loadState = LoadState.idle
    @Published private(set) var operation = Operation.idle
    @Published private(set) var errorMessage: String?
    @Published private(set) var isNamingLook = false
    @Published var name = ""

    var isBusy: Bool { operation != .idle }
    var canSave: Bool { loadState == .loaded && !isBusy && SavedLook.isValidName(name) }

    private let interactor: any SavedLooksInteractorProtocol
    private let onApply: @MainActor (SavedLook) async throws -> Void
    private let onClose: @MainActor () -> Void

    init(
        draft: EditorDraft,
        interactor: any SavedLooksInteractorProtocol,
        onApply: @escaping @MainActor (SavedLook) async throws -> Void,
        onClose: @escaping @MainActor () -> Void
    ) {
        previewDraft = draft
        self.interactor = interactor
        self.onApply = onApply
        self.onClose = onClose
    }

    func load() async {
        guard loadState != .loading, !isBusy else { return }
        loadState = .loading
        errorMessage = nil
        do {
            let result = try await interactor.loadLooks()
            try Task.checkCancellation()
            looks = result
            loadState = .loaded
        } catch is CancellationError {
            loadState = .idle
        } catch {
            loadState = .failed
            errorMessage = "Your looks couldn’t be loaded. Please try again."
        }
    }

    func beginNaming() {
        guard loadState == .loaded, !isBusy else { return }
        name = ""
        errorMessage = nil
        isNamingLook = true
    }

    func close() {
        guard !isBusy else { return }
        errorMessage = nil
        if isNamingLook { isNamingLook = false } else { onClose() }
    }

    func save() async {
        guard canSave else { return }
        operation = .saving
        errorMessage = nil
        defer { operation = .idle }
        do {
            looks = try await interactor.saveLook(named: name, draft: previewDraft)
            isNamingLook = false
        } catch {
            errorMessage = "Your look couldn’t be saved. Please try again."
        }
    }

    func apply(_ look: SavedLook) async {
        guard loadState == .loaded, !isBusy else { return }
        operation = .applying
        errorMessage = nil
        defer { operation = .idle }
        do {
            try await onApply(look)
            onClose()
        } catch is CancellationError {
            return
        } catch SavedLookApplicationError.unavailableFilter {
            errorMessage = "This look’s filter is unavailable."
        } catch {
            errorMessage = "This look couldn’t be applied. Please try again."
        }
    }
}
