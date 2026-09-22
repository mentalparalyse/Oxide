import Foundation

@MainActor
protocol SavedLooksInteractorProtocol {
    func loadLooks() async throws -> [SavedLook]
    func saveLook(named name: String, draft: EditorDraft) async throws -> [SavedLook]
}

@MainActor
struct SavedLooksInteractor: SavedLooksInteractorProtocol {
    let store: SavedLookStore

    func loadLooks() async throws -> [SavedLook] {
        try await store.load()
    }

    func saveLook(named name: String, draft: EditorDraft) async throws -> [SavedLook] {
        try await store.save(SavedLook(name: name, draft: draft))
    }
}
