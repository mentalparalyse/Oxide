import ImageProcessor
import Testing
@testable import Gallery

struct GalleryEffectPresetTests {
    @Test func noneClearsEveryEffect() {
        let enabled = ImageEffects(
            filmGrain: ImageFilmGrain(amount: 0.5),
            lightLeak: ImageLightLeak(amount: 0.5),
            chromaticAberration: ImageChromaticAberration(amount: 0.5),
            halation: ImageHalation(amount: 0.5),
            dustAndScratches: ImageDustAndScratches(amount: 0.5),
            bloom: ImageBloom(amount: 0.5),
            vhs: ImageVHS(amount: 0.5)
        )

        #expect(preset("none").applying(to: enabled) == .neutral)
    }

    @Test func applyingPresetPreservesOtherEffectKinds() {
        let current = ImageEffects(
            lightLeak: ImageLightLeak(amount: 0.4),
            chromaticAberration: ImageChromaticAberration(amount: 0.3)
        )
        let result = preset("grain-film").applying(to: current)

        #expect(result.filmGrain.amount == 0.55)
        #expect(result.lightLeak == current.lightLeak)
        #expect(result.chromaticAberration == current.chromaticAberration)
    }

    @Test func presetsHaveUniqueIdentifiers() {
        let identifiers = GalleryEffectPreset.all.map(\.id)

        #expect(Set(identifiers).count == identifiers.count)
    }

    @Test func applyingHalationPresetPreservesOtherEffectKinds() {
        let current = ImageEffects(filmGrain: ImageFilmGrain(amount: 0.3))
        let result = preset("halation-dream").applying(to: current)

        #expect(result.halation.amount == 0.68)
        #expect(result.filmGrain == current.filmGrain)
    }

    @Test func applyingDustPresetPreservesOtherEffectKinds() {
        let current = ImageEffects(halation: ImageHalation(amount: 0.3))
        let result = preset("dust-archive").applying(to: current)

        #expect(result.dustAndScratches.amount == 0.55)
        #expect(result.halation == current.halation)
    }

    @Test func applyingBloomPresetPreservesOtherEffectKinds() {
        let current = ImageEffects(dustAndScratches: ImageDustAndScratches(amount: 0.3))
        let result = preset("bloom-dream").applying(to: current)

        #expect(result.bloom.amount == 0.62)
        #expect(result.dustAndScratches == current.dustAndScratches)
    }

    @Test func applyingVHSPresetPreservesOtherEffectKinds() {
        let current = ImageEffects(bloom: ImageBloom(amount: 0.3))
        let result = preset("vhs-tracking").applying(to: current)

        #expect(result.vhs.amount == 0.68)
        #expect(result.bloom == current.bloom)
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
}
