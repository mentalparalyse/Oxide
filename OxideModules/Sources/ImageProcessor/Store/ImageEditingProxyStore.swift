import Foundation
import ImageIO

public actor ImageEditingProxyStore {
    public static let maximumPixelSize = 4_032

    private let fileManager: FileManager
    private let rootDirectory: URL?
    private let maxPixelSize: Int

    public init(
        rootDirectory: URL? = nil,
        fileManager: FileManager = .default,
        maxPixelSize: Int = maximumPixelSize
    ) {
        self.rootDirectory = rootDirectory
        self.fileManager = fileManager
        self.maxPixelSize = max(1, maxPixelSize)
    }

    public func proxyURL(for sourceURL: URL, id: String) throws -> URL {
        guard sourceURL.isFileURL else { return sourceURL }

        let directory = try proxyDirectory()
        let proxyURL = directory
            .appendingPathComponent("\(id)-editing-proxy")
            .appendingPathExtension("jpg")
        if fileManager.fileExists(atPath: proxyURL.path) {
            return proxyURL
        }

        guard
            let source = CGImageSourceCreateWithURL(
                sourceURL as CFURL,
                [kCGImageSourceShouldCache: false] as CFDictionary
            ),
            let proxy = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
                kCGImageSourceShouldCacheImmediately: true
            ] as CFDictionary),
            let data = ImageJPEGEncoder.encode(proxy, compressionQuality: 0.95)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }

        try data.write(to: proxyURL, options: .atomic)
        return proxyURL
    }

    private func proxyDirectory() throws -> URL {
        let directory = try rootDirectory ?? fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent("OxideEditingProxies", isDirectory: true)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
