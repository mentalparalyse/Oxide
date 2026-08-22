// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import ImageProcessor
import SwiftUI
import UIComponents

struct GalleryEditingView: View {
    @ObservedObject var presenter: GalleryPresenter
    @State private var activeTool: GalleryEditingTool = .filters
    @State private var selectedSpatialEffectKind: GalleryEffectKind?
    @State private var expandedFilterSectionID: String?

    var body: some View {
        ZStack {
            editorPreview
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(spacing: 0) {
                GalleryEditorNavigationBar(
                    canUndo: presenter.canUndoEdit,
                    onCancel: presenter.cancelEditing,
                    onUndo: { Task { await presenter.undoLastEdit() } },
                    onSave: presenter.saveDraft
                )

                Spacer(minLength: 0)

                VStack(spacing: 0) {
                    toolContent
                        .frame(height: 176)

                    GalleryEditingToolTabBar(selection: $activeTool)
                }
                .background(AppColours.appColor)
            }
        }
        .background(AppColours.appColor)
        .ignoresSafeArea(edges: .bottom)
    }

    private var editorPreview: some View {
        Group {
            if let draft = presenter.draft {
                GalleryEditorPreviewSurface(
                    draft: draft,
                    sourceSize: presenter.editingSourceSize,
                    isCropping: activeTool == .crop,
                    onResize: presenter.resizeCrop,
                    onResizeEnded: { Task { await presenter.commitCropResize() } },
                    spatialEffectKind: activeTool == .effects ? selectedSpatialEffectKind : nil,
                    onSpatialCenterChange: updateSpatialCenter,
                    onSpatialCenterChangeEnded: { Task { await presenter.commitEffects() } }
                )
            } else {
                AppColours.appColor
            }
        }
    }

    @ViewBuilder
    private var toolContent: some View {
        switch activeTool {
        case .filters:
            VStack(spacing: 8) {
                if let expandedFilterSection {
                    GalleryExpandedFilterRail(
                        section: expandedFilterSection,
                        selectedFilterID: presenter.draft?.selectedFilterID,
                        imageURL: presenter.draft?.photo.imageURI,
                        onSelectFilter: { filter in
                            Task { await presenter.selectFilter(filter.id) }
                        }
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
                    onSelectOriginal: {
                        expandedFilterSectionID = nil
                        Task { await presenter.selectFilter(GalleryFilter.original.id) }
                    },
                    onToggleSection: toggleFilterSection
                )
            }
        case .adjustments:
            if let adjustments = presenter.draft?.adjustments {
                GalleryAdjustmentControlsView(
                    adjustments: adjustments,
                    onChange: presenter.setAdjustment,
                    onChangeEnded: { Task { await presenter.commitAdjustment() } },
                    onToggleMonochrome: { Task { await presenter.toggleMonochrome() } }
                )
            }
        case .effects:
            if let draft = presenter.draft {
                GalleryEffectsControlsView(
                    draft: draft,
                    onEffectsChange: presenter.setEffects,
                    onChangeEnded: { Task { await presenter.commitEffects() } },
                    onSelectedKindChange: { selectedSpatialEffectKind = $0 }
                )
            }
        case .crop:
            GalleryCropControlsView(
                selectedAspectRatio: presenter.draft?.cropAspectRatio,
                onSelect: { ratio in Task { await presenter.setCropAspectRatio(ratio) } }
            )
        case .rotate:
            HStack(spacing: 32) {
                Button { Task { await presenter.rotateDraft(by: -90) } } label: {
                    Image(systemName: "rotate.left")
                        .frame(width: 56, height: 56)
                        .background(AppColours.appSurfaceColor, in: Circle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColours.appForegroundColor)
                .accessibilityLabel("Rotate left 90 degrees")

                Text("\(presenter.draft?.rotationDegrees ?? 0)°")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppColours.appForegroundColor)
                    .frame(width: 72)

                Button { Task { await presenter.rotateDraft(by: 90) } } label: {
                    Image(systemName: "rotate.right")
                        .frame(width: 56, height: 56)
                        .background(AppColours.appSurfaceColor, in: Circle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColours.appForegroundColor)
                .accessibilityLabel("Rotate right 90 degrees")
            }
        }
    }

    private var expandedFilterSection: GalleryFilterSection? {
        presenter.filterCatalog.sections.first { $0.id == expandedFilterSectionID }
    }

    private func toggleFilterSection(_ section: GalleryFilterSection) {
        withAnimation(.easeInOut(duration: 0.18)) {
            expandedFilterSectionID = expandedFilterSectionID == section.id ? nil : section.id
        }
    }

    private func updateSpatialCenter(_ centerX: Double, _ centerY: Double) {
        guard let kind = selectedSpatialEffectKind,
              var effects = presenter.draft?.effects,
              let current = effects.spatialMask(for: kind)
        else { return }

        effects.setSpatialMask(
            ImageSpatialEffectMask(
                mode: current.mode,
                centerX: centerX,
                centerY: centerY,
                radius: current.radius,
                feather: current.feather
            ),
            for: kind
        )
        presenter.setEffects(effects)
    }
}
