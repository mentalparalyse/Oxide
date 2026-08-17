// Copyright (c) 2025 SoftFusion. All rights reserved.

import Foundation
import ImageProcessor

protocol GalleryImageExporting: Sendable {
    func exportFile(for photo: GalleryPhoto) async throws -> URL
    func saveToPhotoLibrary(_ fileURL: URL) async throws
}

final class GalleryImageExporter: GalleryImageExporting, @unchecked Sendable {
    private let exportService: any ImageExporting
    private let photoLibraryStore: PhotoLibraryStore

    init(
        exportService: any ImageExporting = ImageExportService(),
        photoLibraryStore: PhotoLibraryStore = PhotoLibraryStore()
    ) {
        self.exportService = exportService
        self.photoLibraryStore = photoLibraryStore
    }

    func exportFile(for photo: GalleryPhoto) async throws -> URL {
        try await exportService.exportJPEG(from: photo, filename: "Oxide-\(photo.id)")
    }

    func saveToPhotoLibrary(_ fileURL: URL) async throws {
        try await photoLibraryStore.saveImage(at: fileURL)
    }
}
