import CoreGraphics
import Foundation
import ImageIO
import UIKit

/// Keeps editing renders off the full-resolution source while preserving enough
/// pixels for the requested crop. Full-resolution exports bypass this cache.
final class ImagePreviewSourceCache: @unchecked Sendable {
    static let shared = ImagePreviewSourceCache()

    private final class CachedImage {
        let image: CGImage

        init(_ image: CGImage) {
            self.image = image
        }
    }

    private let cache = NSCache<NSString, CachedImage>()
    private let notificationCenter: NotificationCenter
    private var memoryWarningObserver: NSObjectProtocol?

    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
        cache.totalCostLimit = 64 * 1_024 * 1_024
        memoryWarningObserver = notificationCenter.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.removeAllImages()
        }
    }

    deinit {
        if let memoryWarningObserver {
            notificationCenter.removeObserver(memoryWarningObserver)
        }
    }

    func image(at url: URL, maxPixelSize: CGFloat) -> CGImage? {
        let pixelSize = max(1, Int(ceil(maxPixelSize)))
        let key = "\(url.standardizedFileURL.path)|\(pixelSize)" as NSString
        if let cached = cache.object(forKey: key) {
            return cached.image
        }

        guard
            let source = CGImageSourceCreateWithURL(url as CFURL, [
                kCGImageSourceShouldCache: false
            ] as CFDictionary),
            let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: pixelSize,
                kCGImageSourceShouldCacheImmediately: true
            ] as CFDictionary)
        else {
            return nil
        }

        cache.setObject(
            CachedImage(image),
            forKey: key,
            cost: image.bytesPerRow * image.height
        )
        return image
    }

    func removeAllImages() {
        cache.removeAllObjects()
    }
}
