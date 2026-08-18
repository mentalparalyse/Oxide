// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation
import ImageProcessor

public struct GalleryDraft: Equatable, Codable, Sendable {
    public let photo: GalleryPhoto
    public var selectedFilterID: String
    public var filterIntensity: Double
    public var rotationDegrees: Int
    public var crop: ImageEditCrop?
    public var cropAspectRatio: Double?
    public var adjustments: ImageAdjustments
    public var effects: ImageEffects
    
    public init(photo: GalleryPhoto) {
        self.photo = photo
        self.selectedFilterID = photo.filterID ?? GalleryFilter.original.id
        self.filterIntensity = photo.filterIntensity
        self.rotationDegrees = photo.rotationDegrees
        self.crop = photo.crop
        self.cropAspectRatio = nil
        self.adjustments = photo.adjustments
        self.effects = photo.effects
    }
    
    public func committed() -> GalleryPhoto {
        var updatedPhoto = photo
        updatedPhoto.filterID = selectedFilterID == GalleryFilter.original.id ? nil : selectedFilterID
        updatedPhoto.filterIntensity = selectedFilterID == GalleryFilter.original.id ? 1.0 : filterIntensity
        updatedPhoto.rotationDegrees = ImageEditRotation.normalized(rotationDegrees)
        updatedPhoto.crop = crop
        updatedPhoto.adjustments = adjustments
        updatedPhoto.effects = effects
        return updatedPhoto
    }
}

public typealias GalleryFilter = LUTFilterPreset
