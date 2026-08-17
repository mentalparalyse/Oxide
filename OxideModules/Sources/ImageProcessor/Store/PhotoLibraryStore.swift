import Foundation
import Photos

public enum PhotoLibraryStoreError: Error {
    case accessDenied
}

public actor PhotoLibraryStore {
    public init() { }

    public func saveImage(at fileURL: URL) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            throw PhotoLibraryStoreError.accessDenied
        }
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileURL)
        }
    }
}
