// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import CoreGraphics
import Foundation

public struct ImageEditCrop: Equatable, Codable, Sendable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double
    
    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    public var normalizedRect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }
}

public struct ImageAdjustments: Equatable, Codable, Sendable {
    public var exposure: Double
    public var contrast: Double
    public var saturation: Double
    public var brightness: Double
    public var isMonochrome: Bool

    public init(
        exposure: Double = 0,
        contrast: Double = 1,
        saturation: Double = 1,
        brightness: Double = 0,
        isMonochrome: Bool = false
    ) {
        self.exposure = exposure
        self.contrast = contrast
        self.saturation = saturation
        self.brightness = brightness
        self.isMonochrome = isMonochrome
    }

    public static let neutral = ImageAdjustments()
}

public enum ImageAdjustmentKind: String, CaseIterable, Identifiable, Sendable {
    case exposure
    case contrast
    case saturation
    case brightness
    case monochrome

    public var id: String { rawValue }
}

public enum ImageEditCropEdge: Equatable, Sendable {
    case leading
    case trailing
    case top
    case bottom
}

public enum ImageEditRotation {
    public static func normalized(_ degrees: Int) -> Int {
        let value = degrees % 360
        return value >= 0 ? value : value + 360
    }
}

public enum ImageEditCropper {
    public static let minimumSide: Double = 0.08
    
    public static func centeredCrop(sourceSize: CGSize, aspectRatio: Double) -> ImageEditCrop? {
        guard sourceSize.width > 0, sourceSize.height > 0, aspectRatio > 0 else {
            return nil
        }
        
        let sourceAspectRatio = sourceSize.width / sourceSize.height
        if sourceAspectRatio > aspectRatio {
            let width = aspectRatio / sourceAspectRatio
            return ImageEditCrop(x: (1 - width) / 2, y: 0, width: width, height: 1)
        }
        
        let height = sourceAspectRatio / aspectRatio
        return ImageEditCrop(x: 0, y: (1 - height) / 2, width: 1, height: height)
    }
    
    public static func resized(
        _ crop: ImageEditCrop?,
        edge: ImageEditCropEdge,
        horizontalDelta: Double,
        verticalDelta: Double,
        minimumSide: Double = minimumSide
    ) -> ImageEditCrop {
        let crop = crop ?? ImageEditCrop(x: 0, y: 0, width: 1, height: 1)
        let minimumSide = min(max(minimumSide, 0.01), 1)
        let maxX = crop.x + crop.width
        let maxY = crop.y + crop.height
        
        switch edge {
        case .leading:
            let x = clamp(crop.x + horizontalDelta, min: 0, max: maxX - minimumSide)
            return ImageEditCrop(x: x, y: crop.y, width: maxX - x, height: crop.height)
        case .trailing:
            let newMaxX = clamp(maxX + horizontalDelta, min: crop.x + minimumSide, max: 1)
            return ImageEditCrop(x: crop.x, y: crop.y, width: newMaxX - crop.x, height: crop.height)
        case .top:
            let y = clamp(crop.y + verticalDelta, min: 0, max: maxY - minimumSide)
            return ImageEditCrop(x: crop.x, y: y, width: crop.width, height: maxY - y)
        case .bottom:
            let newMaxY = clamp(maxY + verticalDelta, min: crop.y + minimumSide, max: 1)
            return ImageEditCrop(x: crop.x, y: crop.y, width: crop.width, height: newMaxY - crop.y)
        }
    }
    
    private static func clamp(_ value: Double, min minimum: Double, max maximum: Double) -> Double {
        Swift.min(Swift.max(value, minimum), maximum)
    }
}
