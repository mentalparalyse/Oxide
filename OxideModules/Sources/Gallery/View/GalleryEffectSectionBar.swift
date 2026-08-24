import SwiftUI
import UIComponents

struct GalleryEffectSectionBar: View {
    let catalog: GalleryEffectCatalog
    let selectionID: GalleryEffectPreset.ID
    let expandedSectionID: GalleryEffectSection.ID?
    let onSelectNone: () -> Void
    let onSelectSection: (GalleryEffectSection) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                noneButton

                ForEach(catalog.sections) { section in
                    sectionButton(section)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .frame(height: 48)
        .accessibilityLabel("Effect categories")
    }

    private var noneButton: some View {
        let isSelected = selectionID == catalog.none.id
        return Button(action: onSelectNone) {
            sectionLabel(title: catalog.none.name, isSelected: isSelected, isExpanded: false)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("No effects")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func sectionButton(_ section: GalleryEffectSection) -> some View {
        let isSelected = section.contains(presetID: selectionID)
        let isExpanded = expandedSectionID == section.id
        return Button { onSelectSection(section) } label: {
            sectionLabel(title: section.title, isSelected: isSelected, isExpanded: isExpanded)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(section.title) effects")
        .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func sectionLabel(title: String, isSelected: Bool, isExpanded: Bool) -> some View {
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
