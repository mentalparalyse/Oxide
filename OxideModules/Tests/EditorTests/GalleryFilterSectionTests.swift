// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import ImageProcessor
import Testing
@testable import Editor

struct GalleryFilterSectionTests {
    @Test func catalogKeepsOriginalOutsideSectionsAndDoesNotDuplicateFilters() {
        let filters = [
            GalleryFilter.original,
            filter("39_loot", "Pure"),
            filter("13_loot", "Amber"),
            filter("unknown", "Custom")
        ]

        let catalog = GalleryFilterCatalog(filters: filters)
        let sectionFilterIDs = catalog.sections.flatMap(\.filters).map(\.id)

        #expect(catalog.original.id == GalleryFilter.original.id)
        #expect(!sectionFilterIDs.contains(GalleryFilter.original.id))
        #expect(Set(sectionFilterIDs).count == sectionFilterIDs.count)
        #expect(Set(sectionFilterIDs) == Set(["39_loot", "13_loot", "unknown"]))
    }

    @Test func selectedFilterBecomesSectionThumbnail() throws {
        let first = filter("39_loot", "Pure")
        let selected = filter("44_loot", "Balanced")
        let section = GalleryFilterSection(id: "clean", title: "Clean", filters: [first, selected])

        #expect(section.thumbnailFilter(selectedFilterID: selected.id) == selected)
        #expect(section.contains(filterID: selected.id))
    }

    @Test func firstFilterIsThumbnailFallbackForNoOrUnknownSelection() {
        let first = filter("film-1", "Film 01")
        let section = GalleryFilterSection(
            id: "film",
            title: "Film",
            filters: [first, filter("film-2", "Film 02")]
        )

        #expect(section.thumbnailFilter(selectedFilterID: nil) == first)
        #expect(section.thumbnailFilter(selectedFilterID: "missing") == first)
        #expect(!section.contains(filterID: GalleryFilter.original.id))
    }

    @Test func emptySectionHasNoThumbnailAndMatchesNoSelection() {
        let section = GalleryFilterSection(id: "empty", title: "Empty", filters: [])

        #expect(section.thumbnailFilter(selectedFilterID: "anything") == nil)
        #expect(!section.contains(filterID: "anything"))
    }

    @Test func catalogFindsParentSectionAndHandlesUnknownAndOriginalIDs() throws {
        let selected = filter("portrait", "Portrait")
        let catalog = GalleryFilterCatalog(filters: [GalleryFilter.original, selected])

        #expect(catalog.section(containing: selected.id)?.id == "clean")
        #expect(catalog.section(containing: GalleryFilter.original.id) == nil)
        #expect(catalog.section(containing: "missing") == nil)
        #expect(catalog.section(containing: nil) == nil)
    }

    @Test func curatedLUTsJoinTheirExplicitPacks() {
        let catalog = GalleryFilterCatalog(filters: [
            GalleryFilter.original,
            filter("00_tron", "Neon Night"),
            filter("39_loot", "Pure")
        ])

        #expect(catalog.sections.map(\.id) == ["clean", "cinema"])
        #expect(catalog.sections.flatMap(\.filters).map(\.id) == ["39_loot", "00_tron"])
    }

    private func filter(_ id: String, _ name: String) -> GalleryFilter {
        GalleryFilter(id: id, name: name)
    }
}
