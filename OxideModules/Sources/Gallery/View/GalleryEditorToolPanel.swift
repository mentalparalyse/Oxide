// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

struct GalleryEditorToolPanel: View {
    @ObservedObject var presenter: GalleryPresenter
    let activeTool: GalleryEditingTool
    @Binding var selectedSpatialEffectKind: GalleryEffectKind?
    @Binding var expandedFilterSectionID: String?

    @ViewBuilder
    var body: some View {
        switch activeTool {
        case .filters:
            filterControls
                .padding(.vertical, 8)
        case .adjustments:
            if let adjustments = presenter.draft?.adjustments {
                GalleryAdjustmentControlsView(
                    adjustments: adjustments,
                    onChange: presenter.setAdjustment,
                    onChangeEnded: { Task { await presenter.commitAdjustment() } },
                    onToggleMonochrome: { Task { await presenter.toggleMonochrome() } }
                )
                .padding(.vertical, 14)
            }
        case .effects:
            if let draft = presenter.draft {
                GalleryEffectsControlsView(
                    draft: draft,
                    onEffectsChange: presenter.setEffects,
                    onChangeEnded: { Task { await presenter.commitEffects() } },
                    onSelectedKindChange: { selectedSpatialEffectKind = $0 }
                )
                .frame(height: 176)
            }
        case .crop:
            GalleryCropControlsView(
                selectedAspectRatio: presenter.draft?.cropAspectRatio,
                onSelect: { ratio in Task { await presenter.setCropAspectRatio(ratio) } }
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 14)
        case .rotate:
            rotateControls
                .padding(14)
        }
    }

    private var filterControls: some View {
        VStack(spacing: 8) {
            if let expandedFilterSection {
                GalleryExpandedFilterRail(
                    section: expandedFilterSection,
                    selectedFilterID: presenter.draft?.selectedFilterID,
                    imageURL: presenter.draft?.photo.imageURI,
                    onSelectFilter: { filter in Task { await presenter.selectFilter(filter.id) } }
                )
            }

            if presenter.draft?.selectedFilterID != GalleryFilter.original.id {
                FilterIntensitySlider(
                    value: presenter.draft?.filterIntensity ?? 1,
                    onChange: presenter.setFilterIntensity,
                    onChangeEnded: { Task { await presenter.commitFilterIntensity() } }
                )
                .padding(.horizontal, 16)
            }

            GalleryFilterSectionBar(
                catalog: presenter.filterCatalog,
                selectedFilterID: presenter.draft?.selectedFilterID,
                expandedSectionID: expandedFilterSectionID,
                imageURL: presenter.draft?.photo.imageURI,
                onSelectOriginal: selectOriginal,
                onToggleSection: toggleFilterSection
            )
        }
    }

    private var rotateControls: some View {
        HStack(spacing: 32) {
            rotationButton(systemName: "rotate.left", degrees: -90, label: "Rotate left 90 degrees")

            Text("\(presenter.draft?.rotationDegrees ?? 0)°")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(AppColours.appForegroundColor)
                .frame(width: 72)

            rotationButton(systemName: "rotate.right", degrees: 90, label: "Rotate right 90 degrees")
        }
    }

    private func rotationButton(systemName: String, degrees: Int, label: String) -> some View {
        Button { Task { await presenter.rotateDraft(by: degrees) } } label: {
            Image(systemName: systemName)
                .frame(width: 56, height: 56)
                .background(AppColours.appSurfaceColor, in: Circle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(AppColours.appForegroundColor)
        .accessibilityLabel(label)
    }

    private var expandedFilterSection: GalleryFilterSection? {
        presenter.filterCatalog.sections.first { $0.id == expandedFilterSectionID }
    }

    private func selectOriginal() {
        expandedFilterSectionID = nil
        Task { await presenter.selectFilter(GalleryFilter.original.id) }
    }

    private func toggleFilterSection(_ section: GalleryFilterSection) {
        withAnimation(.easeInOut(duration: 0.18)) {
            expandedFilterSectionID = expandedFilterSectionID == section.id ? nil : section.id
        }
    }
}
