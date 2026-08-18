// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import CoreGraphics
import ImageProcessor

public struct GalleryPixelDimensions: Equatable, Sendable {
    public let width: Int
    public let height: Int

    public var formatted: String {
        "\(width) × \(height) px"
    }
}

enum GalleryPhotoResolution {
    static func originalDimensions(from sourceSize: CGSize?) -> GalleryPixelDimensions? {
        guard
            let sourceSize,
            sourceSize.width.isFinite,
            sourceSize.height.isFinite,
            sourceSize.width > 0,
            sourceSize.height > 0
        else {
            return nil
        }

        return GalleryPixelDimensions(
            width: Int(sourceSize.width.rounded()),
            height: Int(sourceSize.height.rounded())
        )
    }

    static func editedDimensions(
        from sourceSize: CGSize?,
        crop: ImageEditCrop?,
        rotationDegrees: Int
    ) -> GalleryPixelDimensions? {
        guard let original = originalDimensions(from: sourceSize) else { return nil }

        let cropWidth = clampedFraction(crop?.width ?? 1)
        let cropHeight = clampedFraction(crop?.height ?? 1)
        var width = max(1, Int((CGFloat(original.width) * cropWidth).rounded()))
        var height = max(1, Int((CGFloat(original.height) * cropHeight).rounded()))

        let normalizedRotation = ((rotationDegrees % 360) + 360) % 360
        if normalizedRotation == 90 || normalizedRotation == 270 {
            swap(&width, &height)
        }

        return GalleryPixelDimensions(width: width, height: height)
    }

    private static func clampedFraction(_ value: Double) -> CGFloat {
        CGFloat(min(max(value, 0), 1))
    }
}
