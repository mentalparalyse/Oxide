// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import CoreImage
import Foundation

public enum LUTImageFactory {
    public static let dimension = 64
    public static let imageSize = 512

    public static func makeLookupImage(for preset: LUTFilterPreset) -> CIImage? {
        let pixelCount = imageSize * imageSize
        var pixels = [UInt8](repeating: 0, count: pixelCount * 4)

        for blueIndex in 0..<dimension {
            let tileX = blueIndex % 8
            let tileY = blueIndex / 8

            for greenIndex in 0..<dimension {
                for redIndex in 0..<dimension {
                    let x = tileX * dimension + redIndex
                    let y = tileY * dimension + greenIndex
                    let offset = (y * imageSize + x) * 4

                    let rgb = transformedColor(
                        red: Double(redIndex) / Double(dimension - 1),
                        green: Double(greenIndex) / Double(dimension - 1),
                        blue: Double(blueIndex) / Double(dimension - 1),
                        presetID: preset.id
                    )

                    pixels[offset] = UInt8(clamping: Int((rgb.red * 255).rounded()))
                    pixels[offset + 1] = UInt8(clamping: Int((rgb.green * 255).rounded()))
                    pixels[offset + 2] = UInt8(clamping: Int((rgb.blue * 255).rounded()))
                    pixels[offset + 3] = 255
                }
            }
        }

        return pixels.withUnsafeBufferPointer { buffer in
            guard let baseAddress = buffer.baseAddress else { return nil }
            let data = Data(bytes: baseAddress, count: buffer.count)
            return CIImage(
                bitmapData: data,
                bytesPerRow: imageSize * 4,
                size: CGSize(width: imageSize, height: imageSize),
                format: .RGBA8,
                colorSpace: CGColorSpace(name: CGColorSpace.sRGB)
            )
        }
    }

    private static func transformedColor(
        red: Double,
        green: Double,
        blue: Double,
        presetID: String
    ) -> (red: Double, green: Double, blue: Double) {
        switch presetID {
        case "cinematic":
            return grade(red: red * 0.92, green: green * 0.98, blue: min(1, blue * 1.08 + 0.02), contrast: 1.12, saturation: 1.08)
        case "vintage":
            return grade(red: min(1, red * 1.08 + 0.03), green: green * 0.98, blue: blue * 0.82, contrast: 0.95, saturation: 0.86)
        case "travel":
            return grade(red: red * 1.02, green: min(1, green * 1.08 + 0.02), blue: min(1, blue * 1.06), contrast: 1.08, saturation: 1.18)
        case "portrait":
            return grade(red: min(1, red * 1.04 + 0.02), green: min(1, green * 1.02), blue: blue * 0.96, contrast: 1.02, saturation: 0.96)
        case "film":
            return grade(red: min(1, pow(red, 0.94)), green: pow(green, 0.98), blue: pow(blue, 1.06), contrast: 1.14, saturation: 0.92)
        case "blackwhite":
            let luma = red * 0.299 + green * 0.587 + blue * 0.114
            let value = clamp((luma - 0.5) * 1.18 + 0.5)
            return (value, value, value)
        default:
            return (red, green, blue)
        }
    }

    private static func grade(
        red: Double,
        green: Double,
        blue: Double,
        contrast: Double,
        saturation: Double
    ) -> (red: Double, green: Double, blue: Double) {
        let contrastedRed = (red - 0.5) * contrast + 0.5
        let contrastedGreen = (green - 0.5) * contrast + 0.5
        let contrastedBlue = (blue - 0.5) * contrast + 0.5
        let luma = contrastedRed * 0.299 + contrastedGreen * 0.587 + contrastedBlue * 0.114

        return (
            clamp(luma + (contrastedRed - luma) * saturation),
            clamp(luma + (contrastedGreen - luma) * saturation),
            clamp(luma + (contrastedBlue - luma) * saturation)
        )
    }

    private static func clamp(_ value: Double) -> Double {
        min(1, max(0, value))
    }
}
