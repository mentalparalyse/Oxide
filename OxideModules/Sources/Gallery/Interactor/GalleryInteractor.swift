// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation
import ImageProcessor

@MainActor
protocol GalleryInteractorProtocol {
    func loadPhotos() -> [GalleryPhoto]
    func save(_ photo: GalleryPhoto) -> [GalleryPhoto]
    func delete(photoID: GalleryPhoto.ID) -> [GalleryPhoto]
    func storeImportedImage(data: Data, id: String) async throws -> URL
    func beginEditHistory(for photo: GalleryPhoto)
    func recordEditStep(_ draft: GalleryDraft) -> GalleryEditHistoryState
    func undoEditStep() -> GalleryEditHistoryState
    func preloadFilterPreviews(for imageURL: URL, filters: [GalleryFilter])
    func sourceImageSize(for imageURL: URL) -> CGSize?
}

@MainActor
final class GalleryInteractor: GalleryInteractorProtocol {
    private var photos: [GalleryPhoto]
    private let editHistory = GalleryEditHistoryStore()
    private let imagePersistence = ImageProcessPersistence<ImageProcessEmptySnapshot>()
    private let imageProcessor = ImageProcessor()
    private let persistsChanges: Bool
    
    init(
        photos: [GalleryPhoto]? = nil,
        persistsChanges: Bool = true
    ) {
        self.photos = (photos ?? GalleryPhotoLibraryStore.loadPhotos()).sortedByNewest()
        self.persistsChanges = persistsChanges
    }
    
    func loadPhotos() -> [GalleryPhoto] {
        photos
    }
    
    func save(_ photo: GalleryPhoto) -> [GalleryPhoto] {
        if let existingIndex = photos.firstIndex(where: { $0.id == photo.id }) {
            photos[existingIndex] = photo
        } else {
            photos.append(photo)
        }
        
        photos = photos.sortedByNewest()
        if persistsChanges {
            try? GalleryPhotoLibraryStore.savePhotos(photos)
        }
        return photos
    }
    
    func delete(photoID: GalleryPhoto.ID) -> [GalleryPhoto] {
        photos.removeAll { $0.id == photoID }
        if persistsChanges {
            try? GalleryPhotoLibraryStore.savePhotos(photos)
        }
        return photos
    }
    
    func storeImportedImage(data: Data, id: String) async throws -> URL {
        try await Task.detached(priority: .userInitiated) { [imagePersistence] in
            try imagePersistence.writeImageData(data, id: id)
        }.value
    }
    
    func beginEditHistory(for photo: GalleryPhoto) {
        editHistory.reset(for: photo.id)
        _ = editHistory.record(GalleryDraft(photo: photo))
    }
    
    func recordEditStep(_ draft: GalleryDraft) -> GalleryEditHistoryState {
        editHistory.record(draft)
    }
    
    func undoEditStep() -> GalleryEditHistoryState {
        editHistory.undo()
    }
    
    func preloadFilterPreviews(for _: URL, filters: [GalleryFilter]) {
        let previewFilters = Array(filters.prefix(5))
        Task.detached(priority: .utility) { [imageProcessor] in
            await withTaskGroup(of: Void.self) { group in
                var iterator = previewFilters.makeIterator()

                for _ in 0..<2 {
                    guard let filter = iterator.next() else { break }
                    group.addTask {
                        await imageProcessor.prepareLUT(presetID: filter.id)
                    }
                }

                while await group.next() != nil {
                    guard let filter = iterator.next() else { continue }
                    group.addTask {
                        await imageProcessor.prepareLUT(presetID: filter.id)
                    }
                }
            }
        }
    }
    
    func sourceImageSize(for imageURL: URL) -> CGSize? {
        imageProcessor.sourceSize(for: imageURL)
    }
}
