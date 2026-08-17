import Foundation

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
        let normalizedData = ImageJPEGEncoder.normalize(
            data,
            compressionQuality: 0.95
        ) ?? data
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
}
