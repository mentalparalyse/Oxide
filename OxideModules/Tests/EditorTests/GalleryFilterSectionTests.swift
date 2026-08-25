// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import ImageProcessor
import Testing
@testable import Editor

struct GalleryFilterSectionTests {
    @Test func catalogKeepsOriginalOutsideSectionsAndDoesNotDuplicateFilters() {
        let filters = [
            GalleryFilter.original,
            filter("cinematic-1", "Cinematic 01"),
            filter("vintage-1", "Vintage 01"),
            filter("unknown", "Custom")
        ]

        let catalog = GalleryFilterCatalog(filters: filters)
        let sectionFilterIDs = catalog.sections.flatMap(\.filters).map(\.id)

        #expect(catalog.original.id == GalleryFilter.original.id)
        #expect(!sectionFilterIDs.contains(GalleryFilter.original.id))
        #expect(Set(sectionFilterIDs).count == sectionFilterIDs.count)
        #expect(Set(sectionFilterIDs) == Set(["cinematic-1", "vintage-1", "unknown"]))
    }

    @Test func selectedFilterBecomesSectionThumbnail() throws {
        let first = filter("cinematic-1", "Cinematic 01")
        let selected = filter("cinematic-2", "Cinematic 02")
        let section = GalleryFilterSection(id: "cinematic", title: "Cinematic", filters: [first, selected])

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
        let selected = filter("portrait-1", "Portrait 01")
        let catalog = GalleryFilterCatalog(filters: [GalleryFilter.original, selected])

        #expect(catalog.section(containing: selected.id)?.id == "portrait")
        #expect(catalog.section(containing: GalleryFilter.original.id) == nil)
        #expect(catalog.section(containing: "missing") == nil)
        #expect(catalog.section(containing: nil) == nil)
    }

    @Test func namedMovieLUTsJoinCinematicPack() {
        let catalog = GalleryFilterCatalog(filters: [
            GalleryFilter.original,
            filter("00_tron", "Tron"),
            filter("01_brooklyn", "Brooklyn")
        ])

        #expect(catalog.sections.map(\.id) == ["cinematic"])
        #expect(catalog.sections.first?.filters.map(\.id) == ["00_tron", "01_brooklyn"])
    }

    private func filter(_ id: String, _ name: String) -> GalleryFilter {
        GalleryFilter(id: id, name: name)
    }
}
