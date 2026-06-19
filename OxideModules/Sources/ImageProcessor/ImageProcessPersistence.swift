// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation
import UIKit

public struct ImageProcessHistoryState<Snapshot: Sendable>: Sendable {
    public let currentSnapshot: Snapshot?
    public let canUndo: Bool
    
    public init(currentSnapshot: Snapshot?, canUndo: Bool) {
        self.currentSnapshot = currentSnapshot
        self.canUndo = canUndo
    }
}

public struct ImageProcessEmptySnapshot: Codable, Sendable {
    public init() { }
}

public final class ImageProcessPersistence<Snapshot: Codable & Sendable>: @unchecked Sendable {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let fileManager: FileManager
    private let rootDirectory: URL
    private let lock = NSLock()
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
    
    public var canUndo: Bool {
        lock.withLock {
            currentIndex > 0
        }
    }
    
    public func resetHistory(for identifier: String) {
        lock.withLock {
            removeHistoryDirectory(for: identifier)
            currentIndex = -1
            try? fileManager.createDirectory(
                at: historyDirectory(for: identifier),
                withIntermediateDirectories: true
            )
        }
    }
    
    public func record(_ snapshot: Snapshot, identifier: String) -> ImageProcessHistoryState<Snapshot> {
        lock.withLock {
            if currentIndex < stepURLs.count - 1 {
                stepURLs[(currentIndex + 1)...].forEach { try? fileManager.removeItem(at: $0) }
                stepURLs.removeSubrange((currentIndex + 1)..<stepURLs.count)
            }
            
            let url = historyDirectory(for: identifier)
                .appendingPathComponent("\(stepURLs.count)")
                .appendingPathExtension("json")
            
            guard
                let data = try? encoder.encode(snapshot),
                (try? data.write(to: url, options: [.atomic])) != nil
            else {
                return ImageProcessHistoryState(currentSnapshot: currentSnapshot(), canUndo: currentIndex > 0)
            }
            
            stepURLs.append(url)
            currentIndex = stepURLs.count - 1
            return ImageProcessHistoryState(currentSnapshot: snapshot, canUndo: currentIndex > 0)
        }
    }
    
    public func undo() -> ImageProcessHistoryState<Snapshot> {
        lock.withLock {
            guard currentIndex > 0 else {
                return ImageProcessHistoryState(currentSnapshot: currentSnapshot(), canUndo: currentIndex > 0)
            }
            
            currentIndex -= 1
            return ImageProcessHistoryState(currentSnapshot: currentSnapshot(), canUndo: currentIndex > 0)
        }
    }
    
    public func writeImageData(_ data: Data, id: String) throws -> URL {
        let directory = try imageDirectory()
        let url = directory.appendingPathComponent(id).appendingPathExtension("jpg")
        let normalizedData = normalizedJPEGData(from: data) ?? data
        try normalizedData.write(to: url, options: [.atomic])
        return url
    }
    
    public func imageDirectory() throws -> URL {
        let directory = try applicationSupportDirectory()
            .appendingPathComponent("OxidePhotoLibrary", isDirectory: true)
        
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
    
    private func currentSnapshot() -> Snapshot? {
        guard stepURLs.indices.contains(currentIndex) else { return nil }
        guard let data = try? Data(contentsOf: stepURLs[currentIndex]) else { return nil }
        return try? decoder.decode(Snapshot.self, from: data)
    }
    
    private func removeHistoryDirectory(for identifier: String) {
        stepURLs.forEach { try? fileManager.removeItem(at: $0) }
        stepURLs.removeAll()
        try? fileManager.removeItem(at: historyDirectory(for: identifier))
    }
    
    private func historyDirectory(for identifier: String) -> URL {
        rootDirectory
            .appendingPathComponent("OxideEditHistory", isDirectory: true)
            .appendingPathComponent(identifier, isDirectory: true)
    }
    
    private func applicationSupportDirectory() throws -> URL {
        try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }
    
    private func normalizedJPEGData(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        let normalizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
        
        return normalizedImage.jpegData(compressionQuality: 0.95)
    }
}

private extension NSLock {
    func withLock<T>(_ body: () -> T) -> T {
        lock()
        defer { unlock() }
        return body()
    }
}
