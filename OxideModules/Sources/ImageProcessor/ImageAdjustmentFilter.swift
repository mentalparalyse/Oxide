// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import CoreImage

enum ImageAdjustmentFilter {
    static func apply(
        to image: CIImage,
        adjustments: ImageAdjustments
    ) -> CIImage {
        var output = image

        if adjustments.exposure != 0 {
            output = output.applyingFilter(
                "CIExposureAdjust",
                parameters: [
                    kCIInputEVKey: adjustments.exposure
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

        if adjustments.isMonochrome {
            output = output.applyingFilter("CIPhotoEffectMono")
        }

        return output
    }
}
