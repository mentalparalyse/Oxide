import Foundation
import UIKit

public actor ImageFileStore {
    private let fileManager: FileManager
    private let rootDirectory: URL?

    public init(
        rootDirectory: URL? = nil,
        fileManager: FileManager = .default
    ) {
        self.rootDirectory = rootDirectory
        self.fileManager = fileManager
    }

    public func writeImageData(_ data: Data, id: String) throws -> URL {
        let directory = try imageDirectory()
        let url = directory.appendingPathComponent(id).appendingPathExtension("jpg")
        let normalizedData = normalizedJPEGData(from: data) ?? data
        try normalizedData.write(to: url, options: .atomic)
        return url
    }

    public func imageDirectory() throws -> URL {
        let directory = try rootDirectory ?? Self.imageDirectory(fileManager: fileManager)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    public nonisolated static func imageDirectory(
        fileManager: FileManager = .default
    ) throws -> URL {
        try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("OxidePhotoLibrary", isDirectory: true)
    }

    private func normalizedJPEGData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
        .jpegData(compressionQuality: 0.95)
    }
}
