// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

struct GalleryFilterSectionBar: View {
    let catalog: GalleryFilterCatalog
    let selectedFilterID: String?
    let expandedSectionID: String?
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
        .frame(height: 48)
        .accessibilityLabel("Filter categories")
    }

    private var originalButton: some View {
        let isSelected = selectedFilterID == catalog.original.id
        return Button(action: onSelectOriginal) {
            sectionLabel(title: catalog.original.name, isSelected: isSelected, isExpanded: false)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Original filter")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func sectionButton(_ section: GalleryFilterSection) -> some View {
        let isSelected = section.contains(filterID: selectedFilterID)
        let isExpanded = expandedSectionID == section.id
        return Button { onToggleSection(section) } label: {
            sectionLabel(title: section.title, isSelected: isSelected, isExpanded: isExpanded)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(section.title) filters")
        .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func sectionLabel(
        title: String,
        isSelected: Bool,
        isExpanded: Bool
    ) -> some View {
        HStack(spacing: 5) {
            Text(title)
                .font(.system(size: 13, weight: isExpanded ? .semibold : .medium))
                .foregroundStyle(isExpanded || isSelected ? AppColours.accentHighContrast : Color.white.opacity(0.78))
                .lineLimit(1)

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColours.accent)
            }
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 44)
        .overlay(alignment: .bottom) {
            Capsule()
                .fill(isExpanded ? AppColours.accent : Color.clear)
                .frame(height: 2)
        }
        .contentShape(Rectangle())
    }
}
