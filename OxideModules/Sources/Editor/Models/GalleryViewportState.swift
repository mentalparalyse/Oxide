import CoreGraphics

public struct GalleryViewportState: Equatable {
    public static let minimumScale: CGFloat = 1
    public static let maximumScale: CGFloat = 5
    public static let zoomStep: CGFloat = 0.5
    public static let doubleTapScale: CGFloat = 2

    public private(set) var scale: CGFloat = minimumScale
    public private(set) var offset: CGSize = .zero

    public init() {}

    public mutating func applyScale(_ proposedScale: CGFloat) {
        scale = Self.clampedScale(proposedScale)
        if scale == Self.minimumScale {
            offset = .zero
        }
    }

    public mutating func zoomIn() {
        applyScale(scale + Self.zoomStep)
    }

    public mutating func zoomOut() {
        applyScale(scale - Self.zoomStep)
    }

    public mutating func toggleDoubleTapZoom() {
        applyScale(scale > Self.minimumScale ? Self.minimumScale : Self.doubleTapScale)
    }

    public mutating func applyOffset(
        _ proposedOffset: CGSize,
        imageSize: CGSize,
        containerSize: CGSize
    ) {
        offset = Self.clampedOffset(
            proposedOffset,
            scale: scale,
            imageSize: imageSize,
            containerSize: containerSize
        )
    }

    public mutating func reset() {
        scale = Self.minimumScale
        offset = .zero
    }

    public static func clampedScale(_ scale: CGFloat) -> CGFloat {
        min(max(scale, minimumScale), maximumScale)
    }

    public static func clampedOffset(
        _ offset: CGSize,
        scale: CGFloat,
        imageSize: CGSize,
        containerSize: CGSize
    ) -> CGSize {
        guard scale > minimumScale else { return .zero }
        let horizontalLimit = max(0, (imageSize.width * scale - containerSize.width) / 2)
        let verticalLimit = max(0, (imageSize.height * scale - containerSize.height) / 2)
        return CGSize(
            width: min(max(offset.width, -horizontalLimit), horizontalLimit),
            height: min(max(offset.height, -verticalLimit), verticalLimit)
        )
    }
}
