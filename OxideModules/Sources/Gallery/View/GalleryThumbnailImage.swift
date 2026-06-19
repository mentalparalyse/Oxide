// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import ImageIO
import SwiftUI
import UIKit

struct GalleryThumbnailImage: View {
    let url: URL
    let maxPixelSize: CGFloat

    @State private var image: UIImage?

    var body: some View {
        Group {
            if url.isFileURL {
                localImage
            } else {
                remoteImage
            }
        }
        .task(id: taskID) {
            guard url.isFileURL else { return }
            image = await GalleryThumbnailLoader.shared.image(
                at: url,
                maxPixelSize: maxPixelSize
            )
        }
    }

    @ViewBuilder
    private var localImage: some View {
        if let image {
            GeometryReader { proxy in
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
        } else {
            placeholder
        }
    }

    private var remoteImage: some View {
        GeometryReader { proxy in
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    placeholder
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private var placeholder: some View {
        Color.clear
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
    }

    private var taskID: String {
        "\(url.path)-\(Int(maxPixelSize))"
    }
}

private final class GalleryThumbnailLoader: @unchecked Sendable {
    static let shared = GalleryThumbnailLoader()

    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 80
        cache.totalCostLimit = 32 * 1_024 * 1_024
    }

    func image(at url: URL, maxPixelSize: CGFloat) async -> UIImage? {
        let key = "\(url.path)-\(Int(maxPixelSize))" as NSString
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }

        let image = await Task.detached(priority: .utility) {
            Self.downsampledImage(at: url, maxPixelSize: maxPixelSize)
        }.value

        if let image {
            let cost = Int(image.size.width * image.size.height * image.scale * image.scale * 4)
            cache.setObject(image, forKey: key, cost: cost)
        }
        return image
    }

    private static func downsampledImage(
        at url: URL,
        maxPixelSize: CGFloat
    ) -> UIImage? {
        guard
            FileManager.default.fileExists(atPath: url.path),
            let source = CGImageSourceCreateWithURL(url as CFURL, nil),
            let cgImage = CGImageSourceCreateThumbnailAtIndex(
                source,
                0,
                [
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceThumbnailMaxPixelSize: max(1, maxPixelSize),
                    kCGImageSourceShouldCacheImmediately: true
                ] as CFDictionary
            )
        else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
