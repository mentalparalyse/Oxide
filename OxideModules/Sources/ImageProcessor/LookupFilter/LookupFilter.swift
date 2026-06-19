// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.


/// A custom Core Image filter that applies a color lookup table (LUT) transformation to the input image.
///
/// `LookupFilter` is a subclass of `CIFilter` which accepts an input image, an optional color lookup table image,
/// an optional intensity, and a filter name. The filter can be used to apply complex color grading or mapping
/// operations by converting a Hald LUT texture into Core Image color cube data.
///
/// - Note: This class does not expose its properties as standard `@objc dynamic` CIFilter properties,
///         so it should be used directly with its initializer.
///
/// - Parameters:
///   - inputImage: The input `CIImage` to which the lookup table will be applied.
///   - inputColorLookupTable: An optional `CIImage` representing the color lookup table (LUT).
///   - inputIntensity: An optional `NSNumber` specifying the intensity of the LUT effect (where supported).
///
/// - Important:
///   - `ImageProcessor` caches color cube data per preset and should be preferred for production rendering.
///
/// - Author: Lex Sava
/// - Since: 21.09.2025
import CoreImage
import Foundation

public final class LookupFilter: CIFilter {
    @objc dynamic public var inputImage: CIImage?
    @objc dynamic public var inputColorLookupTable: CIImage?
    @objc dynamic public var inputIntensity: NSNumber = 1.0

    private static let context = CIContext(
        options: [
            .workingColorSpace: CGColorSpace(name: CGColorSpace.sRGB) as Any,
            .outputColorSpace: CGColorSpace(name: CGColorSpace.sRGB) as Any,
            .cacheIntermediates: false
        ]
    )
    private let cacheLock = NSLock()
    private var cachedLookupImage: CIImage?
    private var cachedCubeData: Data?


    public override var inputKeys: [String] {
        [
            kCIInputImageKey,
            "inputColorLookupTable",
            "inputIntensity"
        ]
    }


    public override var outputImage: CIImage? {
        guard let inputImage = inputImage else {
            return nil
        }
        guard let inputColorLookupTable else {
            return inputImage
        }

        guard let cubeData = cubeData(for: inputColorLookupTable) else {
            return inputImage
        }
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return inputImage
        }

        let intensity = min(max(inputIntensity.doubleValue, 0), 1)
        let filteredImage = inputImage.applyingFilter(
            "CIColorCubeWithColorSpace",
            parameters: [
                "inputCubeDimension": LUTColorCubeFactory.dimension,
                "inputCubeData": cubeData,
                "inputColorSpace": colorSpace
            ]
        )

        guard intensity < 1 else {
            return filteredImage
        }

        let mask = CIImage(
            color: CIColor(red: intensity, green: intensity, blue: intensity, alpha: intensity)
        )
        .cropped(to: inputImage.extent)

        return filteredImage.applyingFilter(
            "CIBlendWithAlphaMask",
            parameters: [
                kCIInputBackgroundImageKey: inputImage,
                kCIInputMaskImageKey: mask
            ]
        )
    }

    private func cubeData(for lookupImage: CIImage) -> Data? {
        cacheLock.lock()
        if cachedLookupImage === lookupImage, let cachedCubeData {
            cacheLock.unlock()
            return cachedCubeData
        }
        cacheLock.unlock()

        guard let cubeData = LUTColorCubeFactory.makeCubeData(
            from: lookupImage,
            context: Self.context
        ) else {
            return nil
        }

        cacheLock.lock()
        cachedLookupImage = lookupImage
        cachedCubeData = cubeData
        cacheLock.unlock()
        return cubeData
    }
}

extension LookupFilter: @unchecked Sendable {}
