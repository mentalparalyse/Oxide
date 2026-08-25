import Testing
@testable import Gallery

struct GalleryEffectSectionTests {
    @Test func catalogKeepsNoneOutsideSectionsAndAssignsEveryPresetOnce() {
        let catalog = GalleryEffectCatalog(presets: GalleryEffectPreset.all)
        let sectionPresetIDs = catalog.sections.flatMap(\.presets).map(\.id)
        let expectedPresetIDs = GalleryEffectPreset.all.filter { !$0.isNone }.map(\.id)

        #expect(catalog.none.id == "none")
        #expect(!sectionPresetIDs.contains("none"))
        #expect(Set(sectionPresetIDs).count == sectionPresetIDs.count)
        #expect(Set(sectionPresetIDs) == Set(expectedPresetIDs))
    }

    @Test func catalogUsesCuratedSectionOrder() {
        let catalog = GalleryEffectCatalog(presets: GalleryEffectPreset.all)

        #expect(catalog.sections.map(\.id) == ["film", "light", "lens", "creative"])
    }

    @Test func catalogFindsSectionForSelectedPreset() {
        let catalog = GalleryEffectCatalog(presets: GalleryEffectPreset.all)

        #expect(catalog.section(containing: "grain-film")?.id == "film")
        #expect(catalog.section(containing: "sparkle-soft")?.id == "light")
        #expect(catalog.section(containing: "zoom-rush")?.id == "lens")
        #expect(catalog.section(containing: "tilt-miniature")?.id == "lens")
        #expect(catalog.section(containing: "edge-soft")?.id == "lens")
        #expect(catalog.section(containing: "vignette-dark")?.id == "lens")
        #expect(catalog.section(containing: "sort-melt")?.id == "creative")
        #expect(catalog.section(containing: "none") == nil)
        #expect(catalog.section(containing: "missing") == nil)
    }

    @Test func catalogOmitsEmptySectionsForAPartialCatalog() {
        let presets = GalleryEffectPreset.all.filter { $0.isNone || $0.kind == .bloom }
        let catalog = GalleryEffectCatalog(presets: presets)

        #expect(catalog.sections.map(\.id) == ["light"])
        #expect(catalog.sections[0].presets.allSatisfy { $0.kind == .bloom })
    }
}
