import Foundation

public struct ImageEditRecipe: Equatable, Sendable {
    public let presetID: String?
    public let filterIntensity: Double
    public let rotationDegrees: Int
    public let crop: ImageEditCrop?
    public let adjustments: ImageAdjustments
    public let effects: ImageEffects

    public init(
        presetID: String? = nil,
        filterIntensity: Double = 1,
        rotationDegrees: Int = 0,
        crop: ImageEditCrop? = nil,
        adjustments: ImageAdjustments = .neutral,
        effects: ImageEffects = .neutral
    ) {
        self.presetID = presetID
        self.filterIntensity = filterIntensity
        self.rotationDegrees = rotationDegrees
        self.crop = crop
        self.adjustments = adjustments
        self.effects = effects
    }
}

public protocol ImageProcessingSource: Sendable {
    var imageSourceURL: URL { get }
    var imageEditRecipe: ImageEditRecipe { get }
}
