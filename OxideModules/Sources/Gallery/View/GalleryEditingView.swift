// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

struct GalleryEditingView: View {
    @ObservedObject var presenter: GalleryPresenter
    @State private var activeTool: EditingTool = .filters

    private enum EditingTool: String, CaseIterable {
        case filters
        case adjustments
        case crop
        case rotate

        var title: String {
            rawValue.prefix(1).uppercased() + rawValue.dropFirst()
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                CircleIconButton(systemName: "xmark", label: "Cancel", action: presenter.cancelEditing)
                CircleIconButton(
                    systemName: "arrow.uturn.backward",
                    label: "Undo last edit",
                    action: { Task { await presenter.undoLastEdit() } }
                )
                .opacity(presenter.canUndoEdit ? 1 : 0.35)
                .disabled(!presenter.canUndoEdit)
                Spacer()
                Button("Save", action: presenter.saveDraft)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColours.appForegroundColor)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(AppColours.buttonBacground, in: Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            editorPreview
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 16)

            toolPicker
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

            toolContent
                .frame(height: 176)
                .padding(.bottom, 20)
        }
    }

    private var editorPreview: some View {
        Group {
            if let draft = presenter.draft {
                GalleryEditorPreviewSurface(
                    draft: draft,
                    sourceSize: presenter.editingSourceSize,
                    isCropping: activeTool == .crop,
                    onResize: presenter.resizeCrop,
                    onResizeEnded: { Task { await presenter.commitCropResize() } }
                )
            } else {
                AppColours.appColor
            }
        }
    }

    private var toolPicker: some View {
        HStack(spacing: 4) {
            ForEach(EditingTool.allCases, id: \.self) { tool in
                Button {
                    activeTool = tool
                } label: {
                    Text(tool.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(activeTool == tool ? AppColours.appForegroundColor : AppColours.appMutedForegroundColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(activeTool == tool ? AppColours.appBorderColor : Color.clear, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(AppColours.appSurfaceColor, in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var toolContent: some View {
        switch activeTool {
        case .filters:
            VStack(spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(presenter.filters) { filter in
                            FilterChipView(
                                filter: filter,
                                isSelected: presenter.draft?.selectedFilterID == filter.id,
                                imageURL: presenter.draft?.photo.imageURI,
                                action: { Task { await presenter.selectFilter(filter.id) } }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }

                if presenter.draft?.selectedFilterID != GalleryFilter.original.id {
                    FilterIntensitySlider(
                        value: presenter.draft?.filterIntensity ?? 1,
                        onChange: presenter.setFilterIntensity,
                        onChangeEnded: { Task { await presenter.commitFilterIntensity() } }
                    )
                    .padding(.horizontal, 16)
                }
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
}
