import Foundation
import ImageProcessor

struct SavedLook: Identifiable, Equatable, Codable, Sendable {
    let id: UUID
    let name: String
    let filterID: String
    let filterIntensity: Double
    let adjustments: ImageAdjustments
    let effects: ImageEffects

    static func isValidName(_ name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(name: String, draft: EditorDraft) {
        id = UUID()
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        filterID = draft.selectedFilterID
        filterIntensity = draft.filterIntensity
        adjustments = draft.adjustments
        effects = draft.effects
    }

    func applying(to draft: EditorDraft) -> EditorDraft {
        var result = draft
        result.selectedFilterID = filterID
        result.filterIntensity = filterIntensity
        result.adjustments = adjustments
        result.effects = effects
        return result
    }
}
