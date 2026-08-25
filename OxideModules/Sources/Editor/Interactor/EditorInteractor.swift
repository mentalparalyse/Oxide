import CoreGraphics
import Foundation
import ImageProcessor

@MainActor
protocol EditorInteractorProtocol {
    func beginHistory(for asset: EditorAsset) async
    func record(_ draft: EditorDraft) async -> EditorHistoryState
    func undo() async -> EditorHistoryState
    func sourceImageSize(for imageURL: URL) -> CGSize?
    func preloadFilterPreviews(filters: [GalleryFilter])
}

@MainActor
final class EditorInteractor: EditorInteractorProtocol {
    private let history = EditorHistoryStore()
    private let imageProcessor = ImageProcessor()

    func beginHistory(for asset: EditorAsset) async {
        await history.reset(for: asset.id)
        _ = await history.record(EditorDraft(asset: asset))
    }

    func record(_ draft: EditorDraft) async -> EditorHistoryState {
        await history.record(draft)
    }

    func undo() async -> EditorHistoryState {
        await history.undo()
    }

    func sourceImageSize(for imageURL: URL) -> CGSize? {
        imageProcessor.sourceSize(for: imageURL)
    }

    func preloadFilterPreviews(filters: [GalleryFilter]) {
        let previewFilters = Array(filters.filter { $0.lutResourceName != nil }.prefix(5))
        guard !previewFilters.isEmpty else { return }
        Task.detached(priority: .utility) { [imageProcessor] in
            await withTaskGroup(of: Void.self) { group in
                var iterator = previewFilters.makeIterator()
                for _ in 0..<2 {
                    guard let filter = iterator.next() else { break }
                    group.addTask { await imageProcessor.prepareLUT(presetID: filter.id) }
                }
                while await group.next() != nil {
                    guard let filter = iterator.next() else { continue }
                    group.addTask { await imageProcessor.prepareLUT(presetID: filter.id) }
                }
            }
        }
    }
}
