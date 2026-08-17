// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation
import ImageProcessor

struct GalleryEditHistoryState: Equatable, Sendable {
    let currentDraft: GalleryDraft?
    let canUndo: Bool
}

actor GalleryEditHistoryStore {
    private let persistence: ImageEditHistoryPersistence<GalleryDraft>

    init(persistence: ImageEditHistoryPersistence<GalleryDraft> = ImageEditHistoryPersistence()) {
        self.persistence = persistence
    }

    func reset(for photoID: GalleryPhoto.ID) async {
        await persistence.resetHistory(for: photoID)
    }

    func record(_ draft: GalleryDraft) async -> GalleryEditHistoryState {
        await persistence.record(draft, identifier: draft.photo.id).galleryState
    }

    func undo() async -> GalleryEditHistoryState {
        await persistence.undo().galleryState
    }
}

private extension ImageEditHistoryState where Snapshot == GalleryDraft {
    var galleryState: GalleryEditHistoryState {
        GalleryEditHistoryState(currentDraft: currentSnapshot, canUndo: canUndo)
    }
}
