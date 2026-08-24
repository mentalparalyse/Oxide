// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import ImageProcessor
import SwiftUI
import UIComponents

struct GalleryEditorPreviewSurface: View {
    let draft: GalleryDraft
    let sourceSize: CGSize?
    let isCropping: Bool
    let onResize: (ImageEditCropEdge, ImageEditCrop?, Double, Double) -> Void
    let onResizeEnded: () -> Void
    let spatialEffectKind: GalleryEffectKind?
    let onSpatialCenterChange: (Double, Double) -> Void
    let onSpatialCenterChangeEnded: () -> Void

    @State private var viewport = GalleryViewportState()
    @GestureState private var gestureScale: CGFloat = 1
    @GestureState private var gestureOffset: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            let imageSize = fittedImageSize(in: proxy.size)
            let effectiveScale = GalleryViewportState.clampedScale(viewport.scale * gestureScale)
            let proposedOffset = CGSize(
                width: panOffset.width + gestureOffset.width,
                height: panOffset.height + gestureOffset.height
            )
            let effectiveOffset = GalleryViewportState.clampedOffset(
                proposedOffset,
                scale: effectiveScale,
                imageSize: imageSize,
                containerSize: proxy.size
            )

            ZStack {
                AppColours.appColor

                ZStack {
                    LUTPreviewImage(
                        imageURL: draft.photo.imageURI,
                        presetID: draft.selectedFilterID,
                        intensity: draft.filterIntensity,
                        rotationDegrees: draft.rotationDegrees,
                        crop: isCropping ? nil : draft.crop,
                        adjustments: draft.adjustments,
                        effects: draft.effects,
                        contentMode: .fit,
                        maxPixelSize: 1_600
                    )
                    .frame(width: imageSize.width, height: imageSize.height)

                    if isCropping {
                        CropOverlayView(
                            crop: draft.crop,
                            zoomScale: effectiveScale,
                            onResize: onResize,
                            onResizeEnded: onResizeEnded
                        )
                        .frame(width: imageSize.width, height: imageSize.height)
                    }

                    if let mask = activeSpatialMask {
                        GallerySpatialEffectOverlay(
                            mask: mask,
                            rotationDegrees: draft.rotationDegrees,
                            style: spatialOverlayStyle,
                            effectRotation: draft.effects.tiltShift.rotation,
                            onCenterChange: onSpatialCenterChange,
                            onCenterChangeEnded: onSpatialCenterChangeEnded
                        )
                        .frame(width: imageSize.width, height: imageSize.height)
                    }
                }
                .frame(width: imageSize.width, height: imageSize.height)
                .scaleEffect(effectiveScale)
                .offset(effectiveOffset)

                GalleryZoomControlsView(
                    scale: effectiveScale,
                    zoomOut: { updateZoom(by: -GalleryViewportState.zoomStep, imageSize: imageSize, containerSize: proxy.size) },
                    reset: resetViewport,
                    zoomIn: { updateZoom(by: GalleryViewportState.zoomStep, imageSize: imageSize, containerSize: proxy.size) }
                )
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .contentShape(Rectangle())
            .clipped()
            .simultaneousGesture(magnificationGesture(imageSize: imageSize, containerSize: proxy.size))
            .simultaneousGesture(panGesture(imageSize: imageSize, containerSize: proxy.size))
            .onTapGesture(count: 2) {
                withAnimation(.easeOut(duration: 0.2)) {
                    viewport.toggleDoubleTapZoom()
                }
            }
        }
    }

    private func magnificationGesture(imageSize: CGSize, containerSize: CGSize) -> some Gesture {
        MagnificationGesture()
            .updating($gestureScale) { value, state, _ in
                state = value
            }
            .onEnded { value in
                viewport.applyScale(viewport.scale * value)
                viewport.applyOffset(viewport.offset, imageSize: imageSize, containerSize: containerSize)
            }
    }

    private func panGesture(imageSize: CGSize, containerSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 8)
            .updating($gestureOffset) { value, state, _ in
                guard !isCropping, activeSpatialMask == nil, viewport.scale > 1 else { return }
                state = value.translation
            }
            .onEnded { value in
                guard !isCropping, activeSpatialMask == nil, viewport.scale > 1 else { return }
                viewport.applyOffset(
                    CGSize(
                        width: viewport.offset.width + value.translation.width,
                        height: viewport.offset.height + value.translation.height
                    ),
                    imageSize: imageSize,
                    containerSize: containerSize
                )
            }
    }

    private func fittedImageSize(in container: CGSize) -> CGSize {
        let size = GalleryEditorImageGeometry.effectiveSize(
            sourceSize: sourceSize,
            crop: draft.crop,
            rotationDegrees: draft.rotationDegrees,
            appliesCrop: !isCropping
        )
        guard size.width > 0, size.height > 0 else {
            return container
        }

        let scale = min(container.width / size.width, container.height / size.height)
        return CGSize(width: size.width * scale, height: size.height * scale)
    }

    private var panOffset: CGSize {
        viewport.offset
    }

    private var activeSpatialMask: ImageSpatialEffectMask? {
        guard let spatialEffectKind,
              let mask = draft.effects.spatialMask(for: spatialEffectKind),
              mask.mode == .spot
        else { return nil }
        return mask
    }

    private var spatialOverlayStyle: GallerySpatialEffectOverlay.Style {
        guard spatialEffectKind == .tiltShift,
              draft.effects.tiltShift.style == .linear
        else { return .radial }
        return .linear
    }

    private func updateZoom(by delta: CGFloat, imageSize: CGSize, containerSize: CGSize) {
        withAnimation(.easeOut(duration: 0.16)) {
            viewport.applyScale(viewport.scale + delta)
            viewport.applyOffset(viewport.offset, imageSize: imageSize, containerSize: containerSize)
        }
    }

    private func resetViewport() {
        withAnimation(.easeOut(duration: 0.2)) {
            viewport.reset()
        }
    }
}

enum GalleryEditorImageGeometry {
    static func effectiveSize(
        sourceSize: CGSize?,
        crop: ImageEditCrop?,
        rotationDegrees: Int,
        appliesCrop: Bool
    ) -> CGSize {
        guard var size = sourceSize else { return .zero }

        if appliesCrop, let crop {
            size = CGSize(
                width: size.width * crop.width,
                height: size.height * crop.height
            )
        }

        let rotation = ImageEditRotation.normalized(rotationDegrees)
        if rotation == 90 || rotation == 270 {
            size = CGSize(width: size.height, height: size.width)
        }
        return size
    }
}
