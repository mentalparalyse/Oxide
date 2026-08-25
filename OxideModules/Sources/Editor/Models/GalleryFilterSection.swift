// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import Foundation

public struct GalleryFilterSection: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let filters: [GalleryFilter]

    public init(id: String, title: String, filters: [GalleryFilter]) {
        self.id = id
        self.title = title
        self.filters = filters
    }

    public func contains(filterID: String?) -> Bool {
        guard let filterID else { return false }
        return filters.contains { $0.id == filterID }
    }

    public func thumbnailFilter(selectedFilterID: String?) -> GalleryFilter? {
        filters.first { $0.id == selectedFilterID } ?? filters.first
    }
}

public struct GalleryFilterCatalog: Equatable, Sendable {
    public let original: GalleryFilter
    public let sections: [GalleryFilterSection]

    public init(filters: [GalleryFilter]) {
        original = filters.first { $0.id == GalleryFilter.original.id } ?? GalleryFilter.original

        let availableFilters = filters.filter { $0.id != GalleryFilter.original.id }
        let definitions = GalleryFilterSectionDefinition.allCases
        var grouped = Dictionary(uniqueKeysWithValues: definitions.map { ($0, [GalleryFilter]()) })
        var uncategorized: [GalleryFilter] = []

        for filter in availableFilters {
            if let definition = definitions.first(where: { $0.matches(filter) }) {
                grouped[definition, default: []].append(filter)
            } else {
                uncategorized.append(filter)
            }
        }

        var result = definitions.compactMap { definition -> GalleryFilterSection? in
            guard let filters = grouped[definition], !filters.isEmpty else { return nil }
            return GalleryFilterSection(id: definition.id, title: definition.title, filters: filters)
        }

        if !uncategorized.isEmpty {
            result.append(GalleryFilterSection(id: "other", title: "Other", filters: uncategorized))
        }
        sections = result
    }

    public func section(containing filterID: String?) -> GalleryFilterSection? {
        sections.first { $0.contains(filterID: filterID) }
    }
}

private enum GalleryFilterSectionDefinition: String, CaseIterable, Hashable {
    case cinematic
    case vintage
    case travel
    case portrait
    case film
    case blackAndWhite
    case urban
    case sunset
    case editorial
    case dream

    var id: String { rawValue }

    var title: String {
        switch self {
        case .blackAndWhite: "Black & White"
        default: rawValue.capitalized
        }
    }

    func matches(_ filter: GalleryFilter) -> Bool {
        let normalizedName = filter.name.lowercased()
        if normalizedName == title.lowercased() || normalizedName.hasPrefix(title.lowercased() + " ") {
            return true
        }

        // The named LUTs are movie-inspired and belong to the Cinematic pack.
        return self == .cinematic && Self.namedCinematicFilterIDs.contains(filter.id)
    }

    private static let namedCinematicFilterIDs: Set<String> = [
        "00_tron", "01_brooklyn", "02_ametrine", "03_sedona", "04_suicide_squad",
        "05_her_strong", "06_drive", "07_no_country", "08_casino_royal", "10_loot", "11_loot"
    ]
}
