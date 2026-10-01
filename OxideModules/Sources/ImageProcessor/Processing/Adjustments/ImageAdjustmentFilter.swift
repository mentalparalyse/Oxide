// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import CoreImage

enum ImageAdjustmentFilter {
    static func apply(
        to image: CIImage,
        adjustments: ImageAdjustments
    ) -> CIImage {
        var output = image

        if adjustments.isAutoEnhanced {
            let filters = output.autoAdjustmentFilters(options: [
                .enhance: true,
                .redEye: false,
                .crop: false,
                .level: false
            ])
            for filter in filters {
                filter.setValue(output, forKey: kCIInputImageKey)
                if let filteredImage = filter.outputImage {
                    output = filteredImage
                }
            }
        }

        if adjustments.exposure != 0 {
            output = output.applyingFilter(
                "CIExposureAdjust",
                parameters: [
                    kCIInputEVKey: adjustments.exposure
                ]
            )
        }

        output = applyTonalAdjustments(to: output, adjustments: adjustments)

        if adjustments.temperature != 0 || adjustments.tint != 0 {
            output = output.applyingFilter(
                "CITemperatureAndTint",
                parameters: [
                    "inputNeutral": CIVector(x: 6_500, y: 0),
                    "inputTargetNeutral": CIVector(
                        x: 6_500 - adjustments.temperature * 2_000,
                        y: adjustments.tint * 100
                    )
                ]
            )
        }

        if
            adjustments.contrast != 1 ||
            adjustments.saturation != 1 ||
            adjustments.brightness != 0
        {
            output = output.applyingFilter(
                "CIColorControls",
                parameters: [
                    kCIInputContrastKey: adjustments.contrast,
                    kCIInputSaturationKey: adjustments.saturation,
                    kCIInputBrightnessKey: adjustments.brightness
                ]
            )
        }

        if adjustments.vibrance != 0 {
            output = output.applyingFilter(
                "CIVibrance",
                parameters: ["inputAmount": adjustments.vibrance]
            )
        }

        if adjustments.sharpness > 0 {
            output = output.applyingFilter(
                "CISharpenLuminance",
                parameters: [kCIInputSharpnessKey: adjustments.sharpness * 2]
            )
        }

        if adjustments.isMonochrome {
            output = output.applyingFilter("CIPhotoEffectMono")
        }

        return output
    }

    private static func applyTonalAdjustments(
        to image: CIImage,
        adjustments: ImageAdjustments
    ) -> CIImage {
        guard adjustments.highlights != 0 ||
                adjustments.shadows != 0 ||
                adjustments.whites != 0 ||
                adjustments.blacks != 0 else {
            return image
        }

        // Build one smooth cubic tone curve. Each control is weighted toward
        // its named tonal region while remaining zero at unrelated endpoints.
        let black = adjustments.blacks * 0.12
        let white = adjustments.whites * 0.12
        let shadow = adjustments.shadows * 0.35
        let highlight = adjustments.highlights * 0.35
        let coefficients = CIVector(
            x: black,
            y: 1 - 3 * black + shadow,
            z: 3 * black - 2 * shadow + highlight,
            w: -black + white + shadow - highlight
        )

        return image.applyingFilter(
            "CIColorPolynomial",
            parameters: [
                "inputRedCoefficients": coefficients,
                "inputGreenCoefficients": coefficients,
                "inputBlueCoefficients": coefficients,
                "inputAlphaCoefficients": CIVector(x: 0, y: 1, z: 0, w: 0)
            ]
        )
    }
}
