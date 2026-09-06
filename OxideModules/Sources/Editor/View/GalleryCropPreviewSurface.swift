import ImageProcessor
import SwiftUI
import UIComponents

struct GalleryCropPreviewSurface: View {
    let draft: EditorDraft
    let sourceSize: CGSize?
    let onCommit: (ImageEditCrop) -> Void

    @State private var geometry: GalleryCropGeometry
    @State private var lastCommittedCrop: ImageEditCrop?
    @GestureState private var magnification: CGFloat = 1
    @GestureState private var translation: CGSize = .zero

    init(draft: EditorDraft, sourceSize: CGSize?, onCommit: @escaping (ImageEditCrop) -> Void) {
        self.draft = draft
        self.sourceSize = sourceSize
        self.onCommit = onCommit
        _geometry = State(initialValue: GalleryCropGeometry(crop: draft.crop, rotationDegrees: draft.rotationDegrees))
        _lastCommittedCrop = State(initialValue: draft.crop)
    }

    var body: some View {
        GeometryReader { proxy in
            let size = fittedSize(in: proxy.size)
            let live = geometry.transformed(magnification: magnification, translation: translation, imageSize: size)
            ZStack {
                AppColours.appColor
                LUTPreviewImage(
                    imageURL: draft.asset.imageURI,
                    presetID: draft.selectedFilterID,
                    intensity: draft.filterIntensity,
                    rotationDegrees: draft.rotationDegrees,
                    adjustments: draft.adjustments,
                    effects: draft.effects,
                    contentMode: .fit,
                    maxPixelSize: 1_600
                )
                .frame(width: size.width, height: size.height)
                .scaleEffect(live.scale)
                .offset(x: live.offset.width * size.width, y: live.offset.height * size.height)
                .frame(width: size.width, height: size.height)
                .clipped()
                .allowsHitTesting(false)

                Color.clear
                    .contentShape(Rectangle())
                    .gesture(imageGesture(size: size))
                    .onTapGesture(count: 2) { zoom(to: geometry.scale > 1 ? 1 : 2, size: size) }

                CropOverlayView(
                    crop: geometry.window,
                    onResize: { edge, base, dx, dy in
                        geometry.resize(edge: edge, base: base, dx: dx, dy: dy, locked: draft.cropAspectRatio != nil)
                    },
                    onResizeEnded: commit
                )
                .frame(width: size.width, height: size.height)

                ZoomControlsView(
                    scale: live.scale,
                    zoomOut: { zoom(to: geometry.scale - 0.25, size: size) },
                    reset: { zoom(to: 1, size: size) },
                    zoomIn: { zoom(to: geometry.scale + 0.25, size: size) }
                )
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .onChange(of: draft.crop) { crop in
            guard crop != lastCommittedCrop else { return }
            geometry = GalleryCropGeometry(crop: crop, rotationDegrees: draft.rotationDegrees)
            lastCommittedCrop = crop
        }
        .onChange(of: draft.rotationDegrees) { _ in
            geometry = GalleryCropGeometry(crop: draft.crop, rotationDegrees: draft.rotationDegrees)
        }
    }

    private func imageGesture(size: CGSize) -> some Gesture {
        MagnificationGesture()
            .simultaneously(with: DragGesture(minimumDistance: 2))
            .updating($magnification) { value, state, _ in state = value.first ?? 1 }
            .updating($translation) { value, state, _ in state = value.second?.translation ?? .zero }
            .onEnded { value in
                geometry = geometry.transformed(
                    magnification: value.first ?? 1,
                    translation: value.second?.translation ?? .zero,
                    imageSize: size
                )
                commit()
            }
    }

    private func zoom(to scale: CGFloat, size: CGSize) {
        geometry = geometry.transformed(magnification: scale / geometry.scale, translation: .zero, imageSize: size)
        commit()
    }

    private func commit() {
        let crop = geometry.sourceCrop(rotationDegrees: draft.rotationDegrees)
        guard crop != lastCommittedCrop else { return }
        lastCommittedCrop = crop
        onCommit(crop)
    }

    private func fittedSize(in container: CGSize) -> CGSize {
        let source = GalleryEditorImageGeometry.effectiveSize(
            sourceSize: sourceSize, crop: nil, rotationDegrees: draft.rotationDegrees, appliesCrop: false
        )
        guard source.width > 0, source.height > 0 else { return container }
        // Leave room for the fixed-size handles at the image boundary.
        let factor = min(max(container.width - 36, 1) / source.width, max(container.height - 36, 1) / source.height)
        return CGSize(width: source.width * factor, height: source.height * factor)
    }
}
