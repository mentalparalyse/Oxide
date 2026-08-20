import CoreImage
import Foundation
import Testing
@testable import ImageProcessor

struct ImageEffectSettingsTests {
    @Test func lensWarpSettingsClampInvalidValues() {
        let settings = ImageLensWarp(amount: 2, scale: -3)
        #expect(settings.amount == 1)
        #expect(settings.scale == -1)
    }

    @Test func legacyLensWarpDecodesStableDefaults() throws {
        let settings = try JSONDecoder().decode(
            ImageLensWarp.self,
            from: Data(#"{"amount":0.4}"#.utf8)
        )
        #expect(settings == ImageLensWarp(amount: 0.4))
    }
    @Test func vhsSettingsClampInvalidValues() {
        let settings = ImageVHS(amount: 2, distortion: -1, scanlines: 3, colorBleed: -2)
        #expect(settings.amount == 1)
        #expect(settings.distortion == 0)
        #expect(settings.scanlines == 1)
        #expect(settings.colorBleed == 0)
    }

    @Test func legacyVHSDecodesStableDefaults() throws {
        let settings = try JSONDecoder().decode(
            ImageVHS.self,
            from: Data(#"{"amount":0.4}"#.utf8)
        )
        #expect(settings == ImageVHS(amount: 0.4))
    }
    @Test func bloomSettingsClampInvalidValues() {
        let settings = ImageBloom(amount: 2, radius: -1, threshold: 3, warmth: -2)
        #expect(settings.amount == 1)
        #expect(settings.radius == 0)
        #expect(settings.threshold == 1)
        #expect(settings.warmth == 0)
    }

    @Test func legacyBloomDecodesStableDefaults() throws {
        let settings = try JSONDecoder().decode(
            ImageBloom.self,
            from: Data(#"{"amount":0.4}"#.utf8)
        )
        #expect(settings == ImageBloom(amount: 0.4))
    }

    @Test func spatialMaskClampsInvalidValues() {
        let mask = ImageSpatialEffectMask(
            mode: .spot,
            centerX: -1,
            centerY: 2,
            radius: 0,
            feather: 4
        )

        #expect(mask.centerX == 0)
        #expect(mask.centerY == 1)
        #expect(mask.radius == 0.05)
        #expect(mask.feather == 1)
    }

    @Test func legacySpatialEffectsDecodeAsFullFrame() throws {
        let chromatic = try JSONDecoder().decode(
            ImageChromaticAberration.self,
            from: Data(#"{"amount":0.5}"#.utf8)
        )

        #expect(chromatic.spatialMask == .fullFrame)
    }

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
            halation: ImageHalation(amount: 0.5),
            dustAndScratches: ImageDustAndScratches(amount: 0.6),
            bloom: ImageBloom(amount: 0.5),
            vhs: ImageVHS(amount: 0.6),
            lensWarp: ImageLensWarp(amount: 0.5)
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

    @Test func dustAndScratchesSettingsClampInvalidValues() {
        let settings = ImageDustAndScratches(
            amount: 2,
            dustAmount: -1,
            scratchAmount: 3,
            particleSize: 4
        )

        #expect(settings.amount == 1)
        #expect(settings.dustAmount == 0)
        #expect(settings.scratchAmount == 1)
        #expect(settings.particleSize == 1)
    }
}
