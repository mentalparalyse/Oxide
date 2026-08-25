import ImageProcessor

public struct EditorDraft: Equatable, Codable, Sendable {
    public let asset: EditorAsset
    public var selectedFilterID: String
    public var filterIntensity: Double
    public var rotationDegrees: Int
    public var crop: ImageEditCrop?
    public var cropAspectRatio: Double?
    public var adjustments: ImageAdjustments
    public var effects: ImageEffects

    public init(asset: EditorAsset) {
        self.asset = asset
        selectedFilterID = asset.filterID ?? GalleryFilter.original.id
        filterIntensity = asset.filterIntensity
        rotationDegrees = asset.rotationDegrees
        crop = asset.crop
        cropAspectRatio = nil
        adjustments = asset.adjustments
        effects = asset.effects
    }

    public func committed() -> EditorAsset {
        var result = asset
        result.filterID = selectedFilterID == GalleryFilter.original.id ? nil : selectedFilterID
        result.filterIntensity = selectedFilterID == GalleryFilter.original.id ? 1 : filterIntensity
        result.rotationDegrees = ImageEditRotation.normalized(rotationDegrees)
        result.crop = crop
        result.adjustments = adjustments
        result.effects = effects
        return result
    }
}
