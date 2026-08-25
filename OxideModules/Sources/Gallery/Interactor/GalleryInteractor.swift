// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation
import ImageProcessor

@MainActor
protocol GalleryInteractorProtocol {
    func loadPhotos() -> [GalleryPhoto]
    func save(_ photo: GalleryPhoto) -> [GalleryPhoto]
    func delete(photoID: GalleryPhoto.ID) -> [GalleryPhoto]
    func storeImportedImage(data: Data, id: String) async throws -> URL
    func sourceImageSize(for imageURL: URL) -> CGSize?
}

@MainActor
final class GalleryInteractor: GalleryInteractorProtocol {
    private var photos: [GalleryPhoto]
    private let imageFileStore = ImageFileStore()
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
        try await imageFileStore.writeImageData(data, id: id)
    }

    func sourceImageSize(for imageURL: URL) -> CGSize? {
        imageProcessor.sourceSize(for: imageURL)
    }
}
