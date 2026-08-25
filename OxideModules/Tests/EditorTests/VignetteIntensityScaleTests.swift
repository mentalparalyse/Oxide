import Testing
@testable import Editor

struct VignetteIntensityScaleTests {
    private let scale = VignetteIntensityScale(baseAmount: 0.58)

    @Test func midpointPreservesPresetStrength() {
        #expect(scale.amount(for: 0.5) == 0.58)
        #expect(scale.sliderValue(for: 0.58) == 0.5)
    }

    @Test func endpointsDisableAndApplyControlledBoost() {
        #expect(scale.amount(for: 0) == 0)
        #expect(scale.amount(for: 1) == scale.maximumAmount)
        #expect(scale.maximumAmount < 1)
    }

    @Test func conversionRoundTripsAcrossSlider() {
        for value in stride(from: 0.0, through: 1.0, by: 0.1) {
            let roundTrip = scale.sliderValue(for: scale.amount(for: value))
            #expect(abs(roundTrip - value) < 0.000_001)
        }
    }

    @Test func valuesAreClamped() {
        #expect(scale.amount(for: -1) == 0)
        #expect(scale.amount(for: 2) == scale.maximumAmount)
    }
}
