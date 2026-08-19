import CoreImage
import Foundation
import Testing
@testable import ImageProcessor

struct ImageEffectSettingsTests {
    @Test func filmGrainSettingsClampInvalidValues() {
        #expect(ImageFilmGrain(amount: -1, size: 0).amount == 0)
        #expect(ImageFilmGrain(amount: 2, size: 8).amount == 1)
        #expect(ImageFilmGrain(amount: 2, size: 8).size == 4)
    }

    @Test func legacyEffectsPayloadDecodesAsNeutral() throws {
        let effects = try JSONDecoder().decode(ImageEffects.self, from: Data("{}".utf8))

        #expect(effects == .neutral)
    }

    @Test func processorAppliesFilmGrainWithoutChangingExtent() throws {
        let input = CIImage(color: .gray)
            .cropped(to: CGRect(x: 0, y: 0, width: 32, height: 24))
        let effects = ImageEffects(
            filmGrain: ImageFilmGrain(amount: 0.7, size: 1.5, seed: 42)
        )

        let output = try #require(ImageProcessor().outputImage(
            for: input,
            presetID: nil,
            effects: effects
        ))

        #expect(output.extent == input.extent)
    }

    @Test func lightLeakSettingsClampInvalidValues() {
        let leak = ImageLightLeak(amount: 2, position: -1, warmth: 3)

        #expect(leak.amount == 1)
        #expect(leak.position == 0)
        #expect(leak.warmth == 1)
    }

    @Test func processorCombinesLightLeakAndFilmGrain() throws {
        let input = CIImage(color: .gray)
            .cropped(to: CGRect(x: 0, y: 0, width: 32, height: 24))
        let effects = ImageEffects(
            filmGrain: ImageFilmGrain(amount: 0.4),
            lightLeak: ImageLightLeak(amount: 0.7)
        )

        let output = try #require(ImageProcessor().outputImage(
            for: input,
            presetID: nil,
            effects: effects
        ))

        #expect(output.extent == input.extent)
    }

    @Test func chromaticSettingsClampInvalidValues() {
        let settings = ImageChromaticAberration(amount: 2, direction: -1, falloff: 3)

        #expect(settings.amount == 1)
        #expect(settings.direction == 0)
        #expect(settings.falloff == 1)
    }

    @Test func processorCombinesAllEffects() throws {
        let input = CIImage(color: .gray)
            .cropped(to: CGRect(x: 0, y: 0, width: 48, height: 32))
        let effects = ImageEffects(
            filmGrain: ImageFilmGrain(amount: 0.3),
            lightLeak: ImageLightLeak(amount: 0.4),
            chromaticAberration: ImageChromaticAberration(amount: 0.7),
            halation: ImageHalation(amount: 0.5)
        )

        let output = try #require(ImageProcessor().outputImage(
            for: input,
            presetID: nil,
            effects: effects
        ))

        #expect(output.extent == input.extent)
    }

    @Test func halationSettingsClampInvalidValues() {
        let settings = ImageHalation(amount: 2, radius: -1, threshold: 3)

        #expect(settings.amount == 1)
        #expect(settings.radius == 0)
        #expect(settings.threshold == 1)
    }
}
