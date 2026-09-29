import Foundation
import ImageProcessor

public struct EditorAsset: Identifiable, Equatable, Codable, Sendable {
    public let id: String
    public let imageURI: URL
    public let editingImageURI: URL?
    public let createdAt: Date
    public var filterID: String?
    public var filterIntensity: Double
    public var rotationDegrees: Int
    public var crop: ImageEditCrop?
    public var adjustments: ImageAdjustments
    public var effects: ImageEffects

    public init(
        id: String,
        imageURI: URL,
        editingImageURI: URL? = nil,
        createdAt: Date,
        filterID: String? = nil,
        filterIntensity: Double = 1,
        rotationDegrees: Int = 0,
        crop: ImageEditCrop? = nil,
        adjustments: ImageAdjustments = .neutral,
        effects: ImageEffects = .neutral
    ) {
        self.id = id
        self.imageURI = imageURI
        self.editingImageURI = editingImageURI
        self.createdAt = createdAt
        self.filterID = filterID
        self.filterIntensity = filterIntensity
        self.rotationDegrees = rotationDegrees
        self.crop = crop
        self.adjustments = adjustments
        self.effects = effects
    }

    public var editorSourceURI: URL {
        guard let editingImageURI else { return imageURI }
        guard editingImageURI.isFileURL else { return editingImageURI }
        return FileManager.default.fileExists(atPath: editingImageURI.path)
            ? editingImageURI
            : imageURI
    }
}

public typealias GalleryFilter = LUTFilterPreset
