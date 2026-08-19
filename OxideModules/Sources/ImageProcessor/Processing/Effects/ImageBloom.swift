import Foundation

public struct ImageBloom: Equatable, Codable, Sendable {
    public var amount: Double
    public var radius: Double
    public var threshold: Double
    public var warmth: Double
    public var spatialMask: ImageSpatialEffectMask

    public var isEnabled: Bool { amount > 0 }

    public init(
        amount: Double = 0,
        radius: Double = 0.5,
        threshold: Double = 0.45,
        warmth: Double = 0.5,
        spatialMask: ImageSpatialEffectMask = .fullFrame
    ) {
        self.amount = Self.clamp(amount)
        self.radius = Self.clamp(radius)
        self.threshold = Self.clamp(threshold)
        self.warmth = Self.clamp(warmth)
        self.spatialMask = spatialMask
    }

    public static let disabled = ImageBloom()

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }

    private enum CodingKeys: String, CodingKey {
        case amount, radius, threshold, warmth, spatialMask
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            amount: try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0,
            radius: try container.decodeIfPresent(Double.self, forKey: .radius) ?? 0.5,
            threshold: try container.decodeIfPresent(Double.self, forKey: .threshold) ?? 0.45,
            warmth: try container.decodeIfPresent(Double.self, forKey: .warmth) ?? 0.5,
            spatialMask: try container.decodeIfPresent(ImageSpatialEffectMask.self, forKey: .spatialMask) ?? .fullFrame
        )
    }
}
