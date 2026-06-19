// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import CoreImage
import UIKit

@available(*, deprecated, message: "Use ImageProcessor for image editing.")
public final class LUTFilterRenderer: @unchecked Sendable {
    private let imageProcessor: ImageProcessor
    
    public init(imageProcessor: ImageProcessor = ImageProcessor()) {
        self.imageProcessor = imageProcessor
    }
    
    public func outputImage(
        for inputImage: CIImage,
        presetID: String?,
        intensity: Double? = nil
    ) -> CIImage? {
        imageProcessor.outputImage(
            for: inputImage,
            presetID: presetID,
            intensity: intensity
        )
    }
    
    public func renderUIImage(
        from imageURL: URL,
        presetID: String?,
        intensity: Double? = nil,
        rotationDegrees: Int = 0,
        cropRect: CGRect? = nil,
        adjustments: ImageAdjustments = .neutral,
        maxPixelSize: CGFloat? = nil
    ) async -> UIImage? {
        await imageProcessor.renderUIImage(
            from: imageURL,
            presetID: presetID,
            intensity: intensity,
            rotationDegrees: rotationDegrees,
            cropRect: cropRect,
            adjustments: adjustments,
            maxPixelSize: maxPixelSize
        )
    }
}
