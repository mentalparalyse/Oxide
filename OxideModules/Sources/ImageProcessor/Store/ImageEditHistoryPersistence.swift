import Foundation

public struct ImageEditHistoryState<Snapshot: Sendable>: Sendable {
    public let currentSnapshot: Snapshot?
    public let canUndo: Bool

    public init(currentSnapshot: Snapshot?, canUndo: Bool) {
        self.currentSnapshot = currentSnapshot
        self.canUndo = canUndo
    }
}

public actor ImageEditHistoryPersistence<Snapshot: Codable & Sendable> {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let fileManager: FileManager
    private let rootDirectory: URL
    private var stepURLs: [URL] = []
    private var currentIndex = -1

    public init(
        rootDirectory: URL = FileManager.default.temporaryDirectory,
        fileManager: FileManager = .default,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.rootDirectory = rootDirectory
        self.fileManager = fileManager
        self.encoder = encoder
        self.decoder = decoder
    }

    public var canUndo: Bool { currentIndex > 0 }

    public func resetHistory(for identifier: String) {
        removeHistoryDirectory(for: identifier)
        currentIndex = -1
        try? fileManager.createDirectory(
            at: historyDirectory(for: identifier),
            withIntermediateDirectories: true
        )
    }

    public func record(
        _ snapshot: Snapshot,
        identifier: String
    ) -> ImageEditHistoryState<Snapshot> {
        if currentIndex < stepURLs.count - 1 {
            stepURLs[(currentIndex + 1)...].forEach { try? fileManager.removeItem(at: $0) }
            stepURLs.removeSubrange((currentIndex + 1)..<stepURLs.count)
        }

        let url = historyDirectory(for: identifier)
            .appendingPathComponent("\(stepURLs.count)")
            .appendingPathExtension("json")
        guard
            let data = try? encoder.encode(snapshot),
            (try? data.write(to: url, options: .atomic)) != nil
        else {
            return state(currentSnapshot: currentSnapshot())
        }

        stepURLs.append(url)
        currentIndex = stepURLs.count - 1
        return state(currentSnapshot: snapshot)
    }

    public func undo() -> ImageEditHistoryState<Snapshot> {
        guard currentIndex > 0 else {
            return state(currentSnapshot: currentSnapshot())
        }
        currentIndex -= 1
        return state(currentSnapshot: currentSnapshot())
    }

    private func state(currentSnapshot: Snapshot?) -> ImageEditHistoryState<Snapshot> {
        ImageEditHistoryState(currentSnapshot: currentSnapshot, canUndo: currentIndex > 0)
    }

    private func currentSnapshot() -> Snapshot? {
        guard stepURLs.indices.contains(currentIndex),
              let data = try? Data(contentsOf: stepURLs[currentIndex]) else { return nil }
        return try? decoder.decode(Snapshot.self, from: data)
    }

    private func removeHistoryDirectory(for identifier: String) {
        stepURLs.removeAll()
        try? fileManager.removeItem(at: historyDirectory(for: identifier))
    }

    private func historyDirectory(for identifier: String) -> URL {
        rootDirectory
            .appendingPathComponent("OxideEditHistory", isDirectory: true)
            .appendingPathComponent(identifier, isDirectory: true)
    }
}
