import Foundation
import ImageProcessor
import Testing
@testable import Editor

struct SavedLookStoreTests {
    @Test func looksRoundTripAcrossStoreInstancesWithoutPhotoGeometryOrIdentity() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = SavedLookStore(directory: directory)
        #expect(try await store.load().isEmpty)
        var draft = EditorDraft(asset: EditorAsset(
            id: "private-photo-id",
            imageURI: URL(fileURLWithPath: "/private/photo.jpg"),
            createdAt: Date(),
            filterID: "cinematic",
            filterIntensity: 0.72,
            rotationDegrees: 90,
            crop: ImageEditCrop(x: 0.1, y: 0.1, width: 0.8, height: 0.8),
            effects: ImageEffects(filmGrain: ImageFilmGrain(amount: 0.4))
        ))
        draft.adjustments.exposure = 0.7
        let first = SavedLook(name: "Film", draft: draft)
        _ = try await store.save(first)
        let second = SavedLook(name: "Film", draft: draft)
        _ = try await store.save(second)
        #expect(try await SavedLookStore(directory: directory).load() == [second, first])
        let data = try Data(contentsOf: directory.appendingPathComponent("looks.json"))
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let records = try #require(json["looks"] as? [[String: Any]])
        #expect(Set(records[0].keys) == ["id", "name", "filterID", "filterIntensity", "adjustments", "effects"])
    }

    @Test(arguments: ["broken json", "{\"version\":2,\"looks\":[]}"])
    func unreadableOrNewerLibraryIsNotOverwritten(contents: String) async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent("looks.json")
        let original = Data(contents.utf8)
        try original.write(to: url)
        let store = SavedLookStore(directory: directory)
        let draft = EditorDraft(asset: EditorAsset(id: "photo", imageURI: url, createdAt: Date()))
        await #expect(throws: (any Error).self) { try await store.save(SavedLook(name: "Film", draft: draft)) }
        #expect(try Data(contentsOf: url) == original)
    }

    @Test func failedWriteDoesNotReportSuccess() async throws {
        let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: file) }
        try Data().write(to: file)
        let store = SavedLookStore(directory: file)
        let draft = EditorDraft(asset: EditorAsset(id: "photo", imageURI: file, createdAt: Date()))
        await #expect(throws: (any Error).self) { try await store.save(SavedLook(name: "Film", draft: draft)) }
    }
}
