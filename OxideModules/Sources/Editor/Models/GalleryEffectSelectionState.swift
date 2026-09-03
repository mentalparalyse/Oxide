struct GalleryEffectSelectionState: Equatable, Sendable {
    private(set) var selectionID: GalleryEffectPreset.ID
    private(set) var expandedSectionID: GalleryEffectSection.ID?
    private(set) var editingPresetID: GalleryEffectPreset.ID?

    var isEditing: Bool { editingPresetID != nil }

    init(selectionID: GalleryEffectPreset.ID, expandedSectionID: GalleryEffectSection.ID?) {
        self.selectionID = selectionID
        self.expandedSectionID = expandedSectionID
    }

    mutating func beginEditing(_ preset: GalleryEffectPreset, sectionID: GalleryEffectSection.ID?) {
        selectionID = preset.id
        expandedSectionID = sectionID
        editingPresetID = preset.id
    }

    mutating func returnToCollection() {
        editingPresetID = nil
    }

    mutating func selectNone() {
        selectionID = "none"
        expandedSectionID = nil
        editingPresetID = nil
    }

    mutating func disableSelection(fallbackID: GalleryEffectPreset.ID) {
        selectionID = fallbackID
        editingPresetID = nil
    }

    mutating func toggleSection(_ sectionID: GalleryEffectSection.ID) {
        expandedSectionID = expandedSectionID == sectionID ? nil : sectionID
    }
}
