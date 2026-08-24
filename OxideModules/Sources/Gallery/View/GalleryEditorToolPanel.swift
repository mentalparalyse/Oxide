// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

struct GalleryEditorToolPanel: View {
    @ObservedObject var presenter: GalleryPresenter
    let activeTool: GalleryEditingTool
    @Binding var selectedSpatialEffectKind: GalleryEffectKind?

    @ViewBuilder
    var body: some View {
        switch activeTool {
        case .filters:
            EmptyView()
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

}
