// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation
import ImageProcessor

struct EditorHistoryState: Equatable, Sendable {
    let currentDraft: EditorDraft?
    let canUndo: Bool
}

actor EditorHistoryStore {
    enum HistoryError: Error { case recordingFailed }
    private let persistence: ImageEditHistoryPersistence<EditorDraft>
    private var state = EditorHistoryState(currentDraft: nil, canUndo: false)

    init(persistence: ImageEditHistoryPersistence<EditorDraft> = ImageEditHistoryPersistence()) {
        self.persistence = persistence
    }

    func reset(for photoID: String) async {
        await persistence.resetHistory(for: photoID)
        state = EditorHistoryState(currentDraft: nil, canUndo: false)
    }

    func record(_ draft: EditorDraft) async -> EditorHistoryState {
        state = await persistence.record(draft, identifier: draft.asset.id).editorState
        return state
    }

    func undo() async -> EditorHistoryState {
        state = await persistence.undo().editorState
        return state
    }

    func recordReplacement(_ updated: EditorDraft, replacing previous: EditorDraft) async throws -> EditorHistoryState {
        guard updated != previous else {
            return EditorHistoryState(currentDraft: previous, canUndo: state.canUndo)
        }
        // Checkpoint live edits so one undo restores the exact pre-application state.
        if state.currentDraft != previous {
            guard await record(previous).currentDraft == previous else {
                throw HistoryError.recordingFailed
            }
        }
        let result = await record(updated)
        guard result.currentDraft == updated else {
            throw HistoryError.recordingFailed
        }
        return result
    }
}

private extension ImageEditHistoryState where Snapshot == EditorDraft {
    var editorState: EditorHistoryState {
        EditorHistoryState(currentDraft: currentSnapshot, canUndo: canUndo)
    }
}
