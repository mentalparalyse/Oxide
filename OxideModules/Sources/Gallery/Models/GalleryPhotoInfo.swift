// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import CoreGraphics
import Editor
import Foundation

public struct GalleryPhotoInfo: Equatable, Sendable {
    public let capturedAt: Date
    public let filterName: String?
    public let filterIntensity: Double?
    public let originalDimensions: GalleryPixelDimensions?
    public let editedDimensions: GalleryPixelDimensions?

    init(photo: GalleryPhoto, filter: GalleryFilter?, sourceSize: CGSize?) {
        capturedAt = photo.createdAt
        filterName = filter?.name
        filterIntensity = photo.filterID == nil ? nil : photo.filterIntensity
        originalDimensions = GalleryPhotoResolution.originalDimensions(from: sourceSize)
        editedDimensions = GalleryPhotoResolution.editedDimensions(
            from: sourceSize,
            crop: photo.crop,
            rotationDegrees: photo.rotationDegrees
        )
    }
}
