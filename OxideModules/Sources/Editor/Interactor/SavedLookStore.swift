import Foundation

actor SavedLookStore {
    static let shared = SavedLookStore()

    private struct Library: Codable {
        var version = 1
        var looks: [SavedLook]
    }

    enum StoreError: Error {
        case unsupportedVersion
        case invalidName
    }

    private let directory: URL?

    init(directory: URL? = nil) {
        self.directory = directory
    }

    func load() throws -> [SavedLook] {
        let url = try libraryURL()
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch CocoaError.fileReadNoSuchFile {
            return []
        }
        let library = try JSONDecoder().decode(Library.self, from: data)
        guard library.version == 1 else { throw StoreError.unsupportedVersion }
        return library.looks
    }

    func save(_ look: SavedLook) throws -> [SavedLook] {
        guard SavedLook.isValidName(look.name) else {
            throw StoreError.invalidName
        }
        // Read before writing: unreadable or newer data must never be replaced.
        var looks = try load()
        looks.insert(look, at: 0)
        let data = try JSONEncoder().encode(Library(looks: looks))
        let url = try libraryURL()
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
        return looks
    }

    private func libraryURL() throws -> URL {
        let root = try directory ?? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("OxideLooks", isDirectory: true)
        return root.appendingPathComponent("looks.json")
    }
}
