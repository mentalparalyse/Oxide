// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation
import ImageProcessor

enum GalleryPhotoLibraryStore {
    private static let imagePersistence = ImageProcessPersistence<ImageProcessEmptySnapshot>()
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()
    
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    static func loadPhotos() -> [GalleryPhoto] {
        guard
            let data = try? Data(contentsOf: libraryURL()),
            let photos = try? decoder.decode([GalleryPhoto].self, from: data)
        else {
            return []
        }
        
        return photos.sortedByNewest()
    }
    
    static func savePhotos(_ photos: [GalleryPhoto]) throws {
        let data = try encoder.encode(photos.sortedByNewest())
        try data.write(to: libraryURL(), options: [.atomic])
    }
    
    private static func libraryURL() -> URL {
        let directory = try? imagePersistence.imageDirectory()
        return (directory ?? FileManager.default.temporaryDirectory)
            .appendingPathComponent("library")
            .appendingPathExtension("json")
    }
}

extension Array where Element == GalleryPhoto {
    func sortedByNewest() -> [GalleryPhoto] {
        sorted { $0.createdAt > $1.createdAt }
    }
}
