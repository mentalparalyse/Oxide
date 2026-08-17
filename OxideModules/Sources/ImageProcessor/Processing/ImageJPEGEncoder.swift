import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

enum ImageJPEGEncoder {
    static func encode(
        _ image: CGImage,
        compressionQuality: CGFloat
    ) -> Data? {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            return nil
        }

        CGImageDestinationAddImage(
            destination,
            image,
            [kCGImageDestinationLossyCompressionQuality: compressionQuality] as CFDictionary
        )
        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }

    static func normalize(
        _ data: Data,
        compressionQuality: CGFloat
    ) -> Data? {
        guard
            let source = CGImageSourceCreateWithData(data as CFData, nil),
            let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
            let width = properties[kCGImagePropertyPixelWidth] as? NSNumber,
            let height = properties[kCGImagePropertyPixelHeight] as? NSNumber,
            let image = CGImageSourceCreateThumbnailAtIndex(
                source,
                0,
                [
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceThumbnailMaxPixelSize: max(
                        width.doubleValue,
                        height.doubleValue
                    ),
                    kCGImageSourceShouldCacheImmediately: true
                ] as CFDictionary
            )
        else {
            return nil
        }

        return encode(image, compressionQuality: compressionQuality)
    }
}
