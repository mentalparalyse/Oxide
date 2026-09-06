import CoreGraphics
import ImageProcessor

/// Crop window and image transform use normalized, top-left display coordinates.
/// The persisted crop uses unrotated source coordinates, matching ImageProcessor.
struct GalleryCropGeometry: Equatable {
    static let fullImage = ImageEditCrop(x: 0, y: 0, width: 1, height: 1)
    var window: ImageEditCrop
    private(set) var scale: CGFloat = 1
    private(set) var offset: CGSize = .zero

    init(crop: ImageEditCrop?, rotationDegrees: Int) {
        window = Self.rotated(crop ?? Self.fullImage, degrees: rotationDegrees)
    }

    func transformed(magnification: CGFloat, translation: CGSize, imageSize: CGSize) -> Self {
        guard magnification.isFinite, translation.width.isFinite, translation.height.isFinite,
              imageSize.width.isFinite, imageSize.height.isFinite,
              imageSize.width > 0, imageSize.height > 0 else { return self }
        var result = self
        result.scale = min(max(scale * magnification, 1), 8)
        // Zoom about the crop center, keeping the selected subject centered.
        let factor = result.scale / scale
        let centerX = window.x + window.width / 2 - 0.5
        let centerY = window.y + window.height / 2 - 0.5
        result.offset = CGSize(
            width: centerX + (offset.width - centerX) * factor + translation.width / imageSize.width,
            height: centerY + (offset.height - centerY) * factor + translation.height / imageSize.height
        )
        result.constrainOffset()
        return result
    }

    mutating func resize(edge: ImageEditCropEdge, base: ImageEditCrop?, dx: Double, dy: Double, locked: Bool) {
        guard dx.isFinite, dy.isFinite else { return }
        let base = base ?? window
        var resized = ImageEditCropper.resized(base, edge: edge, horizontalDelta: dx, verticalDelta: dy)
        if locked {
            let horizontal = edge == .leading || edge == .trailing
            let proposedFactor = horizontal ? resized.width / base.width : resized.height / base.height
            let maxFactor: Double
            if horizontal {
                maxFactor = 2 * min(base.y + base.height / 2, 1 - base.y - base.height / 2) / base.height
            } else {
                maxFactor = 2 * min(base.x + base.width / 2, 1 - base.x - base.width / 2) / base.width
            }
            let factor = min(proposedFactor, maxFactor)
            let width = base.width * factor
            let height = base.height * factor
            resized = ImageEditCrop(
                x: edge == .leading ? base.x + base.width - width : (horizontal ? base.x : base.x + (base.width - width) / 2),
                y: edge == .top ? base.y + base.height - height : (horizontal ? base.y + (base.height - height) / 2 : base.y),
                width: width, height: height
            )
        }
        window = resized
        constrainOffset()
    }

    func sourceCrop(rotationDegrees: Int) -> ImageEditCrop {
        let displayed = ImageEditCrop(
            x: (window.x - 0.5 - offset.width) / scale + 0.5,
            y: (window.y - 0.5 - offset.height) / scale + 0.5,
            width: window.width / scale,
            height: window.height / scale
        )
        return Self.rotated(displayed, degrees: -rotationDegrees)
    }

    private mutating func constrainOffset() {
        let margin = (scale - 1) / 2
        offset.width = min(max(offset.width, window.x + window.width - 1 - margin), window.x + margin)
        offset.height = min(max(offset.height, window.y + window.height - 1 - margin), window.y + margin)
    }

    /// Positive Core Image rotation is counterclockwise in top-left display space.
    static func rotated(_ crop: ImageEditCrop, degrees: Int) -> ImageEditCrop {
        switch ImageEditRotation.normalized(degrees) {
        case 90:
            ImageEditCrop(x: crop.y, y: 1 - crop.x - crop.width, width: crop.height, height: crop.width)
        case 180:
            ImageEditCrop(x: 1 - crop.x - crop.width, y: 1 - crop.y - crop.height, width: crop.width, height: crop.height)
        case 270:
            ImageEditCrop(x: 1 - crop.y - crop.height, y: crop.x, width: crop.height, height: crop.width)
        default: crop
        }
    }
}
