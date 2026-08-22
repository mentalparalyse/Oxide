// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

struct GalleryFilterSectionBar: View {
    let catalog: GalleryFilterCatalog
    let selectedFilterID: String?
    let expandedSectionID: String?
    let imageURL: URL?
    let onSelectOriginal: () -> Void
    let onToggleSection: (GalleryFilterSection) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                originalButton

                ForEach(catalog.sections) { section in
                    sectionButton(section)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .frame(height: 88)
        .accessibilityLabel("Filter categories")
    }

    private var originalButton: some View {
        let isSelected = selectedFilterID == catalog.original.id
        return Button(action: onSelectOriginal) {
            sectionLabel(
                title: catalog.original.name,
                filter: catalog.original,
                isSelected: isSelected,
                isExpanded: false
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Original filter")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func sectionButton(_ section: GalleryFilterSection) -> some View {
        let isSelected = section.contains(filterID: selectedFilterID)
        let isExpanded = expandedSectionID == section.id
        return Button { onToggleSection(section) } label: {
            sectionLabel(
                title: section.title,
                filter: section.thumbnailFilter(selectedFilterID: selectedFilterID),
                isSelected: isSelected,
                isExpanded: isExpanded
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(section.title) filters")
        .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func sectionLabel(
        title: String,
        filter: GalleryFilter?,
        isSelected: Bool,
        isExpanded: Bool
    ) -> some View {
        VStack(spacing: 5) {
            LUTPreviewImage(
                imageURL: imageURL,
                presetID: filter?.id,
                rotationDegrees: 0,
                contentMode: .fill,
                maxPixelSize: 112
            )
            .frame(width: 54, height: 54)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isExpanded ? AppColours.accent : Color.clear, lineWidth: 2)
            }
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 18, height: 18)
                        .background(AppColours.accent, in: Circle())
                        .offset(x: 4, y: -4)
                }
            }

            Text(title)
                .font(.system(size: 11, weight: isExpanded ? .semibold : .medium))
                .foregroundStyle(isExpanded || isSelected ? AppColours.accent : AppColours.appMutedForegroundColor)
                .lineLimit(1)
        }
        .frame(minWidth: 64, minHeight: 80)
        .contentShape(Rectangle())
    }
}
