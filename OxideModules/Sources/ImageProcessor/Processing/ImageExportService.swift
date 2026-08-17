import Foundation
import UIKit

public enum ImageExportError: Error {
    case renderingFailed
    case encodingFailed
}

public protocol ImageExporting: Sendable {
    func exportJPEG(
        from source: any ImageProcessingSource,
        filename: String,
        compressionQuality: CGFloat
    ) async throws -> URL
}

public extension ImageExporting {
    func exportJPEG(
        from source: any ImageProcessingSource,
        filename: String = UUID().uuidString
    ) async throws -> URL {
        try await exportJPEG(
            from: source,
            filename: filename,
            compressionQuality: 0.95
        )
    }
}

public final class ImageExportService: ImageExporting, @unchecked Sendable {
    private let imageProcessor: ImageProcessor
    private let outputDirectory: URL

    public init(
        imageProcessor: ImageProcessor = ImageProcessor(),
        outputDirectory: URL = FileManager.default.temporaryDirectory
    ) {
        self.imageProcessor = imageProcessor
        self.outputDirectory = outputDirectory
    }

    public func exportJPEG(
        from source: any ImageProcessingSource,
        filename: String,
        compressionQuality: CGFloat
    ) async throws -> URL {
        let recipe = source.imageEditRecipe
        guard let image = await imageProcessor.renderUIImage(
            from: source.imageSourceURL,
            presetID: recipe.presetID,
            intensity: recipe.filterIntensity,
            rotationDegrees: recipe.rotationDegrees,
            crop: recipe.crop,
            adjustments: recipe.adjustments
        ) else {
            throw ImageExportError.renderingFailed
        }
        guard let data = image.jpegData(compressionQuality: compressionQuality) else {
            throw ImageExportError.encodingFailed
        }
        try FileManager.default.createDirectory(
            at: outputDirectory,
            withIntermediateDirectories: true
        )
        let url = outputDirectory.appendingPathComponent(filename).appendingPathExtension("jpg")
        try data.write(to: url, options: .atomic)
        return url
    }
}
