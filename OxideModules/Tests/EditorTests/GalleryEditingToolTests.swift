// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Testing
@testable import Editor

struct GalleryEditingToolTests {
    @Test func editingToolsHaveStableDisplayMetadata() {
        #expect(GalleryEditingTool.allCases.map(\.title) == [
            "Filters",
            "Adjust",
            "Effects",
            "Crop",
            "Rotate"
        ])
        #expect(GalleryEditingTool.allCases.map(\.systemImage) == [
            "camera.filters",
            "slider.horizontal.3",
            "sparkles",
            "crop",
            "rotate.right"
        ])
    }

    @Test func editingToolIdentifiersAreUnique() {
        let identifiers = GalleryEditingTool.allCases.map(\.id)

        #expect(Set(identifiers).count == identifiers.count)
    }
}
