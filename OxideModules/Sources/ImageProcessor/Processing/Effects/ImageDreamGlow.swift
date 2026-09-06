import Foundation

public struct ImageDreamGlow: Equatable, Codable, Sendable {
    public var amount: Double
    public var glow: Double
    public var spread: Double
    public var threshold: Double
    public var spatialMask: ImageSpatialEffectMask

    public var isEnabled: Bool { amount > 0 && glow > 0 }

    public init(
        amount: Double = 0,
        glow: Double = 0.5,
        spread: Double = 0.55,
        threshold: Double = 0.4,
        spatialMask: ImageSpatialEffectMask = .fullFrame
    ) {
        self.amount = Self.clamp(amount)
        self.glow = Self.clamp(glow)
        self.spread = Self.clamp(spread)
        self.threshold = Self.clamp(threshold)
        self.spatialMask = spatialMask
    }

    public static let disabled = ImageDreamGlow()

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    private enum CodingKeys: String, CodingKey {
        case amount, glow, spread, threshold, spatialMask
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            glow: try container.decodeIfPresent(Double.self, forKey: .glow) ?? 0.5,
            spread: try container.decodeIfPresent(Double.self, forKey: .spread) ?? 0.55,
            threshold: try container.decodeIfPresent(Double.self, forKey: .threshold) ?? 0.4,
            spatialMask: try container.decodeIfPresent(ImageSpatialEffectMask.self, forKey: .spatialMask) ?? .fullFrame
        )
    }
}
