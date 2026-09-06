import ImageProcessor
import Testing
@testable import Editor

struct GalleryEffectPresetTests {
    @Test func noneClearsEveryEffect() {
        let enabled = ImageEffects(
            filmGrain: ImageFilmGrain(amount: 0.5),
            lightLeak: ImageLightLeak(amount: 0.5),
            chromaticAberration: ImageChromaticAberration(amount: 0.5),
            halation: ImageHalation(amount: 0.5),
            dustAndScratches: ImageDustAndScratches(amount: 0.5),
            bloom: ImageBloom(amount: 0.5),
            vhs: ImageVHS(amount: 0.5),
            lensWarp: ImageLensWarp(amount: 0.5),
            zoomBlur: ImageZoomBlur(amount: 0.5),
            kaleidoscope: ImageKaleidoscope(amount: 0.5),
            sparkle: ImageSparkle(amount: 0.5),
            pixelSort: ImagePixelSort(amount: 0.5),
            tiltShift: ImageTiltShift(amount: 0.5),
            edgeBlur: ImageEdgeBlur(amount: 0.5),
            vignette: ImageVignette(amount: 0.5)
        )

        #expect(preset("none").applying(to: enabled) == .neutral)
    }

    @Test func applyingPresetPreservesOtherEffectKinds() {
        let current = ImageEffects(
            lightLeak: ImageLightLeak(amount: 0.4),
            chromaticAberration: ImageChromaticAberration(amount: 0.3)
        )
        let result = preset("grain-film").applying(to: current)

        #expect(result.filmGrain.amount == 1)
        #expect(result.lightLeak == current.lightLeak)
        #expect(result.chromaticAberration == current.chromaticAberration)
    }

    @Test func removingPresetDisablesOnlyItsEffectFamily() {
        let current = ImageEffects(
            filmGrain: ImageFilmGrain(amount: 0.5),
            lightLeak: ImageLightLeak(amount: 0.4)
        )

        let result = preset("grain-film").removing(from: current)

        #expect(result.filmGrain == .disabled)
        #expect(result.lightLeak == current.lightLeak)
    }

    @Test func presetsHaveUniqueIdentifiers() {
        let identifiers = GalleryEffectPreset.all.map(\.id)

        #expect(Set(identifiers).count == identifiers.count)
    }

    @Test func selectedPresetsApplyAtFullStrength() {
        for preset in GalleryEffectPreset.all where !preset.isNone {
            let effects = preset.applying(to: .neutral)
            #expect(appliedAmount(for: preset.kind, in: effects) == 1)
        }
    }

    @Test func applyingHalationPresetPreservesOtherEffectKinds() {
        let current = ImageEffects(filmGrain: ImageFilmGrain(amount: 0.3))
        let result = preset("halation-dream").applying(to: current)

        #expect(result.halation.amount == 1)
        #expect(result.filmGrain == current.filmGrain)
    }

    @Test func applyingDustPresetPreservesOtherEffectKinds() {
        let current = ImageEffects(halation: ImageHalation(amount: 0.3))
        let result = preset("dust-archive").applying(to: current)

        #expect(result.dustAndScratches.amount == 1)
        #expect(result.halation == current.halation)
    }

    @Test func applyingBloomPresetPreservesOtherEffectKinds() {
        let current = ImageEffects(dustAndScratches: ImageDustAndScratches(amount: 0.3))
        let result = preset("bloom-dream").applying(to: current)

        #expect(result.bloom.amount == 1)
        #expect(result.dustAndScratches == current.dustAndScratches)
    }

    @Test func applyingVHSPresetPreservesOtherEffectKinds() {
        let current = ImageEffects(bloom: ImageBloom(amount: 0.3))
        let result = preset("vhs-tracking").applying(to: current)

        #expect(result.vhs.amount == 1)
        #expect(result.bloom == current.bloom)
    }

    @Test func applyingLensWarpPresetPreservesOtherEffectKinds() {
        let current = ImageEffects(vhs: ImageVHS(amount: 0.3))
        let result = preset("lens-pinch").applying(to: current)

        #expect(result.lensWarp.scale == -0.65)
        #expect(result.vhs == current.vhs)
    }

    @Test func applyingMotionBlurPresetPreservesOtherEffectKinds() {
        let current = ImageEffects(lensWarp: ImageLensWarp(amount: 0.3))
        let result = preset("motion-speed").applying(to: current)
        #expect(result.motionBlur.amount == 1)
        #expect(result.lensWarp == current.lensWarp)
    }

    @Test func applyingZoomBlurPresetPreservesOtherEffectKinds() {
        let current = ImageEffects(motionBlur: ImageMotionBlur(amount: 0.3))
        let result = preset("zoom-impact").applying(to: current)
        #expect(result.zoomBlur.amount == 1)
        #expect(result.motionBlur == current.motionBlur)
    }

    @Test func applyingKaleidoscopePresetPreservesOtherEffectKinds() {
        let current = ImageEffects(zoomBlur: ImageZoomBlur(amount: 0.3))
        let result = preset("kaleido-crystal").applying(to: current)
        #expect(result.kaleidoscope.segments == 6)
        #expect(result.zoomBlur == current.zoomBlur)
    }

    @Test func applyingSparklePresetPreservesOtherEffectKinds() {
        let current = ImageEffects(kaleidoscope: ImageKaleidoscope(amount: 0.3))
        let result = preset("sparkle-starburst").applying(to: current)
        #expect(result.sparkle.rayLength == 0.72)
        #expect(result.kaleidoscope == current.kaleidoscope)
    }

    @Test func applyingPixelSortPresetPreservesOtherEffectKinds() {
        let current = ImageEffects(sparkle: ImageSparkle(amount: 0.3))
        let result = preset("sort-melt").applying(to: current)
        #expect(result.pixelSort.trailLength == 0.72)
        #expect(result.sparkle == current.sparkle)
    }

    @Test func applyingTiltShiftPresetPreservesOtherEffectKinds() {
        let current = ImageEffects(pixelSort: ImagePixelSort(amount: 0.3))
        let result = preset("tilt-radial").applying(to: current)
        #expect(result.tiltShift.style == .radial)
        #expect(result.pixelSort == current.pixelSort)
    }

    @Test func applyingEdgeBlurPresetPreservesOtherEffectKinds() {
        let current = ImageEffects(tiltShift: ImageTiltShift(amount: 0.3))
        let result = preset("edge-frame").applying(to: current)
        #expect(result.edgeBlur.shape == .frame)
        #expect(result.tiltShift == current.tiltShift)
    }

    @Test func applyingVignettePresetPreservesOtherEffectKinds() {
        let current = ImageEffects(edgeBlur: ImageEdgeBlur(amount: 0.3))
        let result = preset("vignette-aged").applying(to: current)
        #expect(result.vignette.irregularity == 0.72)
        #expect(result.edgeBlur == current.edgeBlur)
    }

    @Test func applyingLensDirtPresetUsesFullStrengthAndPreservesOtherEffectKinds() {
        let current = ImageEffects(vignette: ImageVignette(amount: 0.3))
        let result = preset("dirt-smudged").applying(to: current)

        #expect(result.lensDirt.amount == 1)
        #expect(result.lensDirt.smudge == 0.8)
        #expect(result.vignette == current.vignette)
    }

    @Test func applyingSoftFocusPresetUsesFullStrengthAndPreservesOtherEffectKinds() {
        let current = ImageEffects(lensDirt: ImageLensDirt(amount: 0.3))
        let result = preset("focus-portrait").applying(to: current)

        #expect(result.softFocus.amount == 1)
        #expect(result.softFocus.detail == 0.86)
        #expect(result.lensDirt == current.lensDirt)
    }

    @Test func removingSoftFocusPreservesOtherEffectKinds() {
        let current = ImageEffects(
            lensDirt: ImageLensDirt(amount: 0.3),
            softFocus: ImageSoftFocus(amount: 1, softness: 0.7)
        )
        let result = preset("focus-classic").removing(from: current)

        #expect(result.softFocus == .disabled)
        #expect(result.lensDirt == current.lensDirt)
    }

    @Test func removingLensDirtPreservesOtherEffectKinds() {
        let current = ImageEffects(
            vignette: ImageVignette(amount: 0.3),
            lensDirt: ImageLensDirt(amount: 1, density: 0.5)
        )
        let result = preset("dirt-clean").removing(from: current)

        #expect(result.lensDirt == .disabled)
        #expect(result.vignette == current.vignette)
    }

    @Test func initialSelectionPrioritizesVisibleTopLayer() {
        let effects = ImageEffects(
            filmGrain: ImageFilmGrain(amount: 0.2),
            lightLeak: ImageLightLeak(amount: 0.2),
            chromaticAberration: ImageChromaticAberration(amount: 0.2)
        )

        #expect(GalleryEffectPreset.initialSelectionID(for: effects) == "chromatic-soft")
        #expect(GalleryEffectPreset.initialSelectionID(for: .neutral) == "none")
    }

    private func preset(_ id: String) -> GalleryEffectPreset {
        GalleryEffectPreset.all.first { $0.id == id }!
    }

    private func appliedAmount(for kind: GalleryEffectKind, in effects: ImageEffects) -> Double {
        switch kind {
        case .none: 0
        case .filmGrain: effects.filmGrain.amount
        case .lightLeak: effects.lightLeak.amount
        case .chromaticAberration: effects.chromaticAberration.amount
        case .halation: effects.halation.amount
        case .dustAndScratches: effects.dustAndScratches.amount
        case .bloom: effects.bloom.amount
        case .vhs: effects.vhs.amount
        case .lensWarp: effects.lensWarp.amount
        case .motionBlur: effects.motionBlur.amount
        case .zoomBlur: effects.zoomBlur.amount
        case .kaleidoscope: effects.kaleidoscope.amount
        case .sparkle: effects.sparkle.amount
        case .pixelSort: effects.pixelSort.amount
        case .tiltShift: effects.tiltShift.amount
        case .edgeBlur: effects.edgeBlur.amount
        case .vignette: effects.vignette.amount
        case .lensDirt: effects.lensDirt.amount
        case .softFocus: effects.softFocus.amount
        }
    }
}
