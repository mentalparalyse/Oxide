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

    @State private var zoomScale: CGFloat = 1
    @State private var panOffset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1
    @GestureState private var gestureOffset: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            let imageSize = fittedImageSize(in: proxy.size)
            let effectiveScale = clampedScale(zoomScale * gestureScale)
            let effectiveOffset = CGSize(
                width: panOffset.width + gestureOffset.width,
                height: panOffset.height + gestureOffset.height
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
                        contentMode: .fit
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
                }
                .frame(width: imageSize.width, height: imageSize.height)
                .scaleEffect(effectiveScale)
                .offset(effectiveOffset)
                .simultaneousGesture(magnificationGesture)
                .simultaneousGesture(panGesture)
                .onTapGesture(count: 2, perform: resetViewport)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureScale) { value, state, _ in
                state = value
            }
            .onEnded { value in
                zoomScale = clampedScale(zoomScale * value)
                if zoomScale == 1 {
                    panOffset = .zero
                }
            }
    }

    private var panGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .updating($gestureOffset) { value, state, _ in
                guard !isCropping, zoomScale > 1 else { return }
                state = value.translation
            }
            .onEnded { value in
                guard !isCropping, zoomScale > 1 else { return }
                panOffset.width += value.translation.width
                panOffset.height += value.translation.height
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

    private func clampedScale(_ value: CGFloat) -> CGFloat {
        min(max(value, 1), 5)
    }

    private func resetViewport() {
        withAnimation(.easeOut(duration: 0.2)) {
            zoomScale = 1
            panOffset = .zero
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
