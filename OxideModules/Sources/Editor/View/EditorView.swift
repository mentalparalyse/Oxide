// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import ImageProcessor
import SwiftUI
import UIComponents

public struct EditorView: View {
    @ObservedObject var presenter: EditorPresenter
    @State private var activeTool: GalleryEditingTool = .filters
    @State private var selectedSpatialEffectKind: GalleryEffectKind?
    @State private var expandedFilterSectionID: String?
    @State private var comparisonVisibility = GalleryComparisonVisibilityState()

    public init(presenter: EditorPresenter) {
        self.presenter = presenter
    }

    public var body: some View {
        ZStack {
            editorPreview
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .galleryPressComparison(
                    isEnabled: isComparisonEligible,
                    onPressVisibilityChange: updatePressComparisonVisibility
                )

            VStack(spacing: 0) {
                GalleryEditorNavigationBar(
                    canUndo: presenter.canUndo,
                    onCancel: presenter.cancel,
                    onUndo: { Task { await presenter.undo() } },
                    onSave: presenter.save
                )

                Spacer(minLength: 0)

                VStack(spacing: 10) {
                    if activeTool == .filters {
                        GalleryEditorFilterPanels(
                            presenter: presenter,
                            expandedSectionID: $expandedFilterSectionID
                        )
                    } else {
                        FloatingControlPanel {
                            GalleryEditorToolPanel(
                                presenter: presenter,
                                activeTool: activeTool,
                                selectedSpatialEffectKind: $selectedSpatialEffectKind
                            )
                        }
                    }

                    FloatingControlPanel {
                        GalleryEditingToolTabBar(selection: $activeTool)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
            .opacity(comparisonVisibility.areControlsHidden ? 0 : 1)
            .allowsHitTesting(!comparisonVisibility.areControlsHidden)
            .accessibilityHidden(comparisonVisibility.areControlsHidden)
        }
        .background(AppColours.appColor)
        .animation(.easeOut(duration: 0.16), value: comparisonVisibility.areControlsHidden)
        .accessibilityAction(
            named: comparisonVisibility.areControlsHidden ? "Show editing controls" : "Hide editing controls"
        ) {
            comparisonVisibility.toggleAccessibilityVisibility()
        }
    }

    private var editorPreview: some View {
        Group {
            GalleryEditorPreviewSurface(
                    draft: presenter.draft,
                    sourceSize: presenter.sourceSize,
                    isCropping: activeTool == .crop,
                    onResize: presenter.resizeCrop,
                    onResizeEnded: { Task { await presenter.commitCropResize() } },
                    spatialEffectKind: activeTool == .effects ? selectedSpatialEffectKind : nil,
                    onSpatialCenterChange: updateSpatialCenter,
                    onSpatialCenterChangeEnded: { Task { await presenter.commitEffects() } }
                )
        }
    }

    private var isComparisonEligible: Bool {
        GalleryComparisonInteraction.isEligible(
            activeTool: activeTool,
            isPositioningSpatialEffect: activeSpatialMask != nil
        )
    }

    private var activeSpatialMask: ImageSpatialEffectMask? {
        guard activeTool == .effects,
              let selectedSpatialEffectKind,
              let mask = presenter.draft.effects.spatialMask(for: selectedSpatialEffectKind),
              mask.mode == .spot
        else { return nil }
        return mask
    }

    private func updatePressComparisonVisibility(_ isVisible: Bool) {
        if isVisible {
            comparisonVisibility.beginPress()
        } else {
            comparisonVisibility.endPress()
        }
    }

    private func updateSpatialCenter(_ centerX: Double, _ centerY: Double) {
        guard let kind = selectedSpatialEffectKind,
              let current = presenter.draft.effects.spatialMask(for: kind)
        else { return }
        var effects = presenter.draft.effects

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
