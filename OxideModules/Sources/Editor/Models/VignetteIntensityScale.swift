import Foundation

struct VignetteIntensityScale: Equatable, Sendable {
    private static let midpoint = 0.5
    private static let responseExponent = 1.35
    private static let boostFraction = 0.55

    let baseAmount: Double

    init(baseAmount: Double) {
        self.baseAmount = Self.clamp(baseAmount)
    }

    var maximumAmount: Double {
        baseAmount + (1 - baseAmount) * Self.boostFraction
    }

    func amount(for sliderValue: Double) -> Double {
        let value = Self.clamp(sliderValue)
        if value <= Self.midpoint {
            let progress = value / Self.midpoint
            return baseAmount * pow(progress, Self.responseExponent)
        }

        let progress = (value - Self.midpoint) / Self.midpoint
        return baseAmount
            + (maximumAmount - baseAmount) * pow(progress, Self.responseExponent)
    }

    func sliderValue(for amount: Double) -> Double {
        let value = Self.clamp(amount)
        if value <= baseAmount {
            guard baseAmount > 0 else { return 0 }
            let progress = pow(value / baseAmount, 1 / Self.responseExponent)
            return Self.midpoint * progress
        }

        let boostRange = maximumAmount - baseAmount
        guard boostRange > 0 else { return Self.midpoint }
        let progress = pow(min((value - baseAmount) / boostRange, 1), 1 / Self.responseExponent)
        return Self.midpoint + Self.midpoint * progress
    }

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}
