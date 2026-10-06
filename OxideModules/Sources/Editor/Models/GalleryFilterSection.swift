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
    case clean
    case golden
    case coastal
    case cinema
    case film
    case moody
    case mono
    case creative

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }

    func matches(_ filter: GalleryFilter) -> Bool {
        Self.filterIDs[self, default: []].contains(filter.id)
    }

    private static let filterIDs: [GalleryFilterSectionDefinition: Set<String>] = [
        .clean: ["portrait", "38_loot", "39_loot", "40_loot", "44_loot", "46_loot", "95_loot", "96_loot", "100_loot", "101_loot", "106_loot", "107_loot", "127_loot", "140_loot", "149_loot", "168_loot"],
        .golden: ["13_loot", "15_loot", "16_loot", "23_loot", "42_loot", "43_loot", "50_loot", "53_loot", "56_loot", "87_loot", "88_loot", "129_loot", "139_loot", "159_loot", "180_loot"],
        .coastal: ["travel", "10_loot", "11_loot", "24_loot", "25_loot", "47_loot", "48_loot", "54_loot", "58_loot", "62_loot", "65_loot", "66_loot", "73_loot", "74_loot", "134_loot", "147_loot"],
        .cinema: ["cinematic", "00_tron", "01_brooklyn", "02_ametrine", "03_sedona", "04_suicide_squad", "05_her_strong", "06_drive", "07_no_country", "08_casino_royal", "14_loot", "28_loot", "31_loot", "32_loot", "33_loot", "34_loot"],
        .film: ["vintage", "film", "29_loot", "57_loot", "59_loot", "60_loot", "61_loot", "63_loot", "75_loot", "79_loot", "82_loot", "92_loot", "93_loot", "122_loot", "138_loot", "164_loot", "178_loot"],
        .moody: ["19_loot", "20_loot", "26_loot", "27_loot", "35_loot", "36_loot", "37_loot", "45_loot", "76_loot", "77_loot", "90_loot", "136_loot", "145_loot", "165_loot", "175_loot"],
        .mono: ["blackwhite", "12_loot", "17_loot", "18_loot", "78_loot", "111_loot", "121_loot", "124_loot", "128_loot", "144_loot", "152_loot", "155_loot", "162_loot", "170_loot", "179_loot", "182_loot"],
        .creative: ["21_loot", "30_loot", "86_loot", "89_loot", "102_loot", "103_loot", "104_loot", "105_loot", "133_loot", "135_loot", "137_loot", "156_loot", "157_loot", "169_loot", "173_loot"]
    ]
}
