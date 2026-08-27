import CoreGraphics
import ImageProcessor
import Testing
@testable import Editor

struct GallerySpatialEffectTests {
    @Test func onlyRelevantEffectsSupportSpatialMasks() {
        #expect(GalleryEffectKind.lightLeak.supportsSpatialMask)
        #expect(GalleryEffectKind.chromaticAberration.supportsSpatialMask)
        #expect(GalleryEffectKind.halation.supportsSpatialMask)
        #expect(GalleryEffectKind.bloom.supportsSpatialMask)
        #expect(GalleryEffectKind.sparkle.supportsSpatialMask)
        #expect(GalleryEffectKind.pixelSort.supportsSpatialMask)
        #expect(GalleryEffectKind.tiltShift.supportsSpatialMask)
        #expect(GalleryEffectKind.edgeBlur.supportsSpatialMask)
        #expect(GalleryEffectKind.vignette.supportsSpatialMask)
        #expect(!GalleryEffectKind.filmGrain.supportsSpatialMask)
        #expect(!GalleryEffectKind.dustAndScratches.supportsSpatialMask)
    }

    @Test func settingVignetteCenterChangesOnlyVignette() {
        var effects = ImageEffects(
            edgeBlur: ImageEdgeBlur(amount: 0.5),
            vignette: ImageVignette(amount: 0.5)
        )
        let spot = ImageSpatialEffectMask(mode: .spot, centerX: 0.8, centerY: 0.3)

        effects.setSpatialMask(spot, for: .vignette)

        #expect(effects.vignette.spatialMask == spot)
        #expect(effects.edgeBlur.spatialMask == .fullFrame)
    }

    @Test func settingMaskChangesOnlySelectedEffect() throws {
        var effects = ImageEffects(
            lightLeak: ImageLightLeak(amount: 0.5),
            chromaticAberration: ImageChromaticAberration(amount: 0.5)
        )
        let spot = ImageSpatialEffectMask(mode: .spot, centerX: 0.2, centerY: 0.7)

        effects.setSpatialMask(spot, for: .chromaticAberration)

        #expect(effects.chromaticAberration.spatialMask == spot)
        #expect(effects.lightLeak.spatialMask == .fullFrame)
    }

    @Test(arguments: [0, 90, 180, 270])
    func displayAndImageCoordinateTransformsRoundTrip(rotation: Int) {
        let display = GallerySpatialEffectGeometry.displayPoint(
            centerX: 0.23,
            centerY: 0.71,
            rotationDegrees: rotation
        )
        let image = GallerySpatialEffectGeometry.imagePoint(
            displayPoint: display,
            rotationDegrees: rotation
        )

        #expect(abs(image.x - 0.23) < 0.0001)
        #expect(abs(image.y - 0.71) < 0.0001)
    }

    @Test func coordinateTransformsClampTouchesToImageBounds() {
        let point = GallerySpatialEffectGeometry.imagePoint(
            displayPoint: CGPoint(x: -1, y: 2),
            rotationDegrees: 0
        )

        #expect(point == CGPoint(x: 0, y: 1))
    }

    @Test func linearGuideMirrorsCoreImageAngleIntoSwiftUICoordinates() {
        #expect(
            GallerySpatialEffectGeometry.linearGuideRotationDegrees(
                effectRotation: 0.25,
                imageRotationDegrees: 0
            ) == -45
        )
        #expect(
            GallerySpatialEffectGeometry.linearGuideRotationDegrees(
                effectRotation: 0.25,
                imageRotationDegrees: 90
            ) == 45
        )
        #expect(
            GallerySpatialEffectGeometry.linearGuideRotationDegrees(
                effectRotation: 0.75,
                imageRotationDegrees: 270
            ) == 135
        )
    }
}
