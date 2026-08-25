// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation
import ImageProcessor

struct EditorHistoryState: Equatable, Sendable {
    let currentDraft: EditorDraft?
    let canUndo: Bool
}

actor EditorHistoryStore {
    private let persistence: ImageEditHistoryPersistence<EditorDraft>

    init(persistence: ImageEditHistoryPersistence<EditorDraft> = ImageEditHistoryPersistence()) {
        self.persistence = persistence
    }

    func reset(for photoID: String) async {
        await persistence.resetHistory(for: photoID)
    }

    func record(_ draft: EditorDraft) async -> EditorHistoryState {
        await persistence.record(draft, identifier: draft.asset.id).editorState
    }

    func undo() async -> EditorHistoryState {
        await persistence.undo().editorState
    }
}

private extension ImageEditHistoryState where Snapshot == EditorDraft {
    var editorState: EditorHistoryState {
        EditorHistoryState(currentDraft: currentSnapshot, canUndo: canUndo)
    }
}
