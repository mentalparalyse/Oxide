import Testing
@testable import Editor

struct GalleryEffectSelectionStateTests {
    @Test func selectingPresetOpensFocusedEditor() {
        var state = GalleryEffectSelectionState(selectionID: "none", expandedSectionID: "lens")
        let preset = GalleryEffectPreset.all.first { $0.id == "edge-soft" }!
        state.beginEditing(preset, sectionID: "lens")
        #expect(state.selectionID == preset.id)
        #expect(state.isEditing)
    }

    @Test func backPreservesAppliedSelection() {
        var state = GalleryEffectSelectionState(selectionID: "none", expandedSectionID: "lens")
        let preset = GalleryEffectPreset.all.first { $0.id == "edge-soft" }!
        state.beginEditing(preset, sectionID: "lens")
        state.returnToCollection()
        #expect(state.selectionID == preset.id)
        #expect(!state.isEditing)
    }

    @Test func disablingSelectionReturnsToCollectionWithFallback() {
        var state = GalleryEffectSelectionState(selectionID: "edge-soft", expandedSectionID: "lens")
        state.disableSelection(fallbackID: "none")
        #expect(state.selectionID == "none")
        #expect(!state.isEditing)
    }

    @Test func noneClosesEditorAndCollapsesSections() {
        var state = GalleryEffectSelectionState(selectionID: "edge-soft", expandedSectionID: "lens")
        state.selectNone()
        #expect(state == GalleryEffectSelectionState(selectionID: "none", expandedSectionID: nil))
    }
}
