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
}
