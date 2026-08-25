import Editor
import SwiftUI

struct GalleryZoomablePreview<Content: View>: View {
    private let content: Content

    @State private var viewport = GalleryViewportState()
    @GestureState private var gestureScale: CGFloat = 1
    @GestureState private var gestureOffset: CGSize = .zero

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { proxy in
            let effectiveScale = GalleryViewportState.clampedScale(
                viewport.scale * gestureScale
            )
            let proposedOffset = CGSize(
                width: viewport.offset.width + gestureOffset.width,
                height: viewport.offset.height + gestureOffset.height
            )
            let effectiveOffset = GalleryViewportState.clampedOffset(
                proposedOffset,
                scale: effectiveScale,
                imageSize: proxy.size,
                containerSize: proxy.size
            )

            content
                .frame(width: proxy.size.width, height: proxy.size.height)
                .scaleEffect(effectiveScale)
                .offset(effectiveOffset)
                .contentShape(Rectangle())
                .simultaneousGesture(magnificationGesture(containerSize: proxy.size))
                .simultaneousGesture(panGesture(containerSize: proxy.size))
                .onTapGesture(count: 2, perform: toggleDoubleTapZoom)
        }
        .clipped()
        .accessibilityAction(named: "Reset zoom") {
            resetViewport()
        }
    }

    private func magnificationGesture(containerSize: CGSize) -> some Gesture {
        MagnificationGesture()
            .updating($gestureScale) { value, state, _ in
                state = value
            }
            .onEnded { value in
                viewport.applyScale(viewport.scale * value)
                viewport.applyOffset(
                    viewport.offset,
                    imageSize: containerSize,
                    containerSize: containerSize
                )
            }
    }

    private func panGesture(containerSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 8)
            .updating($gestureOffset) { value, state, _ in
                guard viewport.scale > GalleryViewportState.minimumScale else { return }
                state = value.translation
            }
            .onEnded { value in
                guard viewport.scale > GalleryViewportState.minimumScale else { return }
                viewport.applyOffset(
                    CGSize(
                        width: viewport.offset.width + value.translation.width,
                        height: viewport.offset.height + value.translation.height
                    ),
                    imageSize: containerSize,
                    containerSize: containerSize
                )
            }
    }

    private func toggleDoubleTapZoom() {
        withAnimation(.easeOut(duration: 0.2)) {
            viewport.toggleDoubleTapZoom()
        }
    }

    private func resetViewport() {
        withAnimation(.easeOut(duration: 0.2)) {
            viewport.reset()
        }
    }
}
