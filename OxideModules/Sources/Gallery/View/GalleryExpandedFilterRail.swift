// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI

struct GalleryExpandedFilterRail: View {
    let section: GalleryFilterSection
    let selectedFilterID: String?
    let imageURL: URL?
    let onSelectFilter: (GalleryFilter) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 14) {
                ForEach(section.filters) { filter in
                    FilterChipView(
                        filter: filter,
                        isSelected: selectedFilterID == filter.id,
                        imageURL: imageURL,
                        action: { onSelectFilter(filter) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .accessibilityLabel("\(section.title) filters")
    }
}
