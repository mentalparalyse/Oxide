// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation
import ImageProcessor

struct GalleryEditHistoryState: Equatable, Sendable {
    let currentDraft: GalleryDraft?
    let canUndo: Bool
}

final class GalleryEditHistoryStore {
    private let persistence: ImageProcessPersistence<GalleryDraft>
    
    init(persistence: ImageProcessPersistence<GalleryDraft> = ImageProcessPersistence()) {
        self.persistence = persistence
    }
    
    var canUndo: Bool {
        persistence.canUndo
    }
    
    func reset(for photoID: GalleryPhoto.ID) {
        persistence.resetHistory(for: photoID)
    }
    
    func record(_ draft: GalleryDraft) -> GalleryEditHistoryState {
        persistence.record(draft, identifier: draft.photo.id).galleryState
    }
    
    func undo() -> GalleryEditHistoryState {
        persistence.undo().galleryState
    }
}

private extension ImageProcessHistoryState where Snapshot == GalleryDraft {
    var galleryState: GalleryEditHistoryState {
        GalleryEditHistoryState(currentDraft: currentSnapshot, canUndo: canUndo)
    }
}
