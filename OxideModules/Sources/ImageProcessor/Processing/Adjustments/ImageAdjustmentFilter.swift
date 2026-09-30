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
