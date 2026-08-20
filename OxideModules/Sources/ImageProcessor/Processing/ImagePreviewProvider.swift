import Foundation
import UIKit

@MainActor
public final class ImagePreviewProvider {
    public static let shared = ImagePreviewProvider()

    private let processor: ImageProcessor
    private let cache = NSCache<NSString, UIImage>()

    public init(processor: ImageProcessor = ImageProcessor()) {
        self.processor = processor
        cache.countLimit = 80
        cache.totalCostLimit = 32 * 1_024 * 1_024
    }

    public func preview(
        from source: any ImageProcessingSource,
        maxPixelSize: CGFloat
    ) async -> UIImage? {
        let maxPixelSize = max(1, maxPixelSize)
        let key = Self.cacheKey(for: source, maxPixelSize: maxPixelSize) as NSString
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }

        let recipe = source.imageEditRecipe
        guard let image = await processor.renderUIImage(
            from: source.imageSourceURL,
            presetID: recipe.presetID,
            intensity: recipe.filterIntensity,
            rotationDegrees: recipe.rotationDegrees,
            crop: recipe.crop,
            adjustments: recipe.adjustments,
            effects: recipe.effects,
            maxPixelSize: maxPixelSize
        ), !Task.isCancelled else {
            return nil
        }

        let cost = Int(image.size.width * image.size.height * image.scale * image.scale * 4)
        cache.setObject(image, forKey: key, cost: cost)
        return image
    }

    public func removeAllCachedPreviews() {
        cache.removeAllObjects()
    }

    private static func cacheKey(
        for source: any ImageProcessingSource,
        maxPixelSize: CGFloat
    ) -> String {
        let recipe = source.imageEditRecipe
        let crop = recipe.crop
        let adjustments = recipe.adjustments
        return [
            source.imageSourceURL.absoluteString,
            String(Int(maxPixelSize)),
            recipe.presetID ?? "original",
            String(recipe.filterIntensity),
            String(ImageEditRotation.normalized(recipe.rotationDegrees)),
            crop.map { "\($0.x),\($0.y),\($0.width),\($0.height)" } ?? "no-crop",
            "\(adjustments.exposure),\(adjustments.contrast),\(adjustments.saturation)",
            "\(adjustments.brightness),\(adjustments.isMonochrome)",
            "effects:\(String(describing: recipe.effects))"
        ].joined(separator: "|")
    }
}
