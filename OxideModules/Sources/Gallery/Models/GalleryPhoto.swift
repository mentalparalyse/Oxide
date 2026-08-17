// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation
import ImageProcessor

public struct GalleryPhoto: Identifiable, Equatable, Codable, Sendable {
    public let id: String
    public let imageURI: URL
    public let createdAt: Date
    public var filterID: String?
    public var filterIntensity: Double
    public var rotationDegrees: Int
    public var crop: ImageEditCrop?
    public var adjustments: ImageAdjustments

    public init(
        id: String,
        imageURI: URL,
        createdAt: Date,
        filterID: String? = nil,
        filterIntensity: Double = 1.0,
        rotationDegrees: Int = 0,
        crop: ImageEditCrop? = nil,
        adjustments: ImageAdjustments = .neutral
    ) {
        self.id = id
        self.imageURI = imageURI
        self.createdAt = createdAt
        self.filterID = filterID
        self.filterIntensity = filterIntensity
        self.rotationDegrees = rotationDegrees
        self.crop = crop
        self.adjustments = adjustments
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case imageURI
        case createdAt
        case filterID
        case filterIntensity
        case rotationDegrees
        case crop
        case adjustments
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        let persistedPath = try container.decode(String.self, forKey: .imageURI)
        imageURI = GalleryPhotoURLResolver.resolve(persistedPath)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        filterID = try container.decodeIfPresent(String.self, forKey: .filterID)
        filterIntensity = try container.decodeIfPresent(Double.self, forKey: .filterIntensity) ?? 1
        rotationDegrees = try container.decodeIfPresent(Int.self, forKey: .rotationDegrees) ?? 0
        crop = try container.decodeIfPresent(ImageEditCrop.self, forKey: .crop)
        adjustments = try container.decodeIfPresent(ImageAdjustments.self, forKey: .adjustments) ?? .neutral
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(GalleryPhotoURLResolver.persistedPath(for: imageURI), forKey: .imageURI)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(filterID, forKey: .filterID)
        try container.encode(filterIntensity, forKey: .filterIntensity)
        try container.encode(rotationDegrees, forKey: .rotationDegrees)
        try container.encodeIfPresent(crop, forKey: .crop)
        try container.encode(adjustments, forKey: .adjustments)
    }
}

extension GalleryPhoto: ImageProcessingSource {
    public var imageSourceURL: URL { imageURI }

    public var imageEditRecipe: ImageEditRecipe {
        ImageEditRecipe(
            presetID: filterID,
            filterIntensity: filterIntensity,
            rotationDegrees: rotationDegrees,
            crop: crop,
            adjustments: adjustments
        )
    }
}

enum GalleryPhotoURLResolver {
    static func persistedPath(for url: URL) -> String {
        url.isFileURL ? url.lastPathComponent : url.absoluteString
    }

    static func resolve(
        _ persistedPath: String,
        fileManager: FileManager = .default
    ) -> URL {
        guard
            let persistedURL = URL(string: persistedPath),
            persistedURL.scheme != nil
        else {
            return photoLibraryDirectory(fileManager: fileManager)
                .appendingPathComponent((persistedPath as NSString).lastPathComponent)
        }

        guard persistedURL.isFileURL else {
            return persistedURL
        }

        return photoLibraryDirectory(fileManager: fileManager)
            .appendingPathComponent(persistedURL.lastPathComponent)
    }

    static func photoLibraryDirectory(fileManager: FileManager = .default) -> URL {
        let applicationSupport = (
            try? fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
        ) ?? fileManager.temporaryDirectory

        return applicationSupport
            .appendingPathComponent("OxidePhotoLibrary", isDirectory: true)
    }
}
