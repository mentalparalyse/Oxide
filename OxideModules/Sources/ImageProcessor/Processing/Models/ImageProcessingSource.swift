import Foundation

public struct ImageEditRecipe: Equatable, Sendable {
    public let presetID: String?
    public let filterIntensity: Double
    public let rotationDegrees: Int
    public let crop: ImageEditCrop?
    public let adjustments: ImageAdjustments

    public init(
        presetID: String? = nil,
        filterIntensity: Double = 1,
        rotationDegrees: Int = 0,
        crop: ImageEditCrop? = nil,
        adjustments: ImageAdjustments = .neutral
    ) {
        self.presetID = presetID
        self.filterIntensity = filterIntensity
        self.rotationDegrees = rotationDegrees
        self.crop = crop
        self.adjustments = adjustments
    }
}

public protocol ImageProcessingSource: Sendable {
    var imageSourceURL: URL { get }
    var imageEditRecipe: ImageEditRecipe { get }
}
