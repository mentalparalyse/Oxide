import ImageProcessor
import Testing
@testable import Gallery

struct GalleryEffectPresetTests {
    @Test func noneClearsEveryEffect() {
        let enabled = ImageEffects(
            filmGrain: ImageFilmGrain(amount: 0.5),
            lightLeak: ImageLightLeak(amount: 0.5),
            chromaticAberration: ImageChromaticAberration(amount: 0.5)
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
