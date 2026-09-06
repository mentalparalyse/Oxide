import CoreGraphics
import ImageProcessor
import Testing
@testable import Editor

struct GalleryCropGeometryTests {
    private let size = CGSize(width: 400, height: 600)

    @Test func zoomKeepsMaskFixedAndChangesExportedCrop() {
        let initial = GalleryCropGeometry(crop: nil, rotationDegrees: 0)
        let zoomed = initial.transformed(magnification: 2, translation: .zero, imageSize: size)
        #expect(zoomed.window == initial.window)
        #expect(zoomed.sourceCrop(rotationDegrees: 0) == ImageEditCrop(x: 0.25, y: 0.25, width: 0.5, height: 0.5))
    }

    @Test func panMovesImageBeneathMaskAndClampsToImageEdges() {
        let initial = GalleryCropGeometry(crop: nil, rotationDegrees: 0)
        let moved = initial.transformed(magnification: 2, translation: CGSize(width: 10_000, height: -10_000), imageSize: size)
        #expect(moved.window == initial.window)
        #expect(moved.sourceCrop(rotationDegrees: 0) == ImageEditCrop(x: 0, y: 0.5, width: 0.5, height: 0.5))
    }

    @Test func zoomOutNeverExposesEmptyPixels() {
        let initial = GalleryCropGeometry(crop: nil, rotationDegrees: 0)
        let zoomed = initial.transformed(magnification: 2, translation: CGSize(width: 100, height: 100), imageSize: size)
        let reset = zoomed.transformed(magnification: 0.01, translation: .zero, imageSize: size)
        #expect(reset.scale == 1)
        #expect(reset.offset == .zero)
        #expect(reset.sourceCrop(rotationDegrees: 0) == GalleryCropGeometry.fullImage)
    }

    @Test func invalidGestureAndZeroLayoutAreIgnored() {
        let initial = GalleryCropGeometry(crop: nil, rotationDegrees: 0)
        #expect(initial.transformed(magnification: .nan, translation: .zero, imageSize: size) == initial)
        #expect(initial.transformed(magnification: 2, translation: .zero, imageSize: .zero) == initial)
        #expect(initial.transformed(magnification: 2, translation: CGSize(width: CGFloat.infinity, height: 0), imageSize: size) == initial)
        #expect(initial.transformed(magnification: 100, translation: .zero, imageSize: size).scale == 8)
    }

    @Test(arguments: [0, 90, 180, 270, -90, 450])
    func rotationRoundTripsAsymmetricCrop(degrees: Int) {
        let crop = ImageEditCrop(x: 0.125, y: 0.25, width: 0.5, height: 0.625)
        let geometry = GalleryCropGeometry(crop: crop, rotationDegrees: degrees)
        #expect(geometry.sourceCrop(rotationDegrees: degrees) == crop)
    }

    @Test func rotationMatchesCoreImageCounterclockwiseDirection() {
        let crop = ImageEditCrop(x: 0, y: 0, width: 0.5, height: 0.25)
        #expect(GalleryCropGeometry.rotated(crop, degrees: 90) == ImageEditCrop(x: 0, y: 0.5, width: 0.25, height: 0.5))
    }

    @Test func resizeUsesGestureStartAndPreservesLockedRatio() {
        var geometry = GalleryCropGeometry(crop: nil, rotationDegrees: 0)
        let base = geometry.window
        geometry.resize(edge: .leading, base: base, dx: 0.1, dy: 0, locked: true)
        geometry.resize(edge: .leading, base: base, dx: 0.25, dy: 0, locked: true)
        #expect(geometry.window == ImageEditCrop(x: 0.25, y: 0.125, width: 0.75, height: 0.75))
    }

    @Test func freeResizeClampsCrossedEdgesAndRejectsNaN() {
        var geometry = GalleryCropGeometry(crop: nil, rotationDegrees: 0)
        geometry.resize(edge: .trailing, base: nil, dx: -10, dy: 0, locked: false)
        #expect(abs(geometry.window.width - ImageEditCropper.minimumSide) < 1e-9)
        let before = geometry
        geometry.resize(edge: .top, base: nil, dx: 0, dy: .nan, locked: false)
        #expect(geometry == before)
    }

    @Test func reopeningCommittedZoomPreservesSelection() {
        let geometry = GalleryCropGeometry(crop: nil, rotationDegrees: 90)
            .transformed(magnification: 3, translation: CGSize(width: 45, height: -72), imageSize: size)
        let crop = geometry.sourceCrop(rotationDegrees: 90)
        let restored = GalleryCropGeometry(crop: crop, rotationDegrees: 90).sourceCrop(rotationDegrees: 90)
        #expect(abs(restored.x - crop.x) < 1e-9)
        #expect(abs(restored.y - crop.y) < 1e-9)
        #expect(abs(restored.width - crop.width) < 1e-9)
        #expect(abs(restored.height - crop.height) < 1e-9)
    }
}
