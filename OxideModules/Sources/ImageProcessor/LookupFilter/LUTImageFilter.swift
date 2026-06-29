// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import CoreImage
import Foundation

enum LUTImageFilter {
    static func apply(
        to inputImage: CIImage,
        preset: LUTFilterPreset,
        cubeData: Data,
        intensity: Double?
    ) -> CIImage? {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return nil
        }

        let resolvedIntensity = min(max(intensity ?? preset.intensity, 0), 1)
        let filteredImage = inputImage.applyingFilter(
            "CIColorCubeWithColorSpace",
            parameters: [
                "inputCubeDimension": LUTColorCubeFactory.dimension,
                "inputCubeData": cubeData,
                "inputColorSpace": colorSpace
            ]
        )

        guard resolvedIntensity < 1 else {
            return filteredImage
        }

        let mask = CIImage(
            color: CIColor(
                red: resolvedIntensity,
                green: resolvedIntensity,
                blue: resolvedIntensity,
                alpha: resolvedIntensity
            )
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
}
